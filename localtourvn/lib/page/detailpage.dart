import 'package:flutter/material.dart';

import 'accountpage.dart';
import 'bookmarkpage.dart';
import 'home_screen.dart';
import 'mappage.dart';
import 'schedulepage.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool isBookmarked = false;
  int currentIndex = 0; // Track the current index of the BottomNavigationBar

  List<Widget> screens = [
    const HomeScreen(),
    const MapPage(),
    const BookmarkPage(),
    const SchedulePage(),
    const AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Container(
          color: const Color(0xFFEDE8D0),
          child: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    const Image(image: AssetImage('assets/picture1.png')),
                    Positioned(
                      top: 0,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 40,
                        color: Colors.black.withOpacity(0.7),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.bookmark,
                                color: isBookmarked ? Colors.yellow : Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  isBookmarked = !isBookmarked;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Image(
                        image: AssetImage('assets/picture2.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      child: Image(
                        image: AssetImage('assets/video1.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      child: Image(
                        image: AssetImage('assets/picture3.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      child: Image(
                        image: AssetImage('assets/picture4.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
                const TabBar(
                  labelColor: Colors.black,
                  indicatorColor: Colors.pink,
                  tabs: [
                    Tab(text: 'Detail'),
                    Tab(text: 'Review'),
                    Tab(text: 'Service'),
                  ],
                ),
                // Use Expanded here for the TabBarView to manage height
                const Expanded(
                  child: TabBarView(
                    children: [
                      Center(child: Text('Details about the place')),
                      Center(child: Text('User Reviews')),
                      Center(child: Text('Available Services')),
                    ],
                  ),
                ),
                // Reuse the BottomNavigationBar from main.dart
                BottomNavigationBar(
                  currentIndex: currentIndex,
                  onTap: (value) {
                    setState(() {
                      currentIndex = value;
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => screens[currentIndex]),
                      );
                    });
                  },
                  selectedItemColor: Colors.red,
                  unselectedItemColor: Colors.grey,
                  items: const [
                    BottomNavigationBarItem(
                      label: "Home",
                      icon: Icon(Icons.home),
                    ),
                    BottomNavigationBarItem(
                      label: "Map",
                      icon: Icon(Icons.map),
                    ),
                    BottomNavigationBarItem(
                      label: "Bookmark",
                      icon: Icon(Icons.bookmark),
                    ),
                    BottomNavigationBarItem(
                      label: "Schedule",
                      icon: Icon(Icons.schedule),
                    ),
                    BottomNavigationBarItem(
                      label: "Account",
                      icon: Icon(Icons.account_box),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
