import 'dart:async';
import 'package:flutter/material.dart';
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

class _FaceCaptureWidgetState extends State<FaceCaptureWidget> with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  String _statusMessage = 'Starting face capture simulation...';
  bool? _statusSuccess;
  double _simulationProgress = 0.0;
  int _failedAttempts = 0;
  Timer? _simulationTimer;
  int _currentStep = 0;

  final List<Map<String, dynamic>> _steps = [
    {'msg': 'Initializing secure camera channel...', 'progress': 0.1, 'delay': 800},
    {'msg': 'Aligning face in high-precision scan box...', 'progress': 0.35, 'delay': 1200},
    {'msg': 'Scanning facial landmarks & structure...', 'progress': 0.65, 'delay': 1500},
    {'msg': 'Extracting 128-dimensional biometric descriptor...', 'progress': 0.9, 'delay': 1000},
    {'msg': 'Processing completion...', 'progress': 1.0, 'delay': 600},
  ];

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _startSimulation();
  }

  void _startSimulation() {
    _currentStep = 0;
    _simulationProgress = 0.0;
    _setStatus(_steps[0]['msg'] as String, null);
    _runNextStep();
  }

  void _runNextStep() {
    if (!mounted) return;
    if (_currentStep >= _steps.length) {
      _completeSimulation();
      return;
    }

    final step = _steps[_currentStep];
    final delay = step['delay'] as int;

    _simulationTimer = Timer(Duration(milliseconds: delay), () {
      if (!mounted) return;
      setState(() {
        _simulationProgress = step['progress'] as double;
        _currentStep++;
        if (_currentStep < _steps.length) {
          _setStatus(_steps[_currentStep]['msg'] as String, null);
        }
      });
      _runNextStep();
    });
  }

  void _completeSimulation() {
    if (!mounted) return;

    // Generate simulated 128-dimension face descriptor (128 double elements)
    final mockDescriptor = List.generate(128, (i) => (i + 1) * 0.0078);

    if (widget.mode == FaceCaptureMode.enroll) {
      _setStatus('Face enrolled successfully on Web Simulator!', true);
      widget.onCapture?.call(mockDescriptor);
    } else {
      // For verify mode, check if we have a stored descriptor to compare against.
      // Since it's a web simulation, we always trigger a high-quality match.
      const matchDistance = 0.12; // Euclidean distance well below the 0.6 threshold
      _setStatus('Identity verified successfully! (94%)', true);
      widget.onVerify?.call(true, matchDistance);
    }
  }

  void _setStatus(String msg, bool? success) {
    if (!mounted) return;
    setState(() {
      _statusMessage = msg;
      _statusSuccess = success;
    });
  }

  Future<void> _retry() async {
    _failedAttempts = 0;
    _simulationTimer?.cancel();
    _startSimulation();
  }

  @override
  void dispose() {
    _scanController.dispose();
    _simulationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 320,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _statusSuccess == true
                    ? const Color(0xFF00D1B2).withAlpha(100)
                    : AppTheme.primary.withAlpha(80),
                width: 2,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Simulated digital grid background
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.1,
                    child: GridPaper(
                      color: AppTheme.primary,
                      divisions: 1,
                      subdivisions: 1,
                      interval: 40,
                    ),
                  ),
                ),

                // Pulsing biometric scan ring
                AnimatedBuilder(
                  animation: _scanController,
                  builder: (context, child) {
                    final scale = 1.0 + (_scanController.value * 0.08);
                    final opacity = 0.15 + ((1.0 - _scanController.value) * 0.25);
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _statusSuccess == true
                                ? const Color(0xFF00D1B2).withAlpha((opacity * 255).round())
                                : AppTheme.primary.withAlpha((opacity * 255).round()),
                            width: 3,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Scanning HUD overlay silhouette
                Icon(
                  Icons.face_unlock_rounded,
                  size: 140,
                  color: _statusSuccess == true
                      ? const Color(0xFF00D1B2).withAlpha(150)
                      : AppTheme.primary.withAlpha(130),
                ),

                // Simulated holographic laser line scan
                AnimatedBuilder(
                  animation: _scanController,
                  builder: (context, child) {
                    final topOffset = 60.0 + (_scanController.value * 200.0);
                    return Positioned(
                      top: topOffset,
                      left: 40,
                      right: 40,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: _statusSuccess == true
                                  ? const Color(0xFF00D1B2)
                                  : AppTheme.primary,
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                          gradient: LinearGradient(
                            colors: _statusSuccess == true
                                ? [
                                    const Color(0xFF00D1B2).withAlpha(25),
                                    const Color(0xFF00D1B2),
                                    const Color(0xFF00D1B2).withAlpha(25),
                                  ]
                                : [
                                    AppTheme.primary.withAlpha(25),
                                    AppTheme.primary,
                                    AppTheme.primary.withAlpha(25),
                                  ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Web Simulator tag
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.webhook, size: 12, color: Colors.blueAccent),
                        SizedBox(width: 4),
                        Text(
                          'WEB EMULATION',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Progress Bar
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: 6,
                    child: LinearProgressIndicator(
                      value: _simulationProgress,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _statusSuccess == true ? const Color(0xFF00D1B2) : AppTheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
              if (_statusSuccess == null)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.primary,
                  ),
                )
              else
                Icon(
                  _statusSuccess == true
                      ? Icons.check_circle
                      : Icons.error,
                  color: _statusSuccess == true ? const Color(0xFF00D1B2) : const Color(0xFFFF6B6B),
                  size: 20,
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _statusMessage,
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
        if (_statusSuccess == false && _failedAttempts < 3) ...[
          const SizedBox(height: 16),
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
