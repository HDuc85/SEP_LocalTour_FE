import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BackToTopButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String languageCode; // Add languageCode as a parameter
  final double iconSize;
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;
  final double borderRadius;
  final double padding;

  const BackToTopButton({
    Key? key,
    required this.onPressed,
    required this.languageCode, // Required for language-based label
    this.iconSize = 24.0,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.icon = Icons.arrow_upward,
    this.borderRadius = 24.0,
    this.padding = 10.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Set label based on languageCode
    final String label = languageCode == 'vi' ? 'Lên Đầu Trang' : 'Back To Top';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact(); // Optional: Haptic feedback
          onPressed();
        },
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: iconSize,
                color: textColor,
              ),
              const SizedBox(width: 8),
              Text(
                label, // Use the dynamic label
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
