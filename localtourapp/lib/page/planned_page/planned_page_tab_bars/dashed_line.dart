import 'dart:math';

import 'package:flutter/material.dart';

class DashedLine extends StatelessWidget {
  final bool isHorizontal;
  final double length;
  final double dashLength;
  final double dashSpacing;

  const DashedLine({
    Key? key,
    required this.isHorizontal,
    required this.length,
    this.dashLength = 10.0,
    this.dashSpacing = 5.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: isHorizontal ? Size(length, 0) : Size(0, length),
      painter: DashedLinePainter(isHorizontal: isHorizontal, dashLength: dashLength, dashSpacing: dashSpacing),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final bool isHorizontal;
  final double dashLength;
  final double dashSpacing;

  DashedLinePainter({
    required this.isHorizontal,
    this.dashLength = 10.0,
    this.dashSpacing = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0;

    double startX = 0;
    double startY = 0;

    while (isHorizontal ? startX < size.width : startY < size.height) {
      final endX = isHorizontal ? startX + dashLength : startX;
      final endY = isHorizontal ? startY : startY + dashLength;

      // Draw the dash
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );

      // Draw the arrowhead
      if ((isHorizontal && endX + dashSpacing >= size.width) || (!isHorizontal && endY + dashSpacing >= size.height)) {
        const arrowLength = 8.0;
        const arrowAngle = 0.5; // radians for angle of arrowhead

        if (isHorizontal) {
          final arrowStart = Offset(endX, startY);
          final arrowLeft = Offset(
            endX - arrowLength * cos(arrowAngle),
            startY - arrowLength * sin(arrowAngle),
          );
          final arrowRight = Offset(
            endX - arrowLength * cos(arrowAngle),
            startY + arrowLength * sin(arrowAngle),
          );
          canvas.drawLine(arrowStart, arrowLeft, paint);
          canvas.drawLine(arrowStart, arrowRight, paint);
        } else {
          final arrowStart = Offset(startX, endY);
          final arrowTop = Offset(
            startX - arrowLength * sin(arrowAngle),
            endY - arrowLength * cos(arrowAngle),
          );
          final arrowBottom = Offset(
            startX + arrowLength * sin(arrowAngle),
            endY - arrowLength * cos(arrowAngle),
          );
          canvas.drawLine(arrowStart, arrowTop, paint);
          canvas.drawLine(arrowStart, arrowBottom, paint);
        }
      }

      // Move to the next dash position
      if (isHorizontal) {
        startX += dashLength + dashSpacing;
      } else {
        startY += dashLength + dashSpacing;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
