import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:localtourvn/page/bookmark/bookmarkmanager.dart';
import 'package:localtourvn/page/plannedpage/plannedpagetabbars/history_tabbar.dart';
import 'package:localtourvn/page/vietmap/features/map_screen/bloc/map_bloc.dart';
import 'package:localtourvn/page/vietmap/features/routing_screen/bloc/routing_bloc.dart';
import 'package:localtourvn/page/vietmap/mappage.dart';
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

final random = Random();

User myUser = User(
  userId: 'anh-tuan-unique-id-1234',
  userName: 'tuannta2k',
  normalizedUserName: 'TUANNTA2K',
  email: 'nguyenthanhanhtuan123@gmail.com',
  normalizedEmail: 'NGUYENTHANHANHTUAN123@GMAIL.COM',
  emailConfirmed: true,
  passwordHash: null,
  phoneNumber: '+84705543619',
  phoneNumberConfirmed: true,
  fullName: 'Nguyen Thanh Anh Tuan',
  dateOfBirth: DateTime(2000, 04, 24),
  address: '123 Example Street',
  gender: 'Male',
  profilePictureUrl: 'https://picsum.photos/seed/${random.nextInt(1000)}/600/400/',
  dateCreated: DateTime.now().subtract(Duration(days: 100)),
  dateUpdated: DateTime.now(),
  reportTimes: 0,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

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

  @override
  void initState() {
    super.initState();
    screens = [
      const HomeScreen(),
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => MapBloc()),
          BlocProvider(create: (context) => RoutingBloc()),
        ],
        child: const MapPage(),
      ),
      const BookmarkPage(),
      PlannedPage(
        user: myUser,
        schedules: dummySchedules.where((schedule) => schedule.userId == myUser.userId).toList(),
        scheduleLikes: dummyScheduleLikes.where((scheduleLike) => scheduleLike.userId == myUser.userId).toList(),
        destinations: dummyDestinations,
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
                user: myUser,
                schedules: dummySchedules,
                scheduleLikes: dummyScheduleLikes,
                destinations: dummyDestinations,
              ),
            );
          case '/map':
            return MaterialPageRoute(
              builder: (context) => MultiBlocProvider(
                providers: [
                  BlocProvider(create: (context) => MapBloc()),
                  BlocProvider(create: (context) => RoutingBloc()),
                ],
                child: const MapPage(),
              ),
            );
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
