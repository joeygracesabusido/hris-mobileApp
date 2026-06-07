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
  String? _statusMessage;
  bool? _statusSuccess;

  Future<void> _handleCapture(List<double> descriptor) async {
    // Validate descriptor quality before enrollment
    if (descriptor.isEmpty || descriptor.any((d) => d.isNaN || d.isInfinite)) {
      setState(() {
        _statusMessage = 'Invalid face data detected. Please try again with better lighting.';
        _statusSuccess = false;
      });
      return;
    }
    final sumSq = descriptor.fold(0.0, (sum, d) => sum + d * d);
    if (sumSq < 1.0) {
      setState(() {
        _statusMessage = 'Face data quality too low. Please try again — center your face in good lighting.';
        _statusSuccess = false;
      });
      return;
    }
    if (sumSq > 500) {
      setState(() {
        _statusMessage = 'Face data quality anomalous. Please try again.';
        _statusSuccess = false;
      });
      return;
    }

    setState(() {
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
        });
        return;
      }

      await _faceRepo.enrollFace(employeeId, descriptor);

      setState(() {
        _statusMessage = 'Face enrolled successfully!';
        _statusSuccess = true;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) context.go('/attendance');
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to enroll: $e';
        _statusSuccess = false;
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
