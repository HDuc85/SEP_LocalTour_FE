import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
<<<<<<< Updated upstream
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
=======
import 'package:localtourapp/account/user_provider.dart';
import 'package:localtourapp/account/users_provider.dart';
import 'package:localtourapp/page/bookmark/bookmarkmanager.dart';
import 'package:localtourapp/page/bookmark/bookmarkpage.dart';
import 'package:localtourapp/page/detailpage/detailpage.dart';
import 'package:localtourapp/page/homescreen/home_screen.dart';
import 'package:localtourapp/page/mymap/MapPage.dart';
import 'package:localtourapp/page/plannedpage/planned_page.dart';
import 'package:localtourapp/page/plannedpage/plannedpagetabbars/history_tabbar.dart';
import 'package:localtourapp/weather/providers/weather_provider.dart';
import 'package:localtourapp/weather/weather_page.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Assuming Hive is being used

import '../models/users/followuser.dart';
import '../models/users/users.dart';
import '../page/detailpage/detailpagetabbars/count_provider.dart';
import 'account/accountpage.dart';
import 'base/basepage.dart';
import 'base/const.dart';
import 'models/schedule/destination.dart';
import 'models/schedule/schedule.dart';
import 'models/schedule/schedulelike.dart';
>>>>>>> Stashed changes

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Create an instance of BookmarkManager and load bookmarks
  BookmarkManager bookmarkManager = BookmarkManager();
  await bookmarkManager.loadBookmarks();

<<<<<<< Updated upstream
=======
  // Generate fake users
  User myUser = fakeUsers.firstWhere(
        (user) => user.userId == 'anh-tuan-unique-id-1234',
    orElse: () => fakeUsers.first, // Fallback to first user if not found
  );

>>>>>>> Stashed changes
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => bookmarkManager),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
<<<<<<< Updated upstream
      ],
      child: const MyApp(),
=======
        ChangeNotifierProvider(create: (_) => UserProvider()..setCurrentUser(myUser)),
        ChangeNotifierProvider(create: (_) => UsersProvider(fakeUsers)),
        ChangeNotifierProvider(create: (_) => CountProvider()),
      ],
      child: MyApp(myUser: myUser),
>>>>>>> Stashed changes
    ),
  );
}

class MyApp extends StatefulWidget {
<<<<<<< Updated upstream
  const MyApp({Key? key}) : super(key: key);
=======
  final User myUser;

  const MyApp({Key? key, required this.myUser}) : super(key: key);
>>>>>>> Stashed changes

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int currentIndex = 0;
  late final List<Widget> screens;
<<<<<<< Updated upstream
=======
  late final List<String?> titles;
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
        scrollController: scrollController,
        users: fakeUsers,
        userId: 'anh-tuan-unique-id-1234',
      ),
      const AccountPage(),
    ];
  }

=======
        userId: 'anh-tuan-unique-id-1234',
        users: Provider.of<UsersProvider>(context, listen: false).users,
      ),
      AccountPage(user: widget.myUser, followUsers: dummyFollowUsers),
    ];

    titles = [
      null,
      null,
      'Bookmark Page',
      null,
      "${widget.myUser.fullName}'s Account Page",
    ];
  }

  @override
  void dispose() {
    scrollController.dispose(); // Dispose the ScrollController
    super.dispose();
  }

>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
      initialRoute: '/',
=======
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
        }
=======
        } else if (settings.name == '/account') {
          final args = settings.arguments as Map<String, dynamic>?;

          // If no userId is passed, default to current user's account
          final userId = args != null && args.containsKey('userId') ? args['userId'] as String : null;
          final selectedUser = userId != null
              ? fakeUsers.firstWhere((user) => user.userId == userId, orElse: () => widget.myUser)
              : widget.myUser;

          return MaterialPageRoute(
            builder: (context) => AccountPage(user: selectedUser, followUsers: dummyFollowUsers),
          );
        }
        // Handle other routes...
>>>>>>> Stashed changes
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (context) => BasePage(
                body: screens[currentIndex],
<<<<<<< Updated upstream
                currentIndex: currentIndex,
                onTabTapped: onTabTapped,
                isMapPage: currentIndex == 1,
=======
                title: titles[currentIndex],
                currentIndex: currentIndex,
                onTabTapped: onTabTapped,
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
                scrollController: scrollController,
                users: fakeUsers,
                userId: 'anh-tuan-unique-id-1234',
=======
                userId: 'anh-tuan-unique-id-1234',
                users: Provider.of<UsersProvider>(context, listen: false).users,
>>>>>>> Stashed changes
              ),
            );
          case '/map':
            return MaterialPageRoute(builder: (context) => const MapPage());
<<<<<<< Updated upstream
          case '/account':
            return MaterialPageRoute(builder: (context) => const AccountPage());
=======
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
=======
      home: BasePage(
        body: screens[currentIndex],
        title: titles[currentIndex],
        currentIndex: currentIndex,
        onTabTapped: onTabTapped,
      ),
>>>>>>> Stashed changes
    );
  }
}
