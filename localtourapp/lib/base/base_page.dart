import 'package:flutter/material.dart';

class BasePage extends StatefulWidget {
  final Widget body;
  final String? title;
  final int currentIndex;
  final Function(int) onTabTapped;
  final bool isMapPage;

  const BasePage({
    Key? key,
    required this.body,
    this.title,
    required this.currentIndex,
    required this.onTabTapped,
    this.isMapPage = false,
  }) : super(key: key);

  @override
  _BasePageState createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.title != null
          ? AppBar(
        title: Text(widget.title!,maxLines: 2,style: const TextStyle(fontSize: 16),),
      )
          : null,
      body: widget.body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget.currentIndex,
        onTap: widget.onTabTapped,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map_sharp), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Bookmark'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Planned',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_rounded),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
