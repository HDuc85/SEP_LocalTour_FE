import 'package:flutter/material.dart';
import 'page/accountpage.dart';
import 'page/mappage.dart';
import 'page/schedulepage.dart';
import 'basepage.dart';
import 'const.dart';
import 'page/bookmarkpage.dart';
import 'page/detailpage.dart';
import 'page/history.dart';
import 'page/home_screen.dart';

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

  final List<Widget> screens = [
    const HomeScreen(),
    const MapPage(),
    const BookmarkPage(),
    const SchedulePage(),
    const AccountPage(),
  ];

  void onTabTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Local Tour',
      theme: ThemeData(
          primaryColor: Constants.primaryColor,
          scaffoldBackgroundColor: const Color(0xFFEDE8D0)),
      initialRoute: '/',
      routes: {
        '/': (context) => BasePage(
          body: screens[currentIndex],
          currentIndex: currentIndex,
          onTabTapped: onTabTapped,
        ),
        '/detail': (context) => const DetailPage(),
        '/bookmark': (context) => const BookmarkPage(),
        '/map': (context) => const MapPage(),
        '/schedule': (context) => const SchedulePage(),
        '/account': (context) => const AccountPage(),
        '/history': (context) => const HistoryPage(),
      },
    );
  }
}
