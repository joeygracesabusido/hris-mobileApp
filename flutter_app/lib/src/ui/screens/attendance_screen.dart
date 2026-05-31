import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../auth/auth_provider.dart';
import '../../data/providers/api_client.dart';
import '../../data/providers/face_repository.dart';
import '../../data/providers/time_log_list_provider.dart';
import '../../data/providers/time_log_repository.dart';
import '../widgets/app_theme.dart';
import '../widgets/face_capture_widget.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  Position? _currentPosition;
  bool _isLoadingLocation = true;
  String? _locationError;
  bool _withinRange = false;
  String _closestLocation = '';
  double _closestDistance = 0;
  bool _isClockingIn = false;
  bool _isClockingOut = false;
  bool _showFaceVerify = false;
  String _verifyMode = '';
  String? _faceError;
  int _failedAttempts = 0;
  List<double>? _storedDescriptor;
  bool _loadingDescriptor = false;

  final FaceRepository _faceRepo = FaceRepository();
  final TimeLogRepository _timeLogRepo = TimeLogRepository();

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError = 'Location services are disabled';
          _isLoadingLocation = false;
        });
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationError = 'Location permission denied';
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError = 'Location permission permanently denied';
          _isLoadingLocation = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });

      _checkGeofence(position);
    } catch (e) {
      setState(() {
        _locationError = 'Failed to get location: $e';
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _checkGeofence(Position position) async {
    try {
      final response = await ApiClient.instance.dio.get('/office-location');
      if (!mounted) return;
      final locations = response.data as List<dynamic>;

      if (locations.isEmpty) {
        setState(() {
          _withinRange = true;
          _closestLocation = 'No geofence configured';
        });
        return;
      }

      var minDistance = double.infinity;
      var closestName = '';

      for (final loc in locations) {
        final lat = (loc['latitude'] as num).toDouble();
        final lon = (loc['longitude'] as num).toDouble();
        final radius = (loc['radius'] as num).toDouble();

        final distance = _calculateDistance(
          position.latitude,
          position.longitude,
          lat,
          lon,
        );

        if (distance <= radius) {
          setState(() {
            _withinRange = true;
            _closestLocation = loc['name'] as String;
            _closestDistance = distance;
          });
          return;
        }

        if (distance < minDistance) {
          minDistance = distance;
          closestName = loc['name'] as String;
        }
      }

      setState(() {
        _withinRange = false;
        _closestLocation = closestName;
        _closestDistance = minDistance;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _withinRange = true);
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371e3;
    final phi1 = lat1 * pi / 180;
    final phi2 = lat2 * pi / 180;
    final deltaPhi = (lat2 - lat1) * pi / 180;
    final deltaLambda = (lon2 - lon1) * pi / 180;

    final a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
        cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  Future<void> _startAttendance(String mode) async {
    if (!_withinRange && _closestLocation.isNotEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You must be within range of $_closestLocation. Distance: ${_closestDistance.toStringAsFixed(0)}m'),
          backgroundColor: const Color(0xFFFF6B6B),
        ),
      );
      return;
    }

    setState(() {
      _verifyMode = mode;
      _loadingDescriptor = true;
      _faceError = null;
      _failedAttempts = 0;
    });

    try {
      final authState = ref.read(authProvider);
      final employeeId = authState.user?['employeeId']?.toString() ??
          authState.user?['id']?.toString();

      if (employeeId == null) {
        setState(() {
          _loadingDescriptor = false;
          _faceError = 'Employee ID not found';
        });
        return;
      }

      final descriptor = await _faceRepo.getFaceDescriptor(employeeId);
      setState(() {
        _storedDescriptor = descriptor;
        _loadingDescriptor = false;
        _showFaceVerify = true;
      });
    } catch (e) {
      setState(() {
        _loadingDescriptor = false;
        _faceError = 'Face not enrolled. Please enroll first.';
      });
    }
  }

  Future<void> _handleFaceResult(bool isMatch, double distance) async {
    if (!isMatch) {
      setState(() => _failedAttempts++);
      if (_failedAttempts >= 3) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Too many failed attempts. Contact HR.'),
            backgroundColor: Color(0xFFFF6B6B),
          ),
        );
      }
      return;
    }

    try {
      final authState = ref.read(authProvider);
      final employeeId = authState.user?['employeeId']?.toString() ??
          authState.user?['id']?.toString();

      if (employeeId == null) throw Exception('Employee ID not found');

      setState(() {
        if (_verifyMode == 'clockIn') {
          _isClockingIn = true;
        } else {
          _isClockingOut = true;
        }
      });

      if (_verifyMode == 'clockIn') {
        await _timeLogRepo.clockIn(
          employeeId,
          latitude: _currentPosition?.latitude,
          longitude: _currentPosition?.longitude,
        );
      } else {
        await _timeLogRepo.clockOut(
          employeeId,
          latitude: _currentPosition?.latitude,
          longitude: _currentPosition?.longitude,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_verifyMode == 'clockIn'
              ? 'Clock in recorded successfully!'
              : 'Clock out recorded successfully!'),
          backgroundColor: const Color(0xFF00D1B2),
        ),
      );

      setState(() {
        _showFaceVerify = false;
        _isClockingIn = false;
        _isClockingOut = false;
      });

      ref.read(timeLogListProvider.notifier).refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: const Color(0xFFFF6B6B),
        ),
      );
      setState(() {
        _isClockingIn = false;
        _isClockingOut = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    if (!authState.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Attendance'),
          backgroundColor: AppTheme.primary,
        ),
        backgroundColor: AppTheme.background,
        body: const Center(
          child: Text('Please log in', style: TextStyle(color: AppTheme.textSecondary)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        backgroundColor: AppTheme.primary,
        leading: IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
          ),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      backgroundColor: AppTheme.background,
      body: _showFaceVerify ? _buildFaceVerify() : _buildMainView(),
    );
  }

  Widget _buildMainView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGpsCard(),
          const SizedBox(height: 20),
          if (_faceError != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6B).withAlpha(25),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFF6B6B).withAlpha(80)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.error_outline, color: Color(0xFFFF6B6B), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Face Enrollment Required',
                        style: TextStyle(
                          color: Color(0xFFFF6B6B),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your face has not been enrolled yet. Please enroll your face first.',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/face-enroll'),
                    icon: const Icon(Icons.face, size: 18),
                    label: const Text('Enroll Face'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D1B2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.login,
                  label: 'Clock In',
                  color: const Color(0xFF00D1B2),
                  loading: _isClockingIn,
                  onTap: _withinRange || _closestLocation.isEmpty
                      ? () => _startAttendance('clockIn')
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.logout,
                  label: 'Clock Out',
                  color: const Color(0xFFFF6B6B),
                  loading: _isClockingOut,
                  onTap: _withinRange || _closestLocation.isEmpty
                      ? () => _startAttendance('clockOut')
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha(15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withAlpha(40)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 18),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Attendance requires GPS location verification and facial recognition. '
                    'Make sure you are at your office location and have good lighting.',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGpsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _withinRange
              ? const Color(0xFF00D1B2).withAlpha(60)
              : const Color(0xFFFF6B6B).withAlpha(60),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _isLoadingLocation
                      ? Colors.grey.withAlpha(30)
                      : _withinRange
                          ? const Color(0xFF00D1B2).withAlpha(30)
                          : const Color(0xFFFF6B6B).withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _isLoadingLocation
                      ? Icons.gps_off
                      : _withinRange
                          ? Icons.gps_fixed
                          : Icons.gps_off,
                  color: _isLoadingLocation
                      ? Colors.grey
                      : _withinRange
                          ? const Color(0xFF00D1B2)
                          : const Color(0xFFFF6B6B),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isLoadingLocation
                          ? 'Getting location...'
                          : _locationError != null
                              ? 'Location Error'
                              : _withinRange
                                  ? 'Within Range'
                                  : 'Outside Range',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _locationError ??
                          (_closestLocation.isNotEmpty
                              ? 'Nearest: $_closestLocation (${_closestDistance.toStringAsFixed(0)}m)'
                              : 'No office location configured'),
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (!_isLoadingLocation)
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppTheme.textSecondary, size: 20),
                  onPressed: _getLocation,
                ),
            ],
          ),
          if (_currentPosition != null) ...[
            const SizedBox(height: 12),
            Text(
              '${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool loading,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        decoration: BoxDecoration(
          color: onTap != null ? AppTheme.cardBackground : AppTheme.cardBackground.withAlpha(100),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: loading ? color : color.withAlpha(onTap != null ? 60 : 20),
          ),
          boxShadow: onTap != null
              ? [
                  BoxShadow(
                    color: color.withAlpha(30),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            if (loading)
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  color: color,
                  strokeWidth: 3,
                ),
              )
            else
              Icon(icon, color: onTap != null ? color : color.withAlpha(80), size: 32),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                color: onTap != null ? Colors.white : Colors.white38,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaceVerify() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Face Verification',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Please look at the camera to verify your identity',
            style: TextStyle(
              color: Colors.white.withAlpha(150),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          if (_loadingDescriptor)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              ),
            )
          else if (_storedDescriptor != null)
            Expanded(
              child: FaceCaptureWidget(
                mode: FaceCaptureMode.verify,
                storedDescriptor: _storedDescriptor,
                onVerify: _handleFaceResult,
              ),
            ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => setState(() => _showFaceVerify = false),
            icon: const Icon(Icons.close, color: AppTheme.textSecondary),
            label: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
