// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:localtourapp/base/base_page.dart';
import 'package:localtourapp/base/const.dart';
import 'package:localtourapp/models/places/placefeedbackhelpful.dart';
import 'package:localtourapp/models/places/placefeedbackmedia.dart';
import 'package:localtourapp/provider/follow_users_provider.dart';
import 'package:localtourapp/provider/place_provider.dart';
import 'package:localtourapp/provider/schedule_provider.dart';
import 'package:localtourapp/generated/l10n.dart';
import 'package:localtourapp/models/places/place.dart';
import 'package:localtourapp/models/places/placetranslation.dart';
import 'package:localtourapp/models/posts/post.dart';
import 'package:localtourapp/models/posts/postcomment.dart';
import 'package:localtourapp/models/posts/postcommentlike.dart';
import 'package:localtourapp/models/posts/postlike.dart';
import 'package:localtourapp/models/posts/postmedia.dart';
import 'package:localtourapp/models/schedule/destination.dart';
import 'package:localtourapp/models/schedule/schedule.dart';
import 'package:localtourapp/models/schedule/schedulelike.dart';
import 'package:localtourapp/models/users/followuser.dart';
import 'package:localtourapp/models/users/users.dart';
import 'package:localtourapp/page/account/account_page.dart';
import 'package:localtourapp/provider/language_provider.dart';
import 'package:localtourapp/provider/review_provider.dart';
import 'package:localtourapp/provider/user_provider.dart';
import 'package:localtourapp/provider/users_provider.dart';
import 'package:localtourapp/page/account/view_profile/auth_provider.dart';
import 'package:localtourapp/page/account/view_profile/post_provider.dart';
import 'package:localtourapp/page/bookmark/bookmark_page.dart';
import 'package:localtourapp/page/detail_page/detail_page.dart';
import 'package:localtourapp/provider/count_provider.dart';
import 'package:localtourapp/page/home_screen/home_screen.dart';
import 'package:localtourapp/page/my_map/map_page.dart';
import 'package:localtourapp/page/planned_page/planned_page.dart';
import 'package:localtourapp/page/planned_page/planned_page_tab_bars/history_tab_bar.dart';
import 'package:localtourapp/weather/providers/weather_provider.dart';
import 'package:localtourapp/weather/weather_page.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'login_page.dart';
import 'models/places/placefeedback.dart';
import 'register_page.dart';
import 'welcome_page.dart';

// Import your models and other dependencies as needed
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  // Initialize Hive
  await Hive.initFlutter();

  // Create an instance of bookmarkProvider and load bookmarks
  PlaceProvider bookmarkProvider = PlaceProvider(
    places: dummyPlaces,
    translations: dummyTranslations,
  );
  await bookmarkProvider.loadBookmarks();

  // Generate fake users
  User myUser = fakeUsers.firstWhere(
        (user) => user.userId == 'anh-tuan-unique-id-1234',
    orElse: () => fakeUsers.first, // Fallback to first user if not found
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider(initialUser: myUser)),
        ChangeNotifierProvider(
            create: (_) => ReviewProvider(
              placeFeedbacks: dummyFeedbacks,
              placeFeedbackMedia: feedbackMediaList,
              placeFeedbackHelpfuls: feebBackHelpfuls,
            )),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => bookmarkProvider),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => UsersProvider(fakeUsers)),
        ChangeNotifierProvider(create: (_) => CountProvider()),
        ChangeNotifierProvider(create: (_) => PlaceProvider()),
        ChangeNotifierProvider(
            create: (_) =>
                FollowUsersProvider(initialFollowUsers: dummyFollowUsers)),
        ChangeNotifierProvider(
            create: (_) => ScheduleProvider(
              places: dummyPlaces,
              translations: dummyTranslations,
              schedules: dummySchedules,
              scheduleLikes: dummyScheduleLikes,
              destinations: dummyDestinations,
            )),
        ChangeNotifierProvider(
            create: (_) => PostProvider(
              posts: dummyPosts,
              comments: dummyComments,
              postLikes: dummyPostLikes,
              commentLikes: dummyPostCommentLikes,
              media: dummyPostMedia,
            )),
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

  bool _showWelcomePage = true;
  bool _showLoginPage = false; // New flag for LoginPage

  @override
  void initState() {
    super.initState();
    screens = [
      const HomeScreen(),
      const MapPage(),
      const BookmarkPage(),
      PlannedPage(
        scheduleLikes: dummyScheduleLikes,
        destinations: dummyDestinations,
        userId: widget.myUser.userId,
        users: Provider.of<UsersProvider>(context, listen: false).users,
      ),
      AccountPage(
        user: widget.myUser,
        followUsers: dummyFollowUsers,
        isCurrentUser: true,
      ),
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

  // Callback when the WelcomePage animation completes
  void _onAnimationComplete() {
    setState(() {
      _showWelcomePage = false; // Hide the WelcomePage
      _showLoginPage = true; // Show the LoginPage
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          locale: languageProvider.currentLocale,
          supportedLocales: const [
            Locale('en'),
            Locale('vn'),
          ],
          localizationsDelegates: const [
            // Ensure you have generated localization delegates
            // Replace 'S.delegate' with your localization delegate
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
              : (_showLoginPage
              ? LoginPage(
            onLogin: () {
              // Simulate a successful login
              authProvider.login(widget.myUser.userId);
              setState(() {
                _showLoginPage = false; // Hide LoginPage
              });
            },
            onRegister: () {
              // Handle Register Button Press
              Navigator.pushNamed(context, '/register');
            },
          )
              : (authProvider.isLoggedIn
              ? BasePage(
            body: screens[currentIndex],
            title: titles[currentIndex],
            currentIndex: currentIndex,
            onTabTapped: onTabTapped,
          )
              : LoginPage(
            onLogin: () {
              // Simulate a successful login
              authProvider.login(widget.myUser.userId);
              setState(() {
                _showLoginPage = false; // Hide LoginPage
              });
            },
            onRegister: () {
              // Handle Register Button Press
              // Navigate to RegisterPage or perform other actions
              Navigator.pushNamed(context, '/register');
            },
          ))),
          onGenerateRoute: (settings) {
            if (settings.name == '/login') {
              return MaterialPageRoute(
                builder: (context) => LoginPage(
                  onLogin: () {
                    // Handle successful login
                    authProvider.login(widget.myUser.userId);
                    setState(() {
                      _showLoginPage = false; // Hide LoginPage
                    });
                  },
                  onRegister: () {
                    // Handle registration navigation
                    // Navigate to RegisterPage
                    Navigator.pushNamed(context, '/register');
                  },
                ),
              );
            }
            if (settings.name == '/register') {
              return MaterialPageRoute(
                builder: (context) => const RegisterPage(), // Ensure you have RegisterPage
              );
            }
            if (settings.name == '/detail') {
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) {
                  return DetailPage(
                    languageCode: args['languageCode'],
                    placeName: args['placeName'] ?? 'Unknown Place',
                    placeId: args['placeId'] ?? -1,
                    mediaList: args['mediaList'] ?? [],
                    userId: args['userId'] ?? 'unknown-user',
                  );
                },
              );
            } else if (settings.name == '/account') {
              final args = settings.arguments as Map<String, dynamic>?;

              final userId = args != null && args.containsKey('userId')
                  ? args['userId'] as String
                  : widget.myUser.userId;
              final User selectedUser = Provider.of<UsersProvider>(context, listen: false)
                  .getUserById(userId) ??
                  widget.myUser;
              final isCurrentUser = userId == widget.myUser.userId;
              return MaterialPageRoute(
                builder: (context) => AccountPage(
                  user: selectedUser,
                  followUsers: dummyFollowUsers,
                  isCurrentUser: isCurrentUser,
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
                return MaterialPageRoute(builder: (context) => const WeatherPage());
              case '/bookmark':
                return MaterialPageRoute(builder: (context) => const BookmarkPage());
              case '/planned_page':
                return MaterialPageRoute(
                  builder: (context) => PlannedPage(
                    scheduleLikes: dummyScheduleLikes,
                    destinations: dummyDestinations,
                    userId: widget.myUser.userId,
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
        );
      },
    );
  }
}

