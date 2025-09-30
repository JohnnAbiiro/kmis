import 'package:flutter/material.dart';

class BouncingImage extends StatefulWidget {
  final Widget child;
  final double maxOffset;
  final Duration duration;

  const BouncingImage({
    super.key,
    required this.child,
    this.maxOffset = 16.0,
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  State<BouncingImage> createState() => _BouncingImageState();
}

class _BouncingImageState extends State<BouncingImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // Up–down tween
    _animation = Tween<double>(begin: 0, end: widget.maxOffset)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_animation.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
