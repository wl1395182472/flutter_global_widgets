import 'package:flutter/material.dart';

class Button3D extends StatefulWidget {
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final double? radius;
  final Color? color;
  final Widget? child;

  const Button3D({
    super.key,
    this.onPressed,
    this.width,
    this.height,
    this.radius,
    this.color,
    this.child,
  });

  @override
  State<Button3D> createState() => _Button3DState();
}

class _Button3DState extends State<Button3D> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _pressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _pressed = false;
        });
        if (widget.onPressed != null) {
          widget.onPressed!();
        }
      },
      onTapCancel: () {
        setState(() {
          _pressed = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius ?? 20.0),
          boxShadow: [
            if (!_pressed)
              const BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.15),
                offset: Offset(5.0, 5.0),
                blurRadius: 10.0,
              ),
            if (!_pressed)
              const BoxShadow(
                color: Color.fromRGBO(255, 255, 255, 0.55),
                offset: Offset(-5.0, -5.0),
                blurRadius: 10.0,
              ),
          ],
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          margin: EdgeInsets.all(_pressed ? 5.0 : 2.0),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(widget.radius ?? 20.0),
            boxShadow: [
              BoxShadow(
                color: const Color.fromRGBO(255, 255, 255, 0.75),
                offset: Offset(
                  _pressed ? -1.0 : -3.0,
                  _pressed ? -1.0 : -3.0,
                ),
                blurRadius: 10.0,
                spreadRadius: 1.0,
                blurStyle: BlurStyle.inner,
              ),
              const BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.2),
                offset: Offset(1.0, 1.0),
                blurRadius: 10.0,
                spreadRadius: 1.0,
                blurStyle: BlurStyle.inner,
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
