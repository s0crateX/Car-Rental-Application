import 'package:flutter/material.dart';

class BlinkingStatusIndicator extends StatefulWidget {
  final bool isAvailable;
  final double size;

  const BlinkingStatusIndicator({
    Key? key,
    required this.isAvailable,
    this.size = 6,
  }) : super(key: key);

  @override
  State<BlinkingStatusIndicator> createState() =>
      _BlinkingStatusIndicatorState();
}

class _BlinkingStatusIndicatorState extends State<BlinkingStatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // Smoother opacity animation with custom curve
    _opacityAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Subtle scale animation for breathing effect
    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.isAvailable ? Colors.green : Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (widget.isAvailable ? Colors.green : Colors.red)
                        .withOpacity(0.4 * _opacityAnimation.value),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
