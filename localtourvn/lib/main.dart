import 'package:flutter/material.dart';
import 'page/accountpage.dart';
import 'page/bookmarkpage.dart';
import 'page/home_screen.dart';
import 'page/mappage.dart';
import 'now_location.dart';
import 'page/schedulepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int currentIndex = 0; 
  List<Widget> screens = [
    const HomeScreen(),
    const MapPage(),
    const BookmarkPage(),
    const SchedulePage(),
    const AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: Scaffold(
        backgroundColor: const Color(0xFFEDE8D0),
        body: Column( 
          children: [
            NowLocation(),
            Expanded( 
              child: screens[currentIndex], 
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (value) {
            setState(() {
              currentIndex = value; 
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
      ),
    );
  }
}
