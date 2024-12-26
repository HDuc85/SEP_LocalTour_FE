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
        title: Text(
          widget.title!,
          maxLines: 2,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16.0),
          ),
        ),
      )
          : null,
      body: widget.body,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 8,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
          child: SizedBox(
            height: 60,
            child: BottomNavigationBar(
              currentIndex: widget.currentIndex,
              onTap: widget.onTabTapped,
              selectedItemColor: Colors.grey,
              backgroundColor: Colors.white,
              showSelectedLabels: true,
              selectedLabelStyle: const TextStyle(fontSize: 11.5),
              showUnselectedLabels: false,
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    height: widget.currentIndex == 0 ? 32 : 20,
                    width: widget.currentIndex == 0 ? 32 : 20,
                    child: Image.asset('assets/icons/Home.png'),
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    height: widget.currentIndex == 1 ? 32 : 20,
                    width: widget.currentIndex == 1 ? 32 : 20,
                    child: Image.asset('assets/icons/Treasure map.png'),
                  ),
                  label: 'Map',
                ),
                BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    height: widget.currentIndex == 2 ? 32 : 20,
                    width: widget.currentIndex == 2 ? 32 : 20,
                    child: Image.asset('assets/icons/Bookmark.png'),
                  ),
                  label: 'Bookmark',
                ),
                BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    height: widget.currentIndex == 3 ? 32 : 20,
                    width: widget.currentIndex == 3 ? 32 : 20,
                    child: Image.asset('assets/icons/Schedule.png'),
                  ),
                  label: 'Planned',
                ),
                BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    height: widget.currentIndex == 4 ? 32 : 20,
                    width: widget.currentIndex == 4 ? 32 : 20,
                    child: Image.asset('assets/icons/Profile.png'),
                  ),
                  label: 'Account',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
