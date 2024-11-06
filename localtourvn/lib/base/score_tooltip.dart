import 'package:flutter/material.dart';

import 'const.dart';


class ScoreDetailsTooltip extends StatefulWidget {
  @override
  _ScoreDetailsTooltipState createState() => _ScoreDetailsTooltipState();
}

class _ScoreDetailsTooltipState extends State<ScoreDetailsTooltip> {
  OverlayEntry? _overlayEntry;

  void _showCustomTooltip(BuildContext context) {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx - 100,
        top: offset.dy - renderBox.size.height - 100,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStarRow(5, "+2 points"),
                _buildStarRow(4, "+1 point"),
                _buildStarRow(3, "0 points"),
                _buildStarRow(2, "-1 point"),
                _buildStarRow(1, "-2 points"),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _hideCustomTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildStarRow(int stars, String points) {
    return Row(
      children: [
        Row(
          children: List.generate(
            stars,
                (index) => const Icon(Icons.star, color: Constants.starColor),
          ),
        ),
        const SizedBox(width: 8),
        Text(points, style: const TextStyle(color: Colors.black)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showCustomTooltip(context),
      onLongPressEnd: (_) => _hideCustomTooltip(),
      child: IconButton(
        icon: const Icon(Icons.info, color: Colors.blue),
        onPressed: () {}, // No action needed on tap, long-press shows tooltip
      ),
    );
  }
}
