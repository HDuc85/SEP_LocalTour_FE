import 'package:flutter/material.dart';

import '../../config/appConfig.dart';

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
