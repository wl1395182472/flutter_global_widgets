import 'package:flutter/material.dart';

import 'rabbit_paint.dart';

class Rabbit extends StatefulWidget {
  final double? width;
  final double? height;
  const Rabbit({
    super.key,
    this.width,
    this.height,
  });

  @override
  State<Rabbit> createState() => _RabbitState();
}

class _RabbitState extends State<Rabbit> with TickerProviderStateMixin {
  final animationDurationMap = {
    "border": const Duration(seconds: 10),
    "fillBody": const Duration(seconds: 1),
    "fillRadishLeaf": const Duration(milliseconds: 300),
    "fillRadishBody": const Duration(milliseconds: 600),
    "fillLeftEar": const Duration(milliseconds: 600),
    "fillRightEar": const Duration(milliseconds: 600),
    "fillLeftFace": const Duration(milliseconds: 300),
    "fillRightFace": const Duration(milliseconds: 300),
  };

  final animationControllerMap = <String, AnimationController>{};

  void initAnimation() {
    for (var key in animationDurationMap.keys) {
      if (key == "border") {
        animationControllerMap[key] = AnimationController(
          vsync: this,
          upperBound: 15.0,
        )..duration = animationDurationMap[key];
      } else {
        animationControllerMap[key] = AnimationController(vsync: this)
          ..duration = animationDurationMap[key];
      }
    }

    var animations = animationControllerMap.values.toList();
    for (int i = 0; i < animations.length - 1; i++) {
      var current = animations[i];
      var next = animations[i + 1];
      exec(current, next);
    }
  }

  void exec(AnimationController current, AnimationController next) {
    current.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        next.forward();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    initAnimation();
    animationControllerMap.values.first.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      alignment: Alignment.center,
      child: CustomPaint(
        painter: RabbitPainter(
          controller: Listenable.merge(
            animationControllerMap.values.toList(),
          ),
          animationMap: animationControllerMap,
        ),
        size: Size(
          widget.width ?? 0.0,
          widget.height ?? 0.0,
        ),
      ),
    );
  }
}
