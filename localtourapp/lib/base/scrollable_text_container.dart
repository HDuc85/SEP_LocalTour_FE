<<<<<<< HEAD
=======
// scrollable_text_container.dart
>>>>>>> TuanNTA2k
import 'package:flutter/material.dart';

class ScrollableTextContainer extends StatelessWidget {
  final String content;
<<<<<<< HEAD

  const ScrollableTextContainer({super.key, required this.content});

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
=======
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
>>>>>>> TuanNTA2k
        ),
      ),
    );
  }
}
