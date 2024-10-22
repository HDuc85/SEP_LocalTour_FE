import 'package:flutter/material.dart';
import 'accountpage.dart';
import 'bookmarkpage.dart';
import 'home_screen.dart'; // Make sure you have imported the correct HomeScreen file
import 'mappage.dart';
import 'now_location.dart';
import 'schedulepage.dart';
import 'search_bar.dart'; // Import the SearchBarHome

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int currentIndex = 0; // Track the current index of the selected screen
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
        appBar: AppBar(
          title: const NowLocation(),
        ),
        body: Column( // Use Column to stack the SearchBar and the selected screen
          children: [
            Expanded( // Use Expanded to allow the screen to take the remaining space
              child: screens[currentIndex], // Display the selected screen
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (value) {
            setState(() {
              currentIndex = value; // Update the current index on tap
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
