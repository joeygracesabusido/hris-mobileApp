import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
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

class _FaceCaptureWidgetState extends State<FaceCaptureWidget>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  late FaceDetector _faceDetector;
  Interpreter? _interpreter;
  bool _isInitialized = false;
  bool _isProcessing = false;
  String? _statusMessage;
  bool? _statusSuccess;
  int _failedAttempts = 0;
  bool _disposed = false;
  DateTime _lastFrameTime = DateTime.now();

  // Throttle: process at most one frame every 500ms to reduce load
  static const _frameThrottleMs = 500;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initialize();
    }
  }

  Future<void> _initialize() async {
    if (_disposed) return;

    try {
      final interpreter =
          await Interpreter.fromAsset('ml/mobile_face_net.tflite');
      _interpreter = interpreter;

      _faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          enableClassification: false,
          enableLandmarks: true,
          enableContours: false,
          performanceMode: FaceDetectorMode.fast,
        ),
      );

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
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await _cameraController!.initialize();
      if (!mounted || _disposed) return;

      setState(() => _isInitialized = true);
      _setStatus('Center your face in the frame', null);

      await _startImageStream();
    } catch (e) {
      _setStatus('Initialization error: $e', false);
    }
  }

  Future<void> _startImageStream() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized || _disposed) {
      return;
    }
    // Avoid starting if already streaming
    if (controller.value.isStreamingImages) return;

    _isProcessing = false;
    await controller.startImageStream(_processImage);
  }

  Future<void> _stopImageStream() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;
    if (!controller.value.isStreamingImages) return;

    try {
      await controller.stopImageStream();
    } catch (_) {
      // Ignore — stream may already be stopped
    }
  }

  void _setStatus(String msg, bool? success) {
    if (!mounted || _disposed) return;
    setState(() {
      _statusMessage = msg;
      _statusSuccess = success;
    });
  }

  Future<void> _processImage(CameraImage image) async {
    if (_isProcessing || !mounted || _disposed) return;

    // Throttle frames to avoid overwhelming the CPU
    final now = DateTime.now();
    if (now.difference(_lastFrameTime).inMilliseconds < _frameThrottleMs) {
      return;
    }
    _lastFrameTime = now;

    _isProcessing = true;

    try {
      final inputImage = _buildInputImage(image);
      if (inputImage == null) {
        _isProcessing = false;
        return;
      }

      final faces = await _faceDetector.processImage(inputImage);

      if (!mounted || _disposed) {
        _isProcessing = false;
        return;
      }

      if (faces.isEmpty) {
        _isProcessing = false;
        return;
      }

      // Face detected — stop stream for processing
      await _stopImageStream();

      final face = faces.first;
      final descriptor = _runModel(image, face.boundingBox);
      if (descriptor == null) {
        _setStatus('Failed to generate face descriptor. Try again.', false);
        _isProcessing = false;
        // Restart stream so user can retry
        await _startImageStream();
        return;
      }

      if (widget.mode == FaceCaptureMode.enroll) {
        widget.onCapture?.call(descriptor);
        _setStatus('Face captured successfully!', true);
      } else if (widget.mode == FaceCaptureMode.verify &&
          widget.storedDescriptor != null) {
        final distance =
            _euclideanDistance(descriptor, widget.storedDescriptor!);
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
            _isProcessing = false;
            return;
          }
          // Restart stream for another attempt
          _isProcessing = false;
          await Future.delayed(const Duration(milliseconds: 1500));
          if (!mounted || _disposed) return;
          _setStatus('Try again — center your face in the frame', null);
          await _startImageStream();
          return;
        }
      }
    } catch (e) {
      debugPrint('Capture error: $e');
      _setStatus('Error processing face. Try again.', false);
      // Restart stream on error
      if (mounted && !_disposed) {
        await _startImageStream();
      }
    } finally {
      _isProcessing = false;
    }
  }

  /// Build an InputImage from the camera frame.
  ///
  /// Samsung (and most Android) devices use YUV_420_888 or NV21.
  /// We request NV21 via imageFormatGroup, but some Samsung models still
  /// deliver YUV_420_888 with separate Y / UV planes. This method handles both.
  InputImage? _buildInputImage(CameraImage image) {
    final controller = _cameraController;
    if (controller == null) return null;

    final camera = controller.description;
    final sensorOrientation = camera.sensorOrientation;

    // Determine the correct rotation for ML Kit.
    // On Android the rotation depends on sensor orientation and device orientation.
    InputImageRotation rotation;
    if (Platform.isAndroid) {
      rotation = _rotationFromSensorOrientation(sensorOrientation);
    } else {
      // iOS — sensorOrientation is always 0; rotation comes from device
      rotation = InputImageRotation.rotation0deg;
    }

    // On Android we requested NV21 format. Build the byte buffer.
    if (Platform.isAndroid) {
      // Some Samsung devices still deliver multiple planes (YUV_420_888)
      // even when NV21 is requested. Concatenate into a single NV21 buffer.
      final Uint8List nv21Bytes;

      if (image.planes.length == 1) {
        // Already a single NV21 plane
        nv21Bytes = image.planes[0].bytes;
      } else {
        // Multiple planes — concatenate Y + UV into NV21
        nv21Bytes = _yuv420ToNv21(image);
      }

      final int effectiveBytesPerRow =
          image.planes.length > 1 ? image.width : image.planes[0].bytesPerRow;
      return InputImage.fromBytes(
        bytes: nv21Bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: InputImageFormat.nv21,
          bytesPerRow: effectiveBytesPerRow,
        ),
      );
    } else {
      // iOS — BGRA8888
      return InputImage.fromBytes(
        bytes: image.planes[0].bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: InputImageFormat.bgra8888,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );
    }
  }

  /// Convert YUV_420_888 camera planes into a single NV21 byte array.
  ///
  /// NV21 layout:  [Y plane] [VU interleaved]
  /// The UV plane in YUV_420_888 may have pixelStride=1 (planar) or
  /// pixelStride=2 (semi-planar / already interleaved, common on Samsung).
  Uint8List _yuv420ToNv21(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final int ySize = width * height;
    final int uvSize = width * (height ~/ 2);

    final nv21 = Uint8List(ySize + uvSize);

    // Copy Y plane
    final yPlane = image.planes[0];
    final yRowStride = yPlane.bytesPerRow;

    if (yRowStride == width) {
      // Fast path — no padding
      nv21.setRange(0, ySize, yPlane.bytes);
    } else {
      // Row-by-row copy to skip padding
      int yOffset = 0;
      for (int row = 0; row < height; row++) {
        final int srcOffset = row * yRowStride;
        nv21.setRange(yOffset, yOffset + width,
            yPlane.bytes.buffer.asUint8List(yPlane.bytes.offsetInBytes + srcOffset, width));
        yOffset += width;
      }
    }

    // Copy UV planes into interleaved VU (NV21 order)
    if (image.planes.length >= 3) {
      final uPlane = image.planes[1];
      final vPlane = image.planes[2];
      final int uvPixelStride = uPlane.bytesPerPixel ?? 1;
      final int uvRowStride = uPlane.bytesPerRow;

      int uvOffset = ySize;
      for (int row = 0; row < height ~/ 2; row++) {
        for (int col = 0; col < width ~/ 2; col++) {
          final int uvIndex = row * uvRowStride + col * uvPixelStride;

          if (uvIndex < vPlane.bytes.length && uvIndex < uPlane.bytes.length) {
            // NV21 = V first, then U
            nv21[uvOffset++] = vPlane.bytes[uvIndex];
            nv21[uvOffset++] = uPlane.bytes[uvIndex];
          } else {
            nv21[uvOffset++] = 128;
            nv21[uvOffset++] = 128;
          }
        }
      }
    } else if (image.planes.length == 2) {
      // Some devices give a combined UV plane
      final uvPlane = image.planes[1];
      final int uvLen = min(uvPlane.bytes.length, uvSize);
      nv21.setRange(ySize, ySize + uvLen, uvPlane.bytes);
    }

    return nv21;
  }

  /// Map sensor orientation to ML Kit InputImageRotation for Android.
  InputImageRotation _rotationFromSensorOrientation(int sensorOrientation) {
    switch (sensorOrientation) {
      case 0:
        return InputImageRotation.rotation0deg;
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  List<double>? _runModel(CameraImage image, Rect boundingBox) {
    if (_interpreter == null) return null;

    try {
      final inputShape = _interpreter!.getInputTensor(0).shape;
      final inputSize = inputShape[1];

      final outputShape = _interpreter!.getOutputTensor(0).shape;
      final outputSize = outputShape[1];

      final input = _preprocess(image, boundingBox, inputSize);
      final output = List.filled(outputSize, 0.0).reshape([1, outputSize]);
      _interpreter!.run(input, output);

      return (output[0] as List<dynamic>).cast<double>();
    } catch (e) {
      debugPrint('TFLite error: $e');
      return null;
    }
  }

  /// Convert CameraImage to an img.Image for cropping/resizing.
  ///
  /// Handles both single-plane NV21 (may have stride padding on devices
  /// like Samsung SM-A075F) and multi-plane YUV_420_888.
  img.Image? _cameraImageToImg(CameraImage cameraImage) {
    final width = cameraImage.width;
    final height = cameraImage.height;

    final image = img.Image(width: width, height: height);

    if (Platform.isAndroid) {
      final Uint8List nv21;
      final int yRowStride;

      if (cameraImage.planes.length == 1) {
        nv21 = cameraImage.planes[0].bytes;
        yRowStride = cameraImage.planes[0].bytesPerRow;
      } else {
        nv21 = _yuv420ToNv21(cameraImage);
        yRowStride = width;
      }

      final int frameSize = yRowStride * height;

      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final int yIndex = y * yRowStride + x;
          final int uvIndex =
              frameSize + (y ~/ 2) * yRowStride + (x & ~1);

          if (yIndex >= nv21.length) continue;

          final int yy = nv21[yIndex];
          int v = 128, u = 128;
          if (uvIndex + 1 < nv21.length) {
            v = nv21[uvIndex];
            u = nv21[uvIndex + 1];
          }

          int r = (yy + 1.402 * (v - 128)).round().clamp(0, 255);
          int g = (yy - 0.344 * (u - 128) - 0.714 * (v - 128))
              .round()
              .clamp(0, 255);
          int b = (yy + 1.772 * (u - 128)).round().clamp(0, 255);

          image.setPixelRgb(x, y, r, g, b);
        }
      }
    } else {
      final plane = cameraImage.planes[0];
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final int index = y * plane.bytesPerRow + x * 4;
          if (index + 2 < plane.bytes.length) {
            final b = plane.bytes[index];
            final g = plane.bytes[index + 1];
            final r = plane.bytes[index + 2];
            image.setPixelRgb(x, y, r, g, b);
          }
        }
      }
    }

    return image;
  }

  List<List<List<List<double>>>> _preprocess(
    CameraImage cameraImage,
    Rect boundingBox,
    int inputSize,
  ) {
    final srcImage = _cameraImageToImg(cameraImage);
    if (srcImage == null) {
      return List.generate(
        1,
        (_) => List.generate(
          inputSize,
          (_) => List.generate(inputSize, (_) => List.filled(3, 0.0)),
        ),
      );
    }

    // Add margin around the bounding box for better face capture
    final margin = boundingBox.width * 0.2;
    final cropX =
        (boundingBox.left - margin).toInt().clamp(0, srcImage.width - 1);
    final cropY =
        (boundingBox.top - margin).toInt().clamp(0, srcImage.height - 1);
    final cropW = (boundingBox.width + margin * 2)
        .toInt()
        .clamp(1, srcImage.width - cropX);
    final cropH = (boundingBox.height + margin * 2)
        .toInt()
        .clamp(1, srcImage.height - cropY);

    final cropped = img.copyCrop(srcImage,
        x: cropX, y: cropY, width: cropW, height: cropH);
    final resized = img.resize(cropped, width: inputSize, height: inputSize);

    final input = List.generate(
      1,
      (_) => List.generate(inputSize,
          (_) => List.generate(inputSize, (_) => List.filled(3, 0.0))),
    );

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = resized.getPixel(x, y);
        input[0][y][x][0] = (pixel.r / 127.5) - 1.0;
        input[0][y][x][1] = (pixel.g / 127.5) - 1.0;
        input[0][y][x][2] = (pixel.b / 127.5) - 1.0;
      }
    }

    return input;
  }

  double _euclideanDistance(List<double> a, List<double> b) {
    double sum = 0;
    final len = min(a.length, b.length);
    for (int i = 0; i < len; i++) {
      sum += (a[i] - b[i]) * (a[i] - b[i]);
    }
    return sqrt(sum);
  }

  Future<void> _retry() async {
    _failedAttempts = 0;
    _setStatus('Center your face in the frame', null);
    _isProcessing = false;
    await _startImageStream();
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
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
                border: Border.all(
                    color: AppTheme.primary.withAlpha(80), width: 2),
              ),
              child: _cameraController != null &&
                      _cameraController!.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _cameraController!.value.aspectRatio,
                      child: CameraPreview(_cameraController!),
                    )
                  : Container(
                      height: 300,
                      color: Colors.black,
                      child: const Center(
                        child: Icon(Icons.videocam_off,
                            color: Colors.white54, size: 48),
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
            ),
        ],
      ],
    );
  }
}
