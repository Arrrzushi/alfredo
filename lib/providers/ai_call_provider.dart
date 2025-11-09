import 'package:flutter/foundation.dart';
import '../models/ai_call_state.dart';
import '../services/ai_call_service.dart';
import '../services/camera_service.dart';
import '../services/ml_kit_service.dart';
import 'dart:async';

class AiCallProvider extends ChangeNotifier {
  final AiCallService _aiService = AiCallService();
  final CameraService _cameraService = CameraService();
  final MlKitService _mlKitService = MlKitService();

  AiCallState _state = AiCallState();
  String _alfredoResponse = '';
  bool _isListening = false;
  bool _isProcessing = false;
  bool _isStreaming = false;
  String? _lastFramePath;
  Map<String, dynamic>? _lastMlKitData;

  // Getters
  AiCallState get state => _state;
  String get alfredoResponse => _alfredoResponse;
  bool get isListening => _isListening;
  bool get isProcessing => _isProcessing;
  bool get isStreaming => _isStreaming;
  CameraService get cameraService => _cameraService;

  AiCallProvider() {
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    final cameraInitialized = await _cameraService.initialize();
    await _mlKitService.initialize();
    
    // Notify listeners when camera is ready
    if (cameraInitialized) {
      // Add a small delay to ensure controller is fully ready
      await Future.delayed(const Duration(milliseconds: 100));
      notifyListeners();
    }
  }

  /// Process user utterance
  Future<void> processUserUtterance(String utterance) async {
    if (_isProcessing) return;

    _isProcessing = true;
    notifyListeners();

    try {
      // Get latest frame and ML Kit data if available
      final framePath = _lastFramePath;
      final mlKitData = _lastMlKitData;

      // Call AI service
      final response = await _aiService.processUserInput(
        utterance: utterance,
        frameImagePath: framePath,
        mlKitData: mlKitData,
        currentState: _state,
      );

      // Update response text
      _alfredoResponse = response.text;

      // Execute tool calls if any
      if (response.toolCalls != null && response.toolCalls!.isNotEmpty) {
        for (final toolCall in response.toolCalls!) {
          await _executeToolCall(toolCall);
        }
      }

      // Update state if provided
      if (response.state != null) {
        _state = response.state!;
      }

      notifyListeners();
    } catch (e) {
      _alfredoResponse = "I encountered an error: $e";
      notifyListeners();
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Execute a tool call
  Future<void> _executeToolCall(ToolCall toolCall) async {
    final result = await _aiService.executeToolCall(toolCall);

    switch (toolCall.name) {
      case 'start_frame_stream':
        if (result['success'] == true) {
          final interval = toolCall.args['interval_sec'] as int? ?? 5;
          _startFrameStream(interval);
        }
        break;

      case 'stop_frame_stream':
        if (result['success'] == true) {
          _stopFrameStream();
        }
        break;

      case 'request_frame':
        await _captureAndProcessFrame(toolCall.args['note'] as String?);
        break;

      case 'set_timer':
        if (result['success'] == true && result['timer'] != null) {
          final timerData = result['timer'] as Map<String, dynamic>;
          _addTimer(TimerInfo.fromJson(timerData));
        }
        break;

      case 'advance_step':
        if (result['success'] == true) {
          final delta = result['step_delta'] as int? ?? 1;
          _advanceStep(delta);
        }
        break;

      case 'generate_recipe':
        if (result['success'] == true && result['recipe'] != null) {
          final recipeData = result['recipe'] as Map<String, dynamic>;
          _updateRecipe(RecipeInfo.fromJson(recipeData));
        }
        break;

      case 'read_pantry':
        // Pantry data is read and available to AI, no UI update needed
        break;

      case 'update_pantry_item':
      case 'add_pantry_item':
      case 'remove_pantry_item':
        // Pantry updated, notify listeners to refresh UI
        notifyListeners();
        break;

      case 'add_to_shopping_list':
        // Shopping list updated, notify listeners
        notifyListeners();
        break;

      case 'nutrition_estimate':
        // Nutrition data available to AI, no UI update needed
        break;

      case 'log_meal':
        // Meal logged, notify listeners
        notifyListeners();
        break;

      case 'summarize_photo':
        // Photo summarized, no UI update needed
        break;
    }
  }

  void _startFrameStream(int intervalSeconds) {
    if (_isStreaming) return;
    if (!_cameraService.isInitialized) {
      // Try to initialize if not already done
      _cameraService.initialize().then((initialized) {
        if (initialized) {
          _cameraService.startFrameStream(intervalSeconds, (imagePath) async {
            await _processFrame(imagePath);
          });
          _isStreaming = true;
          _state = _state.copyWith(notes: 'Streaming frames');
          notifyListeners();
        }
      });
      return;
    }

    _cameraService.startFrameStream(intervalSeconds, (imagePath) async {
      await _processFrame(imagePath);
    });

    _isStreaming = true;
    _state = _state.copyWith(notes: 'Streaming frames');
    notifyListeners();
  }

  void _stopFrameStream() {
    _cameraService.stopFrameStream();
    _isStreaming = false;
    _state = _state.copyWith(notes: 'Streaming paused');
    notifyListeners();
  }

  Future<void> _captureAndProcessFrame(String? note) async {
    final framePath = await _cameraService.captureFrame();
    if (framePath != null) {
      await _processFrame(framePath);
    }
  }

  Future<void> _processFrame(String imagePath) async {
    _lastFramePath = imagePath;

    // Run ML Kit detection on the captured frame
    try {
      final mlKitResult = await _mlKitService.detectObjects(imagePath);
      _lastMlKitData = mlKitResult.toJson();
    } catch (e) {
      // If ML Kit fails, still store the frame path for AI
      _lastMlKitData = {'error': e.toString(), 'objects': [], 'hazards': []};
    }

    notifyListeners();
  }

  void _addTimer(TimerInfo timer) {
    final timers = List<TimerInfo>.from(_state.timers)..add(timer);
    _state = _state.copyWith(timers: timers);
    notifyListeners();
  }

  void _advanceStep(int delta) {
    final newStepIndex = (_state.stepIndex + delta).clamp(0, _state.totalSteps);
    _state = _state.copyWith(stepIndex: newStepIndex);
    notifyListeners();
  }

  void _updateRecipe(RecipeInfo recipe) {
    _state = _state.copyWith(recipe: recipe);
    notifyListeners();
  }

  void setListening(bool listening) {
    _isListening = listening;
    notifyListeners();
  }

  void clearResponse() {
    _alfredoResponse = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _mlKitService.dispose();
    super.dispose();
  }
}




