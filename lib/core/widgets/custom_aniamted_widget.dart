import 'package:flutter/material.dart';

class CustomAnimatedScale extends StatefulWidget {
  const CustomAnimatedScale({
    super.key,
    required this.scale,
    required this.child,
    required this.duration,
  });

  final double scale;
  final Widget child;
  final Duration duration;

  @override
  State<CustomAnimatedScale> createState() => _CustomAnimatedScaleState();
}

class _CustomAnimatedScaleState extends State<CustomAnimatedScale>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween(begin: widget.scale, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}
