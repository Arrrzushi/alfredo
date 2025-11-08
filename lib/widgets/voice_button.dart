import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'neomorphic_container.dart';

class VoiceButton extends StatefulWidget {
  final bool isListening;
  final VoidCallback onTap;
  final double size;

  const VoiceButton({
    super.key,
    required this.isListening,
    required this.onTap,
    this.size = 80,
  });

  @override
  State<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends State<VoiceButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _tapController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _tapScaleAnimation;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();
    // Pulse animation for listening state
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // Tap animation
    _tapController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _tapScaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeOut),
    );
    
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(VoiceButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening && !oldWidget.isListening) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isListening && oldWidget.isListening) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _tapController.forward().then((_) {
      _tapController.reverse();
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _tapScaleAnimation, _rippleAnimation]),
        builder: (context, child) {
          final scale = widget.isListening 
              ? _scaleAnimation.value * _tapScaleAnimation.value
              : _tapScaleAnimation.value;
          
          return Stack(
            alignment: Alignment.center,
            children: [
              // Ripple effect
              if (_tapController.value > 0)
                Container(
                  width: widget.size * (1 + _rippleAnimation.value * 0.5),
                  height: widget.size * (1 + _rippleAnimation.value * 0.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryOrange.withValues(
                      alpha: 0.3 * (1 - _rippleAnimation.value),
                    ),
                  ),
                ),
              // Main button
              Transform.scale(
                scale: scale,
                child: NeomorphicContainer(
                  width: widget.size,
                  height: widget.size,
                  padding: EdgeInsets.zero,
                  margin: EdgeInsets.zero,
                  borderRadius: BorderRadius.circular(widget.size / 2),
                  color: widget.isListening
                      ? AppTheme.primaryOrange
                      : AppTheme.gray100,
                  child: Icon(
                    widget.isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                    size: widget.size * 0.4,
                    color: widget.isListening ? Colors.white : AppTheme.gray700,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
