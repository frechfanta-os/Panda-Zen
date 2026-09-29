import 'package:flutter/material.dart';
import '../../assets/panda_assets.dart';

class PandaReveal extends StatefulWidget {
  final double size;

  const PandaReveal({super.key, required this.size});

  @override
  State<PandaReveal> createState() => _PandaRevealState();
}

class _PandaRevealState extends State<PandaReveal> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.2, end: 1.15), weight: 65),
      TweenSequenceItem(tween: Tween<double>(begin: 1.15, end: 1.0), weight: 35),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

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
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: Center(
        child: Image.asset(
          PandaAssets.happyWave,
          width: widget.size * 0.85,
          height: widget.size * 0.85,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
