import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedEqualizer extends StatefulWidget {
  final bool isPlaying;
  
  const AnimatedEqualizer({Key? key, this.isPlaying = true}) : super(key: key);

  @override
  State<AnimatedEqualizer> createState() => _AnimatedEqualizerState();
}

class _AnimatedEqualizerState extends State<AnimatedEqualizer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(AnimatedEqualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _AnimatedBar(controller: _controller, heightFactor: 0.8, delay: 0.0),
        const SizedBox(width: 3),
        _AnimatedBar(controller: _controller, heightFactor: 1.0, delay: 0.4),
        const SizedBox(width: 3),
        _AnimatedBar(controller: _controller, heightFactor: 0.6, delay: 0.8),
      ],
    );
  }
}

class _AnimatedBar extends StatelessWidget {
  final AnimationController controller;
  final double heightFactor;
  final double delay;

  const _AnimatedBar({
    required this.controller,
    required this.heightFactor,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // Calculate a pseudo-random looking sine wave
        final t = controller.value * 2 * math.pi;
        final value = (math.sin(t + delay * math.pi) + 1) / 2; // 0.0 to 1.0
        
        return Container(
          width: 4,
          height: 6 + 12 * value * heightFactor,
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      },
    );
  }
}
