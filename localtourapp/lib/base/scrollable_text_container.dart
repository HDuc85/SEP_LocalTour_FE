// scrollable_text_container.dart
import 'package:flutter/material.dart';

class ScrollableTextContainer extends StatelessWidget {
  final String content;
  final ScrollController? scrollController;
  final double textSize; // Added textSize parameter

  const ScrollableTextContainer({
    Key? key,
    required this.content,
    this.scrollController,
    this.textSize = 16.0, // Default text size
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 50,
        maxHeight: 200,
      ),
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      color: Colors.white,
      child: SingleChildScrollView(
        controller: scrollController,
        primary: false, // Prevents this scroll view from being the primary scroll view
        physics: const ClampingScrollPhysics(),
        child: Text(
          content,
          style: TextStyle(fontSize: textSize), // Utilize the textSize parameter
        ),
      ),
    );
  }
}
