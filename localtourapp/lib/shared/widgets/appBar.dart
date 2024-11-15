import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:localtourapp/config/appConfig.dart';
=======

import '../../config/appConfig.dart';
>>>>>>> TuanNTA2k

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(AppConfig.appName),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
