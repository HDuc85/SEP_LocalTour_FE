// lib/main.dart

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:localtourapp/base/base_page.dart';
import 'package:localtourapp/base/const.dart';
import 'package:localtourapp/config/appConfig.dart';
import 'package:localtourapp/config/secure_storage_helper.dart';
import 'package:localtourapp/page/my_map/constants/route.dart';
import 'package:localtourapp/page/my_map/features/map_screen/bloc/map_bloc.dart';
import 'package:localtourapp/page/my_map/features/map_screen/maps_screen.dart';
import 'package:localtourapp/page/my_map/features/pick_address_screen/pick_address_screen.dart';
import 'package:localtourapp/page/my_map/features/routing_screen/bloc/routing_bloc.dart';
import 'package:localtourapp/page/my_map/features/routing_screen/routing_screen.dart';
import 'package:localtourapp/page/my_map/features/routing_screen/search_address.dart';
import 'package:localtourapp/page/my_map/features/search_screen/search_screen.dart';
import 'package:localtourapp/page/my_map/navigation_page.dart';
import 'package:localtourapp/page/wheel/wheel_page.dart';
import 'package:localtourapp/generated/l10n.dart';
import 'package:localtourapp/page/account/account_page.dart';
import 'package:localtourapp/page/bookmark/bookmark_page.dart';
import 'package:localtourapp/page/detail_page/detail_page.dart';
import 'package:localtourapp/page/home_screen/home_screen.dart';
import 'package:localtourapp/page/planned_page/planned_page.dart';
import 'package:localtourapp/page/planned_page/planned_page_tab_bars/history_tab_bar.dart';
import 'package:localtourapp/services/location_Service.dart';
import 'package:localtourapp/weather/weather_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'firebase_options.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'welcome_page.dart';

// Import your models and other dependencies as needed
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dotenv
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Error loading .env file: $e');
  }

  // Initialize Firebase
  final app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  auth.FirebaseAuth.instanceFor(app: app);

  // Initialize Hive
  try {
    final appDocumentDirectory = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDirectory.path);
  } catch (e) {
    print('Error initializing Hive: $e');
  }

  // Initialize other services
  final storage = SecureStorageHelper();
  await storage.saveValue(AppConfig.language, 'vi');

  LocationService locationService = LocationService();
  await locationService.getCurrentPosition();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => MapBloc()),
        BlocProvider(create: (context) => RoutingBloc()),
      ],
      child: MyApp(),
    ),
  );
}


class MyApp extends StatefulWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int currentIndex = 0;
  late final List<Widget> screens;
  late final List<String?> titles;
  final ScrollController scrollController = ScrollController();
  String CurrentUserId = '';
  bool _showWelcomePage = true;
  // Removed: bool _showLoginPage = false; // No longer needed

  @override
  void initState() {
    super.initState();
    screens = [
      const HomeScreen(),
      const MapScreen(),
      const BookmarkPage(),
      PlannedPage(
        userId: CurrentUserId,
      ),
      AccountPage(
        userId: '',
      ),
    ];

    titles = [
      null,
      null,
      'Bookmark Page',
      null,
      "Account Page",
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

  // Callback when the WelcomePage animation completes
  void _onAnimationComplete() {
    setState(() {
      _showWelcomePage = false; // Hide the WelcomePage
      // No longer setting _showLoginPage
    });
  }

  Future<void> CurrentUserFetch() async {
    var userId = await SecureStorageHelper().readValue(AppConfig.userId);
    if (userId != null && userId != '') {
      setState(() {
        CurrentUserId = userId;
        currentIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      supportedLocales: const [
        Locale('en'),
        Locale('vi'), // Corrected 'vn' to 'vi' for Vietnamese
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
        primaryColor: Constants.primaryColor,
        scaffoldBackgroundColor: const Color(0xFFEDE8D0),
      ),
      builder: (BuildContext context, Widget? child) {
        return FlutterEasyLoading(child: child);
      },

      home: _showWelcomePage
          ? WelcomePage(onAnimationComplete: _onAnimationComplete)
          : BasePage(
        body: screens[currentIndex],
        title: titles[currentIndex],
        currentIndex: currentIndex,
        onTabTapped: onTabTapped,
      ),
      onGenerateRoute: (settings) {
        // Existing routes
        if (settings.name == '/login') {
          return MaterialPageRoute(
            builder: (context) => LoginPage(
              onLogin: () {
                // Handle successful login
                CurrentUserFetch();
              },
              onRegister: () {
                // Handle registration navigation
                Navigator.pushNamed(context, '/register');
              },
            ),
          );
        }
        if (settings.name == '/register') {
          return MaterialPageRoute(
            builder: (context) => const RegisterPage(),
          );
        }
        if (settings.name == '/detail') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) {
              return DetailPage(
                placeId: args['placeId'] ?? -1,
              );
            },
          );
        }
        if (settings.name == '/account') {
          return MaterialPageRoute(
            builder: (context) => AccountPage(
              userId: CurrentUserId,
            ),
          );
        }

        // Routes from the other project
        if (settings.name == Routes.searchScreen) {
          return MaterialPageRoute(
            builder: (context) => const SearchScreen(),
          );
        }
        if (settings.name == Routes.mapScreen) {
          return MaterialPageRoute(
            builder: (context) => const MapScreen(),
          );
        }
        if (settings.name == Routes.routingScreen) {
          return MaterialPageRoute(
            builder: (context) => const RoutingScreen(),
          );
        }
        if (settings.name == Routes.pickAddressScreen) {
          return MaterialPageRoute(
            builder: (context) => const PickAddressScreen(),
          );
        }
        if (settings.name == Routes.searchAddressForRoutingScreen) {
          return MaterialPageRoute(
            builder: (context) => const SearchAddress(),
          );
        }

        // Existing switch cases
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
          case '/wheel':
            return MaterialPageRoute(builder: (context) => const WheelPage());
          case '/bookmark':
            return MaterialPageRoute(builder: (context) => const BookmarkPage());
          case '/planned_page':
            return MaterialPageRoute(
              builder: (context) => PlannedPage(
                userId: CurrentUserId,
              ),
            );
          case '/map':
            return MaterialPageRoute(builder: (context) => const MapScreen());
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