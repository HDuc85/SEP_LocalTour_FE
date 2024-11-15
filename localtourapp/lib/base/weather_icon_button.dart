import 'package:flutter/material.dart';

class WeatherIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String assetPath;
  final double size;

  const WeatherIconButton({
    Key? key,
    required this.onPressed,
    required this.assetPath,
    this.size = 36.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(size / 2),
        child: Padding(
          padding: EdgeInsets.all(size * 0.3),
          child: Image.asset(
            assetPath,
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
