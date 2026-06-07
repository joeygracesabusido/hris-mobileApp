import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/providers/face_repository.dart';
import '../widgets/app_theme.dart';

class FaceStatusScreen extends ConsumerStatefulWidget {
  const FaceStatusScreen({super.key});

  @override
  ConsumerState<FaceStatusScreen> createState() => _FaceStatusScreenState();
}

class _FaceStatusScreenState extends ConsumerState<FaceStatusScreen> {
  final FaceRepository _faceRepo = FaceRepository();
  FaceEnrollmentStatus? _status;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final status = await _faceRepo.getEnrollmentStatus();
      setState(() {
        _status = status;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final month = months[dt.month - 1];
    final day = dt.day.toString();
    final year = dt.year.toString();

    int hour = dt.hour;
    final period = hour >= 12 ? 'PM' : 'AM';
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    final minute = dt.minute.toString().padLeft(2, '0');

    return '$month $day, $year $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Registration'),
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF00D1B2)),
            SizedBox(height: 16),
            Text(
              'Checking enrollment status...',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: const Color(0xFFFF6B6B), size: 48),
              const SizedBox(height: 16),
              const Text(
                'Unable to check enrollment status',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchStatus,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
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
      );
    }

    if (_status == null) {
      return const Center(
        child: Text(
          'Unexpected error',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enrollment Status',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Employee: ${_status!.employeeName}',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _status!.enrolled
                  ? const Color(0xFF00D1B2).withAlpha(25)
                  : const Color(0xFFFF6B6B).withAlpha(25),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _status!.enrolled
                    ? const Color(0xFF00D1B2).withAlpha(80)
                    : const Color(0xFFFF6B6B).withAlpha(80),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _status!.enrolled ? Icons.check_circle : Icons.info_outline,
                      color: _status!.enrolled
                          ? const Color(0xFF00D1B2)
                          : const Color(0xFFFF6B6B),
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _status!.enrolled ? 'Enrolled' : 'Not Enrolled',
                      style: TextStyle(
                        color: _status!.enrolled
                            ? const Color(0xFF00D1B2)
                            : const Color(0xFFFF6B6B),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (_status!.enrolled && _status!.enrolledAt != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Enrolled on ${_formatDate(_status!.enrolledAt!)}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
                if (!_status!.enrolled) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'You haven\'t enrolled your face yet. Enroll now to use face verification for attendance.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => context.go('/face-enroll'),
                  icon: Icon(
                    _status!.enrolled ? Icons.refresh : Icons.face,
                    size: 18,
                  ),
                  label: Text(
                    _status!.enrolled ? 'Re-enroll Face' : 'Enroll Now',
                  ),
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
        ],
      ),
    );
  }
}
