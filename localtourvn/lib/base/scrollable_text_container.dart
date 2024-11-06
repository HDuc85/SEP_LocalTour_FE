import 'package:flutter/material.dart';

class ScrollableTextContainer extends StatelessWidget {
  final String content;

  const ScrollableTextContainer({Key? key, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 4,    // Minimum height
        maxHeight: 200,  // Maximum height
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8.0), // Optional padding for better readability
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          child: Text(
            content.length > 1000 ? content.substring(0, 1000) : content, // Limit content to 200 characters
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
