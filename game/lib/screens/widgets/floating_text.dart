import 'package:flutter/material.dart';

class FloatingText extends StatefulWidget {
  final String text;
  final Color color;
  final VoidCallback onComplete;

  const FloatingText({
    super.key,
    required this.text,
    required this.color,
    required this.onComplete,
  });

  @override
  State<FloatingText> createState() => _FloatingTextState();
}

class _FloatingTextState extends State<FloatingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0)),
    );

    _offset = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1.5),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offset,
      child: FadeTransition(
        opacity: _opacity,
        child: Text(
          widget.text,
          style: TextStyle(
            color: widget.color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            shadows: const [
              Shadow(blurRadius: 2, color: Colors.black, offset: Offset(1, 1)),
            ],
          ),
        ),
      ),
    );
  }
}
