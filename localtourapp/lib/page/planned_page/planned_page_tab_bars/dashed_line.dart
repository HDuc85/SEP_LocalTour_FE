import 'package:flutter/material.dart';

class DashedLine extends StatelessWidget {
  final bool isHorizontal;
  final double length;
  final double dashWidth;
  final double dashHeight;
  final double dashSpacing;
  final Color color;

  const DashedLine({
    Key? key,
    required this.isHorizontal,
    required this.length,
    this.dashWidth = 4.5,
    this.dashHeight = 2,
    this.dashSpacing = 1,
    this.color = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int dashCount = (length / (dashWidth + dashSpacing)).floor();

    return Flex(
      direction: isHorizontal ? Axis.horizontal : Axis.vertical,
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(dashCount * 2 - 1, (index) {
        if (index % 2 == 0) {
          // Dash
          return SizedBox(
            width: isHorizontal ? dashWidth : dashHeight,
            height: isHorizontal ? dashHeight : dashWidth,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color,
              ),
            ),
          );
        } else {
          // Space between dashes
          return SizedBox(
            width: isHorizontal ? dashSpacing : 0,
            height: isHorizontal ? 0 : dashSpacing,
          );
        }
      }),
    );
  }
}
