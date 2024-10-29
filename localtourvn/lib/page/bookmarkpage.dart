import 'package:flutter/material.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
        height: size.height,
        width: size.width, // Changed from size.height to size.width
        child: Scaffold(
          appBar: AppBar(
            title: Text("Bookmark Page"),
          ),
          body: Center(
            child: const Text("This is Bookmark Page"),
          ),
        )
    );
  }
}
