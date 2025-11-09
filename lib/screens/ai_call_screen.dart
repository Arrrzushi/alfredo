import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../theme/app_theme.dart';
import '../widgets/voice_button.dart';
import '../widgets/neomorphic_container.dart';
import '../providers/ai_call_provider.dart';
import '../models/ai_call_state.dart';

class AiCallScreen extends StatefulWidget {
  const AiCallScreen({super.key});

  @override
  State<AiCallScreen> createState() => _AiCallScreenState();
}

class _AiCallScreenState extends State<AiCallScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  String _transcript = '';

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _initializeTts();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final provider = Provider.of<AiCallProvider>(context, listen: false);
    // Auto-start camera when screen loads
    if (!provider.cameraService.isInitialized) {
      final initialized = await provider.cameraService.initialize();
      if (initialized && mounted) {
        // Force UI rebuild to show camera preview
        if (mounted) {
          setState(() {});
        }
      }
    } else if (provider.cameraService.isInitialized && mounted) {
      // Camera already initialized, ensure UI is updated
      if (mounted) {
        setState(() {});
      }
    }

    // Listen to camera controller changes
    final controller = provider.cameraService.controller;
    if (controller != null && mounted) {
      controller.addListener(_onCameraControllerChanged);
    }
  }

  void _onCameraControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _initializeSpeech() async {
    await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          final provider = Provider.of<AiCallProvider>(context, listen: false);
          provider.setListening(false);
        }
      },
      onError: (error) {
        final provider = Provider.of<AiCallProvider>(context, listen: false);
        provider.setListening(false);
      },
    );
  }

  Future<void> _initializeTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  void _startListening() async {
    final provider = Provider.of<AiCallProvider>(context, listen: false);

    if (!provider.isListening) {
      bool available = await _speech.initialize();
      if (available) {
        provider.setListening(true);
        setState(() {
          _transcript = '';
        });

        await _speech.listen(
          onResult: (result) {
            setState(() {
              _transcript = result.recognizedWords;
            });
            if (result.finalResult) {
              _processVoiceCommand(result.recognizedWords);
            }
          },
        );
      }
    } else {
      _stopListening();
    }
  }

  void _stopListening() {
    _speech.stop();
    final provider = Provider.of<AiCallProvider>(context, listen: false);
    provider.setListening(false);
  }

  Future<void> _processVoiceCommand(String command) async {
    final provider = Provider.of<AiCallProvider>(context, listen: false);
    await provider.processUserUtterance(command);

    // Speak the response
    if (provider.alfredoResponse.isNotEmpty) {
      await _tts.speak(provider.alfredoResponse);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Call'),
        elevation: 0,
        actions: [
          Consumer<AiCallProvider>(
            builder: (context, provider, _) {
              return Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      provider.isStreaming
                          ? AppTheme.successGreen
                          : AppTheme.gray600,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      provider.isStreaming ? 'Streaming' : 'Idle',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<AiCallProvider>(
        builder: (context, provider, _) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Camera Preview - Always show, will show placeholder if not initialized
                  _buildCameraPreview(provider),

                  const SizedBox(height: 20),

                  // Current Recipe Info
                  if (provider.state.recipe != null)
                    _buildRecipeInfo(provider.state),

                  const SizedBox(height: 20),

                  // Active Timers
                  if (provider.state.timers.isNotEmpty)
                    _buildTimers(provider.state.timers),

                  const SizedBox(height: 20),

                  // Voice Interface
                  _buildVoiceInterface(provider),

                  const SizedBox(height: 20),

                  // Transcript
                  if (_transcript.isNotEmpty) _buildTranscript(),

                  const SizedBox(height: 20),

                  // Alfredo Response
                  if (provider.alfredoResponse.isNotEmpty)
                    _buildResponse(
                      provider.alfredoResponse,
                      provider.isProcessing,
                    ),

                  const SizedBox(height: 20),

                  // Status Notes
                  if (provider.state.notes.isNotEmpty)
                    _buildStatusNotes(provider.state.notes),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCameraPreview(AiCallProvider provider) {
    final controller = provider.cameraService.controller;

    // Check if camera is initialized
    if (!provider.cameraService.isInitialized || controller == null) {
      return _buildCameraPlaceholder();
    }

    // Use ValueListenableBuilder to react to controller state changes
    return ValueListenableBuilder<CameraValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        // Show placeholder while initializing
        if (!value.isInitialized) {
          return _buildCameraPlaceholder();
        }

        // Show camera preview when initialized
        return NeomorphicContainer(
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: CameraPreview(controller),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCameraPlaceholder() {
    return NeomorphicContainer(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.videocam_off_rounded, size: 48, color: AppTheme.gray600),
          const SizedBox(height: 12),
          Text(
            'Camera not available',
            style: TextStyle(color: AppTheme.gray600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeInfo(AiCallState state) {
    if (state.recipe == null) return const SizedBox.shrink();

    return NeomorphicContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.restaurant_menu_rounded,
                color: AppTheme.primaryOrange,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.recipe!.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Servings: ${state.recipe!.servings}',
            style: TextStyle(color: AppTheme.gray600, fontSize: 14),
          ),
          if (state.totalSteps > 0)
            Text(
              'Step ${state.stepIndex + 1} of ${state.totalSteps}',
              style: TextStyle(color: AppTheme.gray600, fontSize: 14),
            ),
        ],
      ),
    );
  }

  Widget _buildTimers(List<TimerInfo> timers) {
    return NeomorphicContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timer_rounded, color: AppTheme.primaryOrange),
              const SizedBox(width: 8),
              const Text(
                'Active Timers',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...timers.map((timer) => _buildTimerItem(timer)),
        ],
      ),
    );
  }

  Widget _buildTimerItem(TimerInfo timer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(timer.label, style: const TextStyle(fontSize: 14)),
          ),
          Text(
            _formatTimer(timer.seconds),
            style: TextStyle(
              color: AppTheme.primaryOrange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimer(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Widget _buildVoiceInterface(AiCallProvider provider) {
    return Column(
      children: [
        VoiceButton(
          isListening: provider.isListening,
          onTap: _startListening,
          size: 100,
        ),
        const SizedBox(height: 16),
        Text(
          provider.isListening
              ? 'Listening...'
              : provider.isProcessing
              ? 'Processing...'
              : 'Tap to talk to Alfredo',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget _buildTranscript() {
    return NeomorphicContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.mic_rounded, color: AppTheme.primaryOrange, size: 20),
              const SizedBox(width: 8),
              const Text(
                'You said:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _transcript,
            style: TextStyle(color: AppTheme.gray700, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildResponse(String response, bool isProcessing) {
    return NeomorphicContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.smart_toy_rounded,
                color: AppTheme.primaryOrange,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Alfredo:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (isProcessing)
            const CircularProgressIndicator()
          else
            Text(
              response,
              style: TextStyle(
                color: AppTheme.gray700,
                fontSize: 14,
                height: 1.5,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusNotes(String notes) {
    return NeomorphicContainer(
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppTheme.gray600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              notes,
              style: TextStyle(color: AppTheme.gray600, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _speech.cancel();
    _tts.stop();
    super.dispose();
  }
}
