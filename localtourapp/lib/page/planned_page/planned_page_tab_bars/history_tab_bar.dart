import 'package:flutter/material.dart';

class HistoryTabbar extends StatefulWidget {
  const HistoryTabbar({super.key});

  @override
  State<HistoryTabbar> createState() => _HistoryTabbarState();
}

class _HistoryTabbarState extends State<HistoryTabbar> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
        height: size.height,
        width: size.width, // Changed from size.height to size.width
        child: Scaffold(
          body: const Center(),
        )
    );
  }
}
