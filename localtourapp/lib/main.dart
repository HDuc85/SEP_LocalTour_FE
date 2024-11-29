// lib/main.dart

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:localtourapp/base/base_page.dart';
import 'package:localtourapp/base/const.dart';
import 'package:localtourapp/config/appConfig.dart';
import 'package:localtourapp/config/secure_storage_helper.dart';
import 'package:localtourapp/page/detail_page/event_detail_page.dart';
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

import 'firebase_options.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'welcome_page.dart';

// Import your models and other dependencies as needed
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  final storage = SecureStorageHelper();
  WidgetsFlutterBinding.ensureInitialized();
  final app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  auth.FirebaseAuth.instanceFor(app: app);
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  // Initialize Hive
  await Hive.initFlutter();
  await storage.saveValue(AppConfig.language, 'vi');

  LocationService locationService = LocationService();
  await locationService.getCurrentPosition();

  runApp(
     MyApp(),
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
      const HomeScreen(),
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
            Locale('vn'),
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
          builder: EasyLoading.init(),
          home: _showWelcomePage
              ? WelcomePage(onAnimationComplete: _onAnimationComplete)
              : BasePage(
                  body: screens[currentIndex],
                  title: titles[currentIndex],
                  currentIndex: currentIndex,
                  onTabTapped: onTabTapped,
                ),
          onGenerateRoute: (settings) {
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
                builder: (context) =>
                    const RegisterPage(), // Ensure you have RegisterPage
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
            } else if (settings.name == '/account') {
              return MaterialPageRoute(
                builder: (context) => AccountPage(
                  userId: CurrentUserId,
                ),
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
                return MaterialPageRoute(
                    builder: (context) => const WeatherPage());
              case '/wheel':
                return MaterialPageRoute(builder: (context) =>  const WheelPage());
              case '/bookmark':
                return MaterialPageRoute(
                    builder: (context) => const BookmarkPage());
              case '/planned_page':
                return MaterialPageRoute(
                  builder: (context) => PlannedPage(
                    userId: CurrentUserId,
                  ),
                );
              case '/map':
                return MaterialPageRoute(builder: (context) => const HomeScreen());
              case '/history':
                return MaterialPageRoute(
                    builder: (context) => const HistoryTabbar());
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
