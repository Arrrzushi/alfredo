import 'dart:async';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isStreaming = false;
  Timer? _frameTimer;
  Function(String imagePath)? _onFrameCaptured;

  bool get isInitialized => _isInitialized;
  bool get isStreaming => _isStreaming;
  CameraController? get controller => _controller;

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    // Request camera permission
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      return false;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        return false;
      }

      _controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();
      _isInitialized = true;
      
      // Verify controller is actually initialized
      if (_controller != null && _controller!.value.isInitialized) {
        return true;
      } else {
        _isInitialized = false;
        return false;
      }
    } catch (e) {
      _isInitialized = false;
      return false;
    }
  }

  void startFrameStream(int intervalSeconds, Function(String imagePath) onFrame) {
    if (!_isInitialized || _controller == null) return;
    if (_isStreaming) stopFrameStream();

    _onFrameCaptured = onFrame;
    _isStreaming = true;

    _frameTimer = Timer.periodic(
      Duration(seconds: intervalSeconds),
      (_) => _captureFrame(),
    );

    // Capture initial frame
    _captureFrame();
  }

  void stopFrameStream() {
    _frameTimer?.cancel();
    _frameTimer = null;
    _isStreaming = false;
    _onFrameCaptured = null;
  }

  Future<String?> captureFrame() async {
    if (!_isInitialized || _controller == null) return null;
    if (!_controller!.value.isInitialized) return null;

    try {
      final image = await _controller!.takePicture();
      return image.path;
    } catch (e) {
      return null;
    }
  }

  Future<void> _captureFrame() async {
    if (!_isStreaming) return;
    final path = await captureFrame();
    if (path != null && _onFrameCaptured != null) {
      _onFrameCaptured!(path);
    }
  }

  Future<void> dispose() async {
    stopFrameStream();
    await _controller?.dispose();
    _controller = null;
    _isInitialized = false;
  }
}


