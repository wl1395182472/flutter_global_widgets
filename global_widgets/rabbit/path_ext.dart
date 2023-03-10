import 'package:flutter/material.dart';

extension PathExt on Path {
  void moveToPoint(Offset point) {
    moveTo(point.dx, point.dy);
  }

  void lineToPoint(Offset point) {
    lineTo(point.dx, point.dy);
  }

  void cubicToPoints(List<Offset> points) {
    if (points.length != 3) {
      throw "params points length must 3";
    }
    cubicTo(points[0].dx, points[0].dy, points[1].dx, points[1].dy,
        points[2].dx, points[2].dy);
  }

  void quadraticBezierToPoints(List<Offset> points) {
    if (points.length != 2) {
      throw "params points length must 2";
    }
    quadraticBezierTo(points[0].dx, points[0].dy, points[1].dx, points[1].dy);
  }

  void addPaths(List<Path> paths) {
    for (var element in paths) {
      addPath(element, Offset.zero);
    }
  }

  void addPointsFromPath(Path copyPath, {bool isReverse = false}) {
    var pms = copyPath.computeMetrics();
    var pm = pms.first;
    if (isReverse) {
      for (double i = pm.length; i > 0; i--) {
        var position = pm.getTangentForOffset(i.toDouble())?.position;
        if (position != null) {
          lineTo(position.dx, position.dy);
        }
      }
    } else {
      for (int i = 0; i < pm.length; i++) {
        var position = pm.getTangentForOffset(i.toDouble())?.position;
        if (position != null) {
          lineTo(position.dx, position.dy);
        }
      }
    }
  }

  void addPointsFromPaths() {}

  void mergePath(Path path) {
    var pms = path.computeMetrics();
    var pm = pms.first;
    var firstPosition = pm.getTangentForOffset(0)?.position ?? Offset.zero;
    moveTo(firstPosition.dx, firstPosition.dy);
    for (int i = 0; i < pm.length; i++) {
      var position = pm.getTangentForOffset(i.toDouble())?.position;
      if (position != null) {
        lineTo(position.dx, position.dy);
      }
    }
  }

  void mergePaths(List<Path> paths) {
    for (var value in paths) {
      mergePath(value);
    }
  }

  Offset getPositionFromPercent(double percent) {
    var pms = computeMetrics();
    var pm = pms.first;
    var position =
        pm.getTangentForOffset(pm.length * percent)?.position ?? Offset.zero;
    return position;
  }

  Path getPathFromPercent(double startPercent, double endPercent) {
    var pms = computeMetrics();
    var pm = pms.first;
    var resultPath =
        pm.extractPath(pm.length * startPercent, pm.length * endPercent);
    return resultPath;
  }

  double getWidth() {
    var rect = getBounds();
    return rect.width;
  }

  double getHeight() {
    var rect = getBounds();
    return rect.height;
  }

  Offset getMinYPosition() {
    var pms = computeMetrics();
    var pm = pms.first;
    var minPosition = pm.getTangentForOffset(0)?.position;
    for (int i = 0; i < pm.length; i++) {
      var position = pm.getTangentForOffset(i.toDouble())?.position;
      if (minPosition == null ||
          (position != null && position.dy < minPosition.dy)) {
        minPosition = position;
      }
    }
    return minPosition ?? Offset.zero;
  }
}
