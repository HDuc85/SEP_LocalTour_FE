import 'package:flutter/material.dart';

import '../../constants/colors.dart';

final ThemeData appTheme = ThemeData(
  primaryColor: primaryColor,
  scaffoldBackgroundColor: backgroundColor,
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: textColor),
  ),
);
