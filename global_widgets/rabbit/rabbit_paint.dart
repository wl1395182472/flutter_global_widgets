import 'dart:math';

import 'package:background_manager_system/src/global_widgets/rabbit/path_ext.dart';
import 'package:background_manager_system/src/global_widgets/rabbit/rect_ext.dart';
import 'package:flutter/material.dart';

class RabbitPainter extends CustomPainter {
  final Listenable controller;
  final Animation bodyAnimation;
  final Animation fillAnimation;
  final Animation fillRadishHeaderAnimation;
  final Animation fillRadishBodyAnimation;
  final Animation fillLeftEarAnimation;
  final Animation fillRightEarAnimation;
  final Animation fillLeftFaceAnimation;
  final Animation fillRightFaceAnimation;

  RabbitPainter({required this.controller, required animationMap})
      : bodyAnimation = animationMap["border"],
        fillAnimation = animationMap["fillBody"],
        fillRadishHeaderAnimation = animationMap["fillRadishLeaf"],
        fillRadishBodyAnimation = animationMap["fillRadishBody"],
        fillLeftEarAnimation = animationMap["fillLeftEar"],
        fillRightEarAnimation = animationMap["fillRightEar"],
        fillLeftFaceAnimation = animationMap["fillLeftFace"],
        fillRightFaceAnimation = animationMap["fillRightFace"],
        super(repaint: controller);

  late final Paint _paint = Paint()
    ..isAntiAlias = true
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) async {
    _paint.color = const Color(0xFFFFE4B5);
    _paint.style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _paint);

    /// 左边身体 path
    var leftBodyPoints = createLeftBodyPoints(size);
    var leftBodyPath = createThreePath(leftBodyPoints);

    /// 右边身体 path
    var matrix4 = Matrix4.translationValues(size.width - 20.0, 0, 0);
    matrix4.rotateY(2 * pi / 2);
    var rightBodyPath = leftBodyPath.transform(matrix4.storage);

    /// 耳朵 path
    var leftFirstPosition = leftBodyPath.getPositionFromPercent(0);
    var rightFirstPosition = rightBodyPath.getPositionFromPercent(0);
    Path earPath = createEarPath(leftFirstPosition, rightFirstPosition);

    /// 左边手脚 path
    var leftHandsFeetPoints = createLeftHandsFeetPoints(leftBodyPoints);
    var leftHandsFeetPath = createThreePath(leftHandsFeetPoints);

    /// 右边手脚 path
    var rightHandsFeetPoints =
        createRightHandsFeetPoints(leftBodyPoints, rightBodyPath);
    var rightHandsFeetPath = createThreePath(rightHandsFeetPoints);

    /// 胡萝卜叶 path
    Path radishLeafPath =
        createRadishLeafPath(leftHandsFeetPoints, rightFirstPosition);

    /// 嘴 path
    var mouthPoints = createMouthPoints(radishLeafPath);
    var mouthPath = createThreePath(mouthPoints);

    /// 左眼 path
    Path leftEyesPath = createLeftEyesPath(leftBodyPoints);

    /// 右眼 path
    Path rightEyesPath = createRightEyesPath(rightFirstPosition);

    /// 尾巴 path
    var tailPath = createTailPath(rightBodyPath);

    /// 胡萝卜顶端 path
    Path radishTopPath = createRadishTopPath(
        leftHandsFeetPath, radishLeafPath, rightHandsFeetPath);

    /// 胡萝卜底部 path
    Path radishBottomPath =
        createRadishBottomPath(leftHandsFeetPath, rightHandsFeetPath);

    /// 胡萝卜内部1 path
    Path radishBodyPath1 = createRadishBodyPath1(leftHandsFeetPath);

    /// 胡萝卜内部2 path
    Path radishBodyPath2 = createRadishBodyPath2(rightHandsFeetPath);

    /// 胡萝卜内部3 path
    Path radishBodyPath3 = createRadishBodyPath3(rightHandsFeetPath);

    /// 合成完整兔子形状的 path
    Path bodyBorderPath = createBodyBorderPath(
        earPath,
        rightBodyPath,
        rightHandsFeetPath,
        radishBottomPath,
        leftHandsFeetPath,
        leftBodyPath,
        tailPath);

    _paint.style = PaintingStyle.fill;
    _paint.color = Colors.white;

    /// 绘制整体白色填充
    canvas.save();
    canvas.clipPath(bodyBorderPath);
    var bodyRect = bodyBorderPath.getBounds();
    canvas.drawRect(
        bodyRect.clone(height: bodyRect.height * fillAnimation.value), _paint);
    canvas.restore();

    _paint.color = const Color(0xFFE79EC3);

    /// 绘制左脸腮红
    drawLeftFaceFill(canvas, leftBodyPoints.first);

    /// 绘制右脸腮红
    drawRightFaceFill(canvas, rightFirstPosition);

    /// 绘制左耳填充
    drawLeftEarFill(canvas, leftFirstPosition);

    /// 绘制右耳填充
    drawRightEarFill(canvas, rightFirstPosition);

    _paint.style = PaintingStyle.fill;
    _paint.color = Colors.green;

    /// 绘制萝卜叶填充
    drawRadishLeafFill(canvas, radishLeafPath);

    /// 创建萝卜填充的path
    Path radishBorderPath = createRadishBorderPath(
        radishTopPath, rightHandsFeetPath, radishBottomPath, leftHandsFeetPath);
    _paint.style = PaintingStyle.fill;
    _paint.color = Colors.orange;

    /// 绘制萝卜填充
    canvas.save();
    var radishRect = radishBorderPath.getBounds();
    canvas.clipPath(radishBorderPath);
    canvas.drawRect(
        radishRect.clone(
            height: radishRect.height * fillRadishBodyAnimation.value),
        _paint);
    canvas.restore();

    _paint.color = Colors.black87;
    _paint.style = PaintingStyle.stroke;
    _paint.strokeWidth = 4.0;

    /// 将所有线条path放入集合进行统一绘制
    var list = [
      leftBodyPath,
      rightBodyPath,
      earPath,
      leftHandsFeetPath,
      rightHandsFeetPath,
      radishLeafPath,
      mouthPath,
      leftEyesPath,
      rightEyesPath,
      radishTopPath,
      radishBottomPath,
      radishBodyPath1,
      radishBodyPath2,
      radishBodyPath3,
      tailPath,
    ];

    /// 绘制所有边框
    drawBorder(canvas, list);
  }

  ///绘制整体边框动画
  void drawBorder(Canvas canvas, List<Path> list) {
    int index = (bodyAnimation.value as double) ~/ 1;
    double progress = bodyAnimation.value % 1;
    for (int i = 0; i < index; i++) {
      var path = list[i];
      canvas.drawPath(path, _paint);
    }
    if (index >= list.length) {
      return;
    }
    var path = list[index];
    var pms = path.computeMetrics();
    var pm = pms.first;
    canvas.drawPath(pm.extractPath(0, progress * pm.length), _paint);
  }

  /// 创建胡萝卜填充的path
  Path createRadishBorderPath(Path radishTopPath, Path rightHandsFeetPath,
      Path radishBottomPath, Path leftHandsFeetPath) {
    Path radishPath = Path();
    var radishFistPosition = radishTopPath.getPositionFromPercent(0);
    radishPath
      ..moveTo(radishFistPosition.dx, radishFistPosition.dy)
      ..addPointsFromPath(radishTopPath)
      ..addPointsFromPath(rightHandsFeetPath)
      ..addPointsFromPath(radishBottomPath, isReverse: true)
      ..addPointsFromPath(leftHandsFeetPath, isReverse: true)
      ..close();
    return radishPath;
  }

  /// 创建兔子填充的path
  Path createBodyBorderPath(
      Path earPath,
      Path rightBodyPath,
      Path rightHandsFeetPath,
      Path radishBottomPath,
      Path leftHandsFeetPath,
      Path leftBodyPath,
      Path tailPath) {
    var whitePath = Path();
    var earFirstPosition = earPath.getPositionFromPercent(0);
    whitePath
      ..moveTo(earFirstPosition.dx, earFirstPosition.dy)
      ..addPointsFromPath(earPath)
      ..addPointsFromPath(rightBodyPath)
      ..addPointsFromPath(rightHandsFeetPath.getPathFromPercent(0.9, 1),
          isReverse: true)
      ..addPointsFromPath(radishBottomPath, isReverse: true)
      ..addPointsFromPath(leftHandsFeetPath.getPathFromPercent(0.9, 1))
      ..addPointsFromPath(leftBodyPath, isReverse: true)
      ..addPath(tailPath, Offset.zero)
      ..close();
    return whitePath;
  }

  /// 创建右眼path
  Path createRightEyesPath(Offset rightFirstPosition) {
    var point1 =
        Offset(rightFirstPosition.dx - 15.0, rightFirstPosition.dy + 50.0);
    var point2 = Offset(point1.dx + 10.0, point1.dy - 13.0);
    var point3 = Offset(point1.dx + 20.0, point1.dy);

    Path rightEyesPath = Path();
    rightEyesPath.moveToPoint(point1);
    rightEyesPath.quadraticBezierToPoints([point2, point3]);
    return rightEyesPath;
  }

  /// 创建左眼path
  Path createLeftEyesPath(List<Offset> leftBodyPoints) {
    var point1 =
        Offset(leftBodyPoints.first.dx - 5.0, leftBodyPoints.first.dy + 50.0);
    var point2 = Offset(point1.dx + 10.0, point1.dy - 13.0);
    var point3 = Offset(point1.dx + 20.0, point1.dy);

    Path leftEyesPath = Path();
    leftEyesPath.moveToPoint(point1);
    leftEyesPath.quadraticBezierToPoints([point2, point3]);
    return leftEyesPath;
  }

  /// 创建胡萝卜叶的path
  Path createRadishLeafPath(
      List<Offset> leftHandsFeetPoints, Offset rightFirstPosition) {
    var point1 = Offset(leftHandsFeetPoints.first.dx + 20.0,
        leftHandsFeetPoints.first.dy - 5.0);
    var point2 = Offset(leftHandsFeetPoints.first.dx - 5.0,
        leftHandsFeetPoints.first.dy - 45.0);
    var point3 = Offset(leftHandsFeetPoints.first.dx + 45.0,
        leftHandsFeetPoints.first.dy - 45.0);
    var point4 = Offset(leftHandsFeetPoints.first.dx + 35.0,
        leftHandsFeetPoints.first.dy - 10.0);
    var point5 = Offset(leftHandsFeetPoints.first.dx + 40.0,
        leftHandsFeetPoints.first.dy - 35.0);
    var point6 = Offset(
        rightFirstPosition.dx + 0.0, leftHandsFeetPoints.first.dy - 35.0);
    var point7 = Offset(leftHandsFeetPoints.first.dx + 50.0,
        leftHandsFeetPoints.first.dy - 5.0);

    var points = [point1, point2, point3, point4, point5, point6, point7];
    Path radishLeafPath = createThreePath(points);
    return radishLeafPath;
  }

  /// 创建耳朵path
  Path createEarPath(Offset leftFirstPosition, Offset rightFirstPosition) {
    var centerWidth = rightFirstPosition.dx - leftFirstPosition.dx;

    var position1 = Offset(leftFirstPosition.dx, leftFirstPosition.dy);
    var position2 = Offset(leftFirstPosition.dx - 50.0, -20.0);
    var position3 = Offset(leftFirstPosition.dx + centerWidth / 2, -20.0);
    var position4 =
        Offset(leftFirstPosition.dx + centerWidth / 2, leftFirstPosition.dy);
    var position5 = Offset(leftFirstPosition.dx + centerWidth / 2 + 5.0, -12.0);
    var position6 = Offset(rightFirstPosition.dx + 55.0, -12.0);
    var position7 = Offset(rightFirstPosition.dx, rightFirstPosition.dy);

    var points = [
      position1,
      position2,
      position3,
      position4,
      position5,
      position6,
      position7
    ];

    var earPath = createThreePath(points);
    return earPath;
  }

  /// 创建胡萝卜身体上第三条线 path
  Path createRadishBodyPath3(Path rightHandsFeetPath) {
    var radishBodyPath3 = Path();
    var radishBodyPosition7 = rightHandsFeetPath.getPositionFromPercent(0.78);
    var radishBodyPosition8 =
        Offset(radishBodyPosition7.dx - 3.0, radishBodyPosition7.dy - 3.0);
    var radishBodyPosition9 =
        Offset(radishBodyPosition8.dx - 5.0, radishBodyPosition8.dy + 3.0);
    radishBodyPath3.moveToPoint(radishBodyPosition7);
    radishBodyPath3
        .quadraticBezierToPoints([radishBodyPosition8, radishBodyPosition9]);
    return radishBodyPath3;
  }

  /// 创建胡萝卜身体上第二条线 path
  Path createRadishBodyPath2(Path rightHandsFeetPath) {
    var radishBodyPath2 = Path();
    var radishBodyPosition4 = rightHandsFeetPath.getPositionFromPercent(0.7);
    var radishBodyPosition5 =
        Offset(radishBodyPosition4.dx - 5.0, radishBodyPosition4.dy - 3.0);
    var radishBodyPosition6 =
        Offset(radishBodyPosition5.dx - 10.0, radishBodyPosition5.dy + 3.0);
    radishBodyPath2.moveToPoint(radishBodyPosition4);
    radishBodyPath2
        .quadraticBezierToPoints([radishBodyPosition5, radishBodyPosition6]);
    return radishBodyPath2;
  }

  /// 创建胡萝卜身体上第一条线 path
  Path createRadishBodyPath1(Path leftHandsFeetPath) {
    var radishBodyPath1 = Path();
    var radishBodyPosition1 = leftHandsFeetPath.getPositionFromPercent(0.3);
    var radishBodyPosition2 =
        Offset(radishBodyPosition1.dx + 5.0, radishBodyPosition1.dy - 3.0);
    var radishBodyPosition3 =
        Offset(radishBodyPosition2.dx + 10.0, radishBodyPosition1.dy + 3.0);
    radishBodyPath1.moveToPoint(radishBodyPosition1);
    radishBodyPath1
        .quadraticBezierToPoints([radishBodyPosition2, radishBodyPosition3]);
    return radishBodyPath1;
  }

  /// 胡萝卜底部线条path
  Path createRadishBottomPath(Path leftHandsFeetPath, Path rightHandsFeetPath) {
    var radishBottomPath = Path();
    var radishBottomPosition1 = leftHandsFeetPath.getPositionFromPercent(0.9);
    var radishBottomPosition2 = Offset(
        radishBottomPosition1.dx + 18.0, radishBottomPosition1.dy + 40.0);
    var radishBottomPosition3 = rightHandsFeetPath.getPositionFromPercent(0.9);
    radishBottomPath.moveToPoint(radishBottomPosition1);
    radishBottomPath.quadraticBezierToPoints(
        [radishBottomPosition2, radishBottomPosition3]);

    return radishBottomPath;
  }

  /// 胡萝卜顶部线条path
  Path createRadishTopPath(
      Path leftHandsFeetPath, Path radishLeafPath, Path rightHandsFeetPath) {
    var radishTopPath = Path();
    var radishTopPosition1 = leftHandsFeetPath.getPositionFromPercent(0.07);
    var radishTopPosition2 =
        radishLeafPath.getPositionFromPercent(0).translate(0, -6.0);
    var radishTopPosition3 =
        radishLeafPath.getPositionFromPercent(1).translate(0, -9.0);
    var radishTopPosition4 = rightHandsFeetPath.getPositionFromPercent(0.07);
    radishTopPath.moveToPoint(radishTopPosition1);
    radishTopPath.cubicToPoints(
        [radishTopPosition2, radishTopPosition3, radishTopPosition4]);
    return radishTopPath;
  }

  /// 绘制萝卜叶填充
  void drawRadishLeafFill(Canvas canvas, Path radishHeadPath) {
    canvas.save();
    var radishLeafRect = radishHeadPath.getBounds();
    canvas.clipPath(radishHeadPath);
    canvas.drawRect(
        Rect.fromLTWH(
            radishLeafRect.left,
            radishLeafRect.top,
            radishLeafRect.width,
            radishLeafRect.height * fillRadishHeaderAnimation.value),
        _paint);
    canvas.restore();
  }

  /// 绘制右耳填充
  void drawRightEarFill(Canvas canvas, Offset rightFirstPosition) {
    canvas.save();
    var rightEarRect = Rect.fromLTWH(
      rightFirstPosition.dx - 23.0,
      25.0,
      30.0,
      (rightFirstPosition.dy - 30.0),
    );
    canvas.translate(rightEarRect.center.dx, rightEarRect.center.dy);

    Path rightEarPath = Path();
    rightEarPath.addOval(Rect.fromLTWH(-rightEarRect.width / 2,
        -rightEarRect.height / 2, rightEarRect.width, rightEarRect.height));
    rightEarPath = rightEarPath.transform(Matrix4.rotationZ(pi / 10).storage);

    var rightEarDrawRect = rightEarPath.getBounds();
    canvas.clipPath(rightEarPath);
    canvas.drawRect(
        rightEarDrawRect.clone(
            height: rightEarDrawRect.height * fillRightEarAnimation.value),
        _paint);

    canvas.restore();
  }

  /// 绘制左耳填充
  void drawLeftEarFill(Canvas canvas, Offset leftFirstPosition) {
    canvas.save();

    var leftEarRect = Rect.fromLTWH(
        leftFirstPosition.dx - 3.0, 25.0, 30.0, (leftFirstPosition.dy - 30.0));
    canvas.translate(leftEarRect.center.dx, leftEarRect.center.dy);
    Path leftEarPath = Path();
    leftEarPath.addOval(Rect.fromLTWH(-leftEarRect.width / 2,
        -leftEarRect.height / 2, leftEarRect.width, leftEarRect.height));

    var newPath = leftEarPath.transform(Matrix4.rotationZ(-pi / 15).storage);
    canvas.clipPath(newPath);
    var leftEarDrawRect = newPath.getBounds();
    canvas.drawRect(
        leftEarDrawRect.clone(
            height: leftEarDrawRect.height * fillLeftEarAnimation.value),
        _paint);
    canvas.restore();
  }

  /// 绘制右脸腮红
  void drawRightFaceFill(Canvas canvas, Offset rightFirstPosition) {
    canvas.save();

    Path rightFacePath = Path();
    Rect rightFaceRect = Rect.fromLTWH(rightFirstPosition.dx + 25.0 - 15.0,
        rightFirstPosition.dy + 80.0 - 15.0, 30.0, 30.0);
    rightFacePath.addOval(rightFaceRect);
    canvas.clipPath(rightFacePath);
    canvas.drawRect(
        rightFaceRect.clone(
            height: rightFaceRect.height * fillRightFaceAnimation.value),
        _paint);
    canvas.restore();
  }

  /// 绘制左脸腮红
  void drawLeftFaceFill(Canvas canvas, Offset position1) {
    canvas.save();

    Path leftFacePath = Path();
    Rect leftFaceRect = Rect.fromLTWH(
        position1.dx - 25.0 - 15.0, position1.dy + 80.0 - 15.0, 30.0, 30.0);
    leftFacePath.addOval(leftFaceRect);
    canvas.clipPath(leftFacePath);
    canvas.drawRect(
        leftFaceRect.clone(
            height: leftFaceRect.height * fillLeftFaceAnimation.value),
        _paint);
    canvas.restore();
  }

  /// 创建左边3形状的贝塞尔曲线的点
  List<Offset> createLeftBodyPoints(Size size) {
    var position1 = Offset(size.width / 3, 100.0);
    var position2 = Offset(size.width / 3 - 80.0, position1.dy + 20.0);
    var position3 = Offset(size.width / 3 - 70.0, position2.dy + 100.0);
    var position4 = Offset(size.width / 3, position3.dy + 10.0);
    var position5 = Offset(size.width / 3 - 60.0, position4.dy + 20.0);
    var position6 = Offset(size.width / 3 - 50.0, position5.dy + 80.0);
    var position7 = Offset(size.width / 3 + 15.0, position6.dy + 10.0);

    return [
      position1,
      position2,
      position3,
      position4,
      position5,
      position6,
      position7
    ];
  }

  /// 创建左边手脚3形状的贝塞尔曲线的点
  List<Offset> createLeftHandsFeetPoints(List<Offset> leftBodyPoints) {
    var handsFeetPosition1 =
        Offset(leftBodyPoints[3].dx + 10.0, leftBodyPoints[3].dy + 10.0);
    var handsFeetPosition2 =
        Offset(handsFeetPosition1.dx + 20.0, handsFeetPosition1.dy + 5.0);
    var handsFeetPosition3 =
        Offset(handsFeetPosition2.dx + 20.0, handsFeetPosition2.dy + 40.0);
    var handsFeetPosition4 =
        Offset(handsFeetPosition1.dx, handsFeetPosition3.dy + 15.0);

    var handsFeetPosition5 =
        Offset(handsFeetPosition4.dx + 20.0, handsFeetPosition4.dy + 10.0);
    var handsFeetPosition6 =
        Offset(handsFeetPosition5.dx + 10.0, handsFeetPosition5.dy + 20.0);
    var handsFeetPosition7 =
        Offset(leftBodyPoints.last.dx, leftBodyPoints.last.dy);
    return [
      handsFeetPosition1,
      handsFeetPosition2,
      handsFeetPosition3,
      handsFeetPosition4,
      handsFeetPosition5,
      handsFeetPosition6,
      handsFeetPosition7,
    ];
  }

  /// 绘制右边手脚贝塞尔曲线的点
  List<Offset> createRightHandsFeetPoints(
      List<Offset> leftBodyPoints, Path rightPath) {
    var rightHandsFeetPosition1 =
        Offset(leftBodyPoints[3].dx + 80.0, leftBodyPoints[3].dy + 15.0);
    var rightHandsFeetPosition2 = Offset(
        rightHandsFeetPosition1.dx - 20.0, rightHandsFeetPosition1.dy + 5.0);
    var rightHandsFeetPosition3 = Offset(
        rightHandsFeetPosition2.dx - 15.0, rightHandsFeetPosition2.dy + 30.0);
    var rightHandsFeetPosition4 = Offset(
        rightHandsFeetPosition1.dx - 15.0, rightHandsFeetPosition3.dy + 15.0);

    var rightHandsFeetPosition5 = Offset(
        rightHandsFeetPosition4.dx - 15.0, rightHandsFeetPosition4.dy + 10.0);
    var rightHandsFeetPosition6 = Offset(
        rightHandsFeetPosition5.dx - 5.0, rightHandsFeetPosition5.dy + 20.0);

    var rightLastPosition = rightPath.getPositionFromPercent(1);
    var rightHandsFeetPosition7 =
        Offset(rightLastPosition.dx, rightLastPosition.dy);
    return [
      rightHandsFeetPosition1,
      rightHandsFeetPosition2,
      rightHandsFeetPosition3,
      rightHandsFeetPosition4,
      rightHandsFeetPosition5,
      rightHandsFeetPosition6,
      rightHandsFeetPosition7,
    ];
  }

  /// 创建嘴的贝塞尔曲线的点
  List<Offset> createMouthPoints(Path radishLeafPath) {
    var radishHeadMinYPosition = radishLeafPath.getMinYPosition();
    var mouthPosition1 = Offset(
        radishHeadMinYPosition.dx - 10.0, radishHeadMinYPosition.dy - 20.0);
    var mouthPosition2 =
        Offset(mouthPosition1.dx - 2.0, mouthPosition1.dy + 10.0);
    var mouthPosition3 =
        Offset(mouthPosition2.dx + 18.0, mouthPosition2.dy + 5.0);
    var mouthPosition4 =
        Offset(mouthPosition3.dx + 2.0, mouthPosition1.dy + 2.0);

    var mouthPosition5 = Offset(mouthPosition4.dx, mouthPosition4.dy + 10.0);
    var mouthPosition6 =
        Offset(mouthPosition5.dx + 18.0, mouthPosition5.dy + 2.0);
    var mouthPosition7 = Offset(mouthPosition6.dx + 2.0, mouthPosition1.dy);
    return [
      mouthPosition1,
      mouthPosition2,
      mouthPosition3,
      mouthPosition4,
      mouthPosition5,
      mouthPosition6,
      mouthPosition7,
    ];
  }

  /// 创建尾巴的点
  Path createTailPath(Path rightBodyPath) {
    var tailPath = Path();
    var tailPosition1 = rightBodyPath.getPositionFromPercent(0.8);
    var tailPosition2 =
        Offset(tailPosition1.dx + 35.0, tailPosition1.dy - 30.0);
    var tailPosition3 =
        Offset(tailPosition1.dx + 35.0, tailPosition1.dy + 40.0);
    var tailPosition4 = rightBodyPath.getPositionFromPercent(0.9);

    tailPath.moveToPoint(tailPosition1);
    tailPath.cubicToPoints([tailPosition2, tailPosition3, tailPosition4]);

    return tailPath;
  }

  /// 创建3形状的path
  Path createThreePath(List<Offset> points) {
    Path path = Path();
    path.moveToPoint(points[0]);
    path.cubicToPoints(points.sublist(1, 4));
    path.cubicToPoints(points.sublist(4, 7));
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
