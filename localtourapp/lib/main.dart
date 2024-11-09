import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:localtourvn/page/bookmark/bookmarkmanager.dart';
import 'package:localtourvn/page/mymap/MapPage.dart';
import 'package:localtourvn/page/plannedpage/plannedpagetabbars/history_tabbar.dart';
import 'package:localtourvn/weather/providers/weather_provider.dart';
import 'package:localtourvn/weather/weather_page.dart';
import 'package:provider/provider.dart';
import 'base/basepage.dart';
import 'base/const.dart';
import 'models/schedule/destination.dart';
import 'models/schedule/schedule.dart';
import 'models/schedule/schedulelike.dart';
import 'models/users/users.dart';
import 'page/accountpage.dart';
import 'page/bookmark/bookmarkpage.dart';
import 'page/detailpage/detailpage.dart';
import 'page/homescreen/home_screen.dart';
import 'page/plannedpage/planned_page.dart';
import 'models/users/users.dart';

final random = Random();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Create an instance of BookmarkManager and load bookmarks
  BookmarkManager bookmarkManager = BookmarkManager();
  await bookmarkManager.loadBookmarks();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => bookmarkManager),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int currentIndex = 0;
  late final List<Widget> screens;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    screens = [
      const HomeScreen(),
      const MapPage(),
      const BookmarkPage(),
      PlannedPage(
        schedules: dummySchedules,
        scheduleLikes: dummyScheduleLikes,
        destinations: dummyDestinations,
        scrollController: scrollController,
        users: fakeUsers,
        userId: 'anh-tuan-unique-id-1234',
      ),
      const AccountPage(),
    ];
  }

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
        scaffoldBackgroundColor: const Color(0xFFEDE8D0),
      ),
      initialRoute: '/',
      builder: EasyLoading.init(),
      onGenerateRoute: (settings) {
        if (settings.name == '/detail') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) {
              return DetailPage(
                placeName: args['placeName'],
                placeId: args['placeId'],
                mediaList: args['mediaList'],
              );
            },
          );
        }
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (context) => BasePage(
                body: screens[currentIndex],
                currentIndex: currentIndex,
                onTabTapped: onTabTapped,
                isMapPage: currentIndex == 1,
              ),
            );
          case '/weather':
            return MaterialPageRoute(builder: (context) => WeatherPage());
          case '/bookmark':
            return MaterialPageRoute(builder: (context) => const BookmarkPage());
          case '/planned_page':
            return MaterialPageRoute(
              builder: (context) => PlannedPage(
                schedules: dummySchedules,
                scheduleLikes: dummyScheduleLikes,
                destinations: dummyDestinations,
                scrollController: scrollController,
                users: fakeUsers,
                userId: 'anh-tuan-unique-id-1234',
              ),
            );
          case '/map':
            return MaterialPageRoute(builder: (context) => const MapPage());
          case '/account':
            return MaterialPageRoute(builder: (context) => const AccountPage());
          case '/history':
            return MaterialPageRoute(builder: (context) => const HistoryTabbar());
          default:
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
            );
        }
      },
    );
  }
}
