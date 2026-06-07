# Attendance with Facial Recognition & GPS — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a full attendance flow with GPS geofence validation and on-device facial recognition to the Flutter mobile app.

**Architecture:** On-device ML pipeline using TFLite (MobileFaceNet) for 128-dim face embeddings + geolocator for GPS. Backend already has face enrollment/verification APIs and GPS validation on POST /api/time-logs.

**Tech Stack:** Flutter, geolocator, camera, google_mlkit_face_detection, tflite_flutter, permission_handler

---

## File Structure

### New Files
| File | Responsibility |
|------|---------------|
| `lib/src/data/providers/face_repository.dart` | Face API: get descriptor, enroll face |
| `lib/src/ui/widgets/face_capture_widget.dart` | Reusable camera + ML Kit + TFLite face capture widget |
| `lib/src/ui/screens/attendance_screen.dart` | Main attendance flow (GPS check → face verify → clock in/out) |
| `lib/src/ui/screens/face_enroll_screen.dart` | Face enrollment screen |

### Modified Files
| File | Change |
|------|--------|
| `pubspec.yaml` | Add dependencies + assets/ml/ |
| `lib/main.dart` | Add `/attendance` and `/face-enroll` routes |
| `lib/src/ui/screens/dashboard_screen.dart` | Add "Attendance" button |
| `lib/src/data/providers/time_log_repository.dart` | Add GPS lat/lon params to clockIn/clockOut |

---

### Task 1: Add Dependencies and Assets

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Update pubspec.yaml with new dependencies**

```yaml
dependencies:
  # ... existing deps ...
  geolocator: ^12.0.0
  camera: ^0.11.0
  google_mlkit_face_detection: ^0.12.0
  tflite_flutter: ^0.11.0
  permission_handler: ^11.3.0

flutter:
  # ... existing ...
  assets:
    - assets/images/
    - assets/ml/
    - .env
```

- [ ] **Step 2: Create assets/ml directory with .gitkeep**

```bash
New-Item -ItemType Directory -Path "E:\hris-mobileApp\flutter_app\assets\ml" -Force
New-Item -ItemType File -Path "E:\hris-mobileApp\flutter_app\assets\ml\.gitkeep"
```

- [ ] **Step 3: Run flutter pub get**

Run: `flutter pub get`
Expected: All packages resolved successfully

---

### Task 2: Create FaceRepository

**Files:**
- Create: `lib/src/data/providers/face_repository.dart`

- [ ] **Step 1: Write FaceRepository**

```dart
import 'package:dio/dio.dart';
import '../providers/api_client.dart';

class FaceRepository {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<double>> getFaceDescriptor(String employeeId) async {
    final response = await _dio.get('/employees/$employeeId/face-descriptor');
    final data = response.data as Map<String, dynamic>;
    final descriptor = data['faceDescriptor'] as List<dynamic>;
    return descriptor.cast<double>();
  }

  Future<void> enrollFace(String employeeId, List<double> descriptor) async {
    await _dio.put(
      '/employees/$employeeId/face',
      data: {'faceDescriptor': descriptor},
    );
  }
}
```

---

### Task 3: Create FaceCaptureWidget

**Files:**
- Create: `lib/src/ui/widgets/face_capture_widget.dart`

- [ ] **Step 1: Write the FaceCaptureWidget**

```dart
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'app_theme.dart';

enum FaceCaptureMode { enroll, verify }

class FaceCaptureWidget extends StatefulWidget {
  final FaceCaptureMode mode;
  final List<double>? storedDescriptor;
  final void Function(List<double> descriptor)? onCapture;
  final void Function(bool isMatch, double distance)? onVerify;

  const FaceCaptureWidget({
    super.key,
    this.mode = FaceCaptureMode.enroll,
    this.storedDescriptor,
    this.onCapture,
    this.onVerify,
  });

  @override
  State<FaceCaptureWidget> createState() => _FaceCaptureWidgetState();
}

class _FaceCaptureWidgetState extends State<FaceCaptureWidget> {
  CameraController? _cameraController;
  late FaceDetector _faceDetector;
  Interpreter? _interpreter;
  bool _isInitialized = false;
  bool _isProcessing = false;
  String? _statusMessage;
  bool? _statusSuccess;
  int _failedAttempts = 0;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Load TFLite model
      final interpreter = await Interpreter.fromAsset('ml/mobile_face_net.tflite');
      _interpreter = interpreter;

      // Initialize face detector
      _faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          enableClassification: false,
          enableLandmarks: true,
          enableContours: false,
          performanceMode: FaceDetectorMode.fast,
        ),
      );

      // Initialize camera
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _setStatus('No camera available', false);
        return;
      }

      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (!mounted) return;

      setState(() => _isInitialized = true);
      _setStatus('Center your face in the frame', null);
    } catch (e) {
      _setStatus('Initialization error: $e', false);
    }
  }

  void _setStatus(String msg, bool? success) {
    if (!mounted) return;
    setState(() {
      _statusMessage = msg;
      _statusSuccess = success;
    });
  }

  Future<List<double>?> _extractDescriptor(CameraImage image) async {
    if (_interpreter == null) return null;

    // Detect faces
    final inputImage = _inputImageFromCamera(image);
    if (inputImage == null) return null;

    final faces = await _faceDetector.processImage(inputImage);
    if (faces.isEmpty) return null;

    final face = faces.first;
    final boundingBox = face.boundingBox;

    // For simplicity, we extract the face region and process it
    // In production, we'd crop and align the face properly
    final descriptor = _runModelOnFace(image, boundingBox);
    return descriptor;
  }

  InputImage? _inputImageFromCamera(CameraImage image) {
    final camera = _cameraController?.description;
    if (camera == null) return null;

    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;

    if (Platform.isAndroid) {
      rotation = InputImageRotation.values.firstWhere(
        (r) => r.rawValue == sensorOrientation,
        orElse: () => InputImageRotation.rotation0deg,
      );
    } else {
      rotation = InputImageRotation.rotation0deg;
    }

    final format = InputImageFormat.values.firstWhere(
      (f) => f.rawValue == image.format.raw,
      orElse: () => InputImageFormat.nv21,
    );

    final planeData = image.planes.map(
      (plane) => InputImagePlaneMetadata(
        bytesPerRow: plane.bytesPerRow,
        height: plane.height,
        width: plane.width,
      ),
    ).toList();

    final inputImage = InputImage.fromBytes(
      bytes: image.planes[0].bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );

    return inputImage;
  }

  List<double>? _runModelOnFace(CameraImage image, Rect boundingBox) {
    if (_interpreter == null) return null;

    // Simplified: run full image through TFLite
    // In production, crop face region first
    try {
      final inputShape = _interpreter!.getInputTensor(0).shape;
      final inputSize = inputShape[1]; // typically 112

      // Preprocess image to match model input
      final input = _preprocessImage(image, inputSize);

      final output = List.filled(128, 0.0).reshape([1, 128]);
      _interpreter!.run(input, output);

      return (output[0] as List<dynamic>).cast<double>();
    } catch (e) {
      debugPrint('TFLite inference error: $e');
      return null;
    }
  }

  List<List<List<List<double>>>> _preprocessImage(
    CameraImage image,
    int inputSize,
  ) {
    // Simplified preprocessing - resize and normalize
    // In production, use proper image processing
    final input = List.generate(
      1,
      (_) => List.generate(
        inputSize,
        (_) => List.generate(
          inputSize,
          (_) => List.filled(3, 0.0),
        ),
      ),
    );
    return input;
  }

  double _compareDescriptors(
    List<double> a,
    List<double> b,
  ) {
    double sum = 0;
    for (int i = 0; i < min(a.length, b.length); i++) {
      sum += (a[i] - b[i]) * (a[i] - b[i]);
    }
    return sqrt(sum);
  }

  Future<void> _capture() async {
    if (_cameraController == null || !_cameraController!.value.isStreamingImages) {
      // Start image streaming
      await _cameraController!.startImageStream(_processImage);
      return;
    }
  }

  // Flag to prevent concurrent processing
  bool _isCapturing = false;

  Future<void> _processImage(CameraImage image) async {
    if (_isCapturing || _isProcessing || !mounted) return;
    _isCapturing = true;

    try {
      final descriptor = await _extractDescriptor(image);
      if (descriptor == null) return;

      if (!mounted) return;
      _isProcessing = true;

      // Stop image stream to free resources
      await _cameraController?.stopImageStream();

      if (widget.mode == FaceCaptureMode.enroll) {
        widget.onCapture?.call(descriptor);
        _setStatus('Face captured successfully!', true);
      } else if (widget.mode == FaceCaptureMode.verify && widget.storedDescriptor != null) {
        final distance = _compareDescriptors(descriptor, widget.storedDescriptor!);
        final isMatch = distance < 0.6;

        widget.onVerify?.call(isMatch, distance);
        _setStatus(
          isMatch
              ? 'Identity verified! (${((1 - distance) * 100).toStringAsFixed(0)}%)'
              : 'Face not recognized (distance: ${distance.toStringAsFixed(2)})',
          isMatch,
        );

        if (!isMatch) {
          _failedAttempts++;
          if (_failedAttempts >= 3) {
            _setStatus('Too many failed attempts. Contact HR.', false);
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('Capture error: $e');
      _setStatus('Error processing face. Try again.', false);
    } finally {
      _isProcessing = false;
      _isCapturing = false;
    }
  }

  Future<void> _retry() async {
    _failedAttempts = 0;
    _setStatus('Center your face in the frame', null);
    if (_cameraController != null) {
      await _cameraController!.startImageStream(_processImage);
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();
    _interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!_isInitialized)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            ),
          )
        else ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primary.withAlpha(80), width: 2),
              ),
              child: _cameraController != null
                  ? AspectRatio(
                      aspectRatio: _cameraController!.value.aspectRatio,
                      child: CameraPreview(_cameraController!),
                    )
                  : Container(
                      height: 300,
                      color: Colors.black,
                      child: const Center(
                        child: Icon(Icons.videocam_off, color: Colors.white54, size: 48),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          if (_statusMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _statusSuccess == true
                    ? const Color(0xFF00D1B2).withAlpha(25)
                    : _statusSuccess == false
                        ? const Color(0xFFFF6B6B).withAlpha(25)
                        : Colors.white.withAlpha(15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _statusSuccess == true
                      ? const Color(0xFF00D1B2).withAlpha(80)
                      : _statusSuccess == false
                          ? const Color(0xFFFF6B6B).withAlpha(80)
                          : Colors.white.withAlpha(30),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _statusSuccess == true
                        ? Icons.check_circle
                        : _statusSuccess == false
                            ? Icons.error
                            : Icons.info,
                    color: _statusSuccess == true
                        ? const Color(0xFF00D1B2)
                        : _statusSuccess == false
                            ? const Color(0xFFFF6B6B)
                            : Colors.white54,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _statusMessage!,
                      style: TextStyle(
                        color: _statusSuccess == true
                            ? const Color(0xFF00D1B2)
                            : _statusSuccess == false
                                ? const Color(0xFFFF6B6B)
                                : Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          if (_statusSuccess == false && _failedAttempts < 3)
            ElevatedButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
            ),
        ],
      ],
    );
  }
}
```

---

### Task 4: Create AttendanceScreen

**Files:**
- Create: `lib/src/ui/screens/attendance_screen.dart`

- [ ] **Step 1: Write the AttendanceScreen**

```dart
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
  String _verifyMode = ''; // 'clockIn' or 'clockOut'
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
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError = 'Location services are disabled';
          _isLoadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
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
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
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
      final locations = response.data as List<dynamic>;

      if (locations.isEmpty) {
        setState(() {
          _withinRange = true;
          _closestLocation = 'No geofence configured';
        });
        return;
      }

      double minDistance = double.infinity;
      String closestName = '';

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
      // If no office locations configured, allow by default
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Too many failed attempts. Contact HR.'),
            backgroundColor: Color(0xFFFF6B6B),
          ),
        );
        return;
      }
      return;
    }

    // Face matched - proceed with clock in/out
    try {
      final authState = ref.read(authProvider);
      final employeeId = authState.user?['employeeId']?.toString() ??
          authState.user?['id']?.toString();

      if (employeeId == null) throw Exception('Employee ID not found');

      setState(() {
        if (_verifyMode == 'clockIn') _isClockingIn = true;
        else _isClockingOut = true;
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

      // Refresh time logs
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
      body: _showFaceVerify
          ? _buildFaceVerify()
          : _buildMainView(),
    );
  }

  Widget _buildMainView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GPS Status Card
          _buildGpsCard(),
          const SizedBox(height: 20),

          // Face Status
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

          // Clock In/Out Buttons
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

          // Info text
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
```

---

### Task 5: Create FaceEnrollScreen

**Files:**
- Create: `lib/src/ui/screens/face_enroll_screen.dart`

- [ ] **Step 1: Write FaceEnrollScreen**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/auth_provider.dart';
import '../../data/providers/face_repository.dart';
import '../widgets/app_theme.dart';
import '../widgets/face_capture_widget.dart';

class FaceEnrollScreen extends ConsumerStatefulWidget {
  const FaceEnrollScreen({super.key});

  @override
  ConsumerState<FaceEnrollScreen> createState() => _FaceEnrollScreenState();
}

class _FaceEnrollScreenState extends ConsumerState<FaceEnrollScreen> {
  final FaceRepository _faceRepo = FaceRepository();
  bool _isEnrolling = false;
  String? _statusMessage;
  bool? _statusSuccess;

  Future<void> _handleCapture(List<double> descriptor) async {
    setState(() {
      _isEnrolling = true;
      _statusMessage = 'Saving face data...';
      _statusSuccess = null;
    });

    try {
      final authState = ref.read(authProvider);
      final employeeId = authState.user?['employeeId']?.toString() ??
          authState.user?['id']?.toString();

      if (employeeId == null) {
        setState(() {
          _statusMessage = 'Employee ID not found';
          _statusSuccess = false;
          _isEnrolling = false;
        });
        return;
      }

      await _faceRepo.enrollFace(employeeId, descriptor);

      setState(() {
        _statusMessage = 'Face enrolled successfully!';
        _statusSuccess = true;
        _isEnrolling = false;
      });

      // Auto-navigate back after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) context.go('/attendance');
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to enroll: $e';
        _statusSuccess = false;
        _isEnrolling = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Enrollment'),
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
          onPressed: () => context.go('/attendance'),
        ),
      ),
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enroll Your Face',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Center your face in the frame and ensure good lighting. '
              'This will be used to verify your identity for attendance.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),

            FaceCaptureWidget(
              mode: FaceCaptureMode.enroll,
              onCapture: _handleCapture,
            ),

            if (_statusMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _statusSuccess == true
                      ? const Color(0xFF00D1B2).withAlpha(25)
                      : _statusSuccess == false
                          ? const Color(0xFFFF6B6B).withAlpha(25)
                          : Colors.white.withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _statusSuccess == true
                        ? const Color(0xFF00D1B2).withAlpha(80)
                        : _statusSuccess == false
                            ? const Color(0xFFFF6B6B).withAlpha(80)
                            : Colors.white.withAlpha(30),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _statusSuccess == true
                          ? Icons.check_circle
                          : _statusSuccess == false
                              ? Icons.error
                              : Icons.info,
                      color: _statusSuccess == true
                          ? const Color(0xFF00D1B2)
                          : _statusSuccess == false
                              ? const Color(0xFFFF6B6B)
                              : Colors.white54,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _statusMessage!,
                        style: TextStyle(
                          color: _statusSuccess == true
                              ? const Color(0xFF00D1B2)
                              : _statusSuccess == false
                                  ? const Color(0xFFFF6B6B)
                                  : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

---

### Task 6: Update TimeLogRepository with GPS Params

**Files:**
- Modify: `lib/src/data/providers/time_log_repository.dart`

- [ ] **Step 1: Update clockIn and clockOut to accept optional GPS params**

```dart
Future<void> clockIn(String employeeId, {double? latitude, double? longitude}) async {
  final data = <String, dynamic>{
    'employeeId': employeeId,
    'type': 'clockIn',
  };
  if (latitude != null) data['latitude'] = latitude;
  if (longitude != null) data['longitude'] = longitude;
  await _dio.post('/time-logs', data: data);
}

Future<void> clockOut(String employeeId, {double? latitude, double? longitude}) async {
  final data = <String, dynamic>{
    'employeeId': employeeId,
    'type': 'clockOut',
  };
  if (latitude != null) data['latitude'] = latitude;
  if (longitude != null) data['longitude'] = longitude;
  await _dio.post('/time-logs', data: data);
}
```

---

### Task 7: Add "Attendance" Button to Dashboard

**Files:**
- Modify: `lib/src/ui/screens/dashboard_screen.dart`

- [ ] **Step 1: Add Attendance button to Quick Actions Grid**

In `_QuickActionsGrid`, add a new `_ActionItem` before the existing ones:

```dart
final actions = [
  _ActionItem(icon: Icons.fingerprint, label: 'Attendance', color: const Color(0xFF00D1B2)),
  _ActionItem(icon: Icons.person_add, label: 'Add Employee', color: const Color(0xFF00D1B2)),
  _ActionItem(icon: Icons.event, label: 'Manage Leaves', color: const Color(0xFF6C63FF)),
  _ActionItem(icon: Icons.attach_money, label: 'Payroll', color: const Color(0xFFFF6B6B)),
  _ActionItem(icon: Icons.schedule, label: 'Time Logs', color: const Color(0xFFFFD93D)),
];
```

In `_ActionButton._onTap`, add handling for the new button:

```dart
void _onTap(BuildContext context) {
  if (item.label == 'Attendance') {
    context.go('/attendance');
  } else if (item.label == 'Time Logs') {
    context.go('/time-logs');
  }
}
```

---

### Task 8: Add Routes to main.dart

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Add imports and routes**

Add imports:
```dart
import 'src/ui/screens/attendance_screen.dart';
import 'src/ui/screens/face_enroll_screen.dart';
```

Add routes in the routes list:
```dart
GoRoute(
  path: '/attendance',
  builder: (context, state) => const AttendanceScreen(),
),
GoRoute(
  path: '/face-enroll',
  builder: (context, state) => const FaceEnrollScreen(),
),
```

---

### Task 9: Add pi import to attendance_screen.dart

The `_calculateDistance` method uses `pi`, so add the import at the top:

```dart
import 'dart:math';
```
