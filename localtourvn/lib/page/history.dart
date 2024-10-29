import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
        height: size.height,
        width: size.width, // Changed from size.height to size.width
        child: Scaffold(
          appBar: AppBar(
            title: const Text("History Page"),
          ),
          body: const Center(
            child: Text("This is History Page"),
          ),
        )
    );
  }
}
