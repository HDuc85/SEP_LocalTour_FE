import 'package:flutter/material.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height,
      width: size.width, // Changed from size.height to size.width
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Schedule Page"),
        ),
        body: const Center(
          child: Text("This is Schedule Page"),
        ),
      )
      );
  }
}
