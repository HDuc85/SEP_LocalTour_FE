import 'package:flutter/material.dart';

import '../../config/appConfig.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(AppConfig.appName),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
