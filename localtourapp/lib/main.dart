// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:localtourapp/account/account_page.dart';
import 'package:localtourapp/account/language_provider.dart';
import 'package:localtourapp/account/user_provider.dart';
import 'package:localtourapp/account/users_provider.dart';
import 'package:localtourapp/base/base_page.dart';
import 'package:localtourapp/base/const.dart';
import 'package:localtourapp/generated/l10n.dart';
import 'package:localtourapp/models/schedule/destination.dart';
import 'package:localtourapp/models/schedule/schedule.dart';
import 'package:localtourapp/models/schedule/schedulelike.dart';
import 'package:localtourapp/models/users/followuser.dart';
import 'package:localtourapp/models/users/users.dart';
import 'package:localtourapp/page/bookmark/bookmark_manager.dart';
import 'package:localtourapp/page/bookmark/bookmark_page.dart';
import 'package:localtourapp/page/detail_page/detail_page.dart';
import 'package:localtourapp/page/detail_page/detail_page_tab_bars/count_provider.dart';
import 'package:localtourapp/page/home_screen/home_screen.dart';
import 'package:localtourapp/page/my_map/map_page.dart';
import 'package:localtourapp/page/planned_page/planned_page.dart';
import 'package:localtourapp/page/planned_page/planned_page_tab_bars/history_tabbar.dart';
import 'package:localtourapp/weather/providers/weather_provider.dart';
import 'package:localtourapp/weather/weather_page.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Import your models and other dependencies as needed

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Create an instance of BookmarkManager and load bookmarks
  BookmarkManager bookmarkManager = BookmarkManager();
  await bookmarkManager.loadBookmarks();

  // Generate fake users
  List<User> fakeUsers = generateFakeUsers(10); // Ensure generateFakeUsers is defined
  User myUser = fakeUsers.firstWhere(
        (user) => user.userId == 'anh-tuan-unique-id-1234',
    orElse: () => fakeUsers.first, // Fallback to first user if not found
  );

  runApp(
    MultiProvider(
      providers: [
        // Add LanguageProvider here
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => bookmarkManager),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()..setCurrentUser(myUser)),
        ChangeNotifierProvider(create: (_) => UsersProvider(fakeUsers)),
        ChangeNotifierProvider(create: (_) => CountProvider()),
      ],
      child: MyApp(myUser: myUser),
    ),
  );
}

class MyApp extends StatefulWidget {
  final User myUser;

  const MyApp({Key? key, required this.myUser}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int currentIndex = 0;
  late final List<Widget> screens;
  late final List<String?> titles;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    screens = [
      const HomeScreen(),
      const MapPage(),
      const BookmarkPage(),
      PlannedPage(
        schedules: dummySchedules, // Ensure dummySchedules is defined
        scheduleLikes: dummyScheduleLikes, // Ensure dummyScheduleLikes is defined
        destinations: dummyDestinations, // Ensure dummyDestinations is defined
        userId: 'anh-tuan-unique-id-1234',
        users: Provider.of<UsersProvider>(context, listen: false).users,
      ),
      AccountPage(user: widget.myUser, followUsers: dummyFollowUsers), // Ensure dummyFollowUsers is defined
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

  void onTabTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: languageProvider.currentLocale,
      supportedLocales: const [
        Locale('en'),
        Locale('vn'),
        Locale('cn'),
      ],
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) return supportedLocales.first;
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      title: 'Local Tour',
      theme: ThemeData(
        primaryColor: Constants.primaryColor, // Ensure Constants.primaryColor is defined
        scaffoldBackgroundColor: const Color(0xFFEDE8D0),
      ),
      // Assuming EasyLoading is set up correctly
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
        } else if (settings.name == '/account') {
          final args = settings.arguments as Map<String, dynamic>?;

          // If no userId is passed, default to current user's account
          final userId = args != null && args.containsKey('userId') ? args['userId'] as String : null;
          final selectedUser = userId != null
              ? Provider.of<UsersProvider>(context, listen: false).getUserById(userId) ?? widget.myUser
              : widget.myUser;

          return MaterialPageRoute(
            builder: (context) => AccountPage(user: selectedUser, followUsers: dummyFollowUsers),
          );
        }
        // Handle other routes...
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (context) => BasePage(
                body: screens[currentIndex],
                title: titles[currentIndex],
                currentIndex: currentIndex,
                onTabTapped: onTabTapped,
              ),
            );
          case '/weather':
            return MaterialPageRoute(builder: (context) => const WeatherPage());
          case '/bookmark':
            return MaterialPageRoute(builder: (context) => const BookmarkPage());
          case '/planned_page':
            return MaterialPageRoute(
              builder: (context) => PlannedPage(
                schedules: dummySchedules,
                scheduleLikes: dummyScheduleLikes,
                destinations: dummyDestinations,
                userId: 'anh-tuan-unique-id-1234',
                users: Provider.of<UsersProvider>(context, listen: false).users,
              ),
            );
          case '/map':
            return MaterialPageRoute(builder: (context) => const MapPage());
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
      home: BasePage(
        body: screens[currentIndex],
        title: titles[currentIndex],
        currentIndex: currentIndex,
        onTabTapped: onTabTapped,
      ),
    );
  }
}
