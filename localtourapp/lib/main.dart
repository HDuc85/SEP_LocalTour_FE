<<<<<<< HEAD
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
=======
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

import 'models/places/placefeedback.dart';

// Import your models and other dependencies as needed

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  // Initialize Hive
  await Hive.initFlutter();

  // Create an instance of bookmarkProvider and load bookmarks
  PlaceProvider bookmarkProvider = PlaceProvider();
  await bookmarkProvider.loadBookmarks();

  // Generate fake users
  User myUser = fakeUsers.firstWhere(
        (user) => user.userId == 'anh-tuan-unique-id-1234',
    orElse: () => fakeUsers.first, // Fallback to first user if not found
  );
  runApp(
    MultiProvider(
      providers: [
        // Add LanguageProvider here
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider(initialUser: myUser)),
        ChangeNotifierProvider(create: (_) => ReviewProvider(placeFeedbacks: dummyFeedbacks, placeFeedbackMedia: feedbackMediaList, placeFeedbackHelpfuls: feebBackHelpfuls)),
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

  @override
  void initState() {
    super.initState();
    screens = [
      const HomeScreen(),
      const MapPage(),
      const BookmarkPage(),
      PlannedPage(
        scheduleLikes:
        dummyScheduleLikes, // Ensure dummyScheduleLikes is defined
        destinations: dummyDestinations, // Ensure dummyDestinations is defined
        userId: widget.myUser.userId,
        users: Provider.of<UsersProvider>(context, listen: false).users,
      ),
      AccountPage(
        user: widget.myUser,
        followUsers: dummyFollowUsers,
        isCurrentUser: true,
      ), // Ensure dummyFollowUsers is defined
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
>>>>>>> TuanNTA2k
    });
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Local Tour',
      theme: ThemeData(
        primaryColor: Constants.primaryColor,
        scaffoldBackgroundColor: const Color(0xFFEDE8D0),
      ),
      initialRoute: '/',
=======
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
        primaryColor:
        Constants.primaryColor, // Ensure Constants.primaryColor is defined
        scaffoldBackgroundColor: const Color(0xFFEDE8D0),
      ),
      // Assuming EasyLoading is set up correctly
>>>>>>> TuanNTA2k
      builder: EasyLoading.init(),
      onGenerateRoute: (settings) {
        if (settings.name == '/detail') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) {
              return DetailPage(
<<<<<<< HEAD
                placeName: args['placeName'],
                placeId: args['placeId'],
                mediaList: args['mediaList'],
              );
            },
          );
        }
=======
                languageCode: args['languageCode'],
                placeName: args['placeName'] ??
                    'Unknown Place', // Provide a default name
                placeId: args['placeId'] ?? -1, // Provide a default ID, if null
                mediaList:
                args['mediaList'] ?? [], // Default to an empty list if null
                userId: args['userId'] ?? 'unknown-user', // Default userId
              );
            },
          );
        } else if (settings.name == '/account') {
          final args = settings.arguments as Map<String, dynamic>?;

          // If no userId is passed, default to current user's account
          final userId = args != null && args.containsKey('userId')
              ? args['userId'] as String
              : widget.myUser.userId;
          final User selectedUser;
          selectedUser = Provider.of<UsersProvider>(context, listen: false)
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
>>>>>>> TuanNTA2k
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (context) => BasePage(
                body: screens[currentIndex],
<<<<<<< HEAD
                currentIndex: currentIndex,
                onTabTapped: onTabTapped,
                isMapPage: currentIndex == 1,
              ),
            );
          case '/weather':
            return MaterialPageRoute(builder: (context) => WeatherPage());
=======
                title: titles[currentIndex],
                currentIndex: currentIndex,
                onTabTapped: onTabTapped,
              ),
            );
          case '/weather':
            return MaterialPageRoute(builder: (context) => const WeatherPage());
>>>>>>> TuanNTA2k
          case '/bookmark':
            return MaterialPageRoute(
                builder: (context) => const BookmarkPage());
          case '/planned_page':
            return MaterialPageRoute(
              builder: (context) => PlannedPage(
<<<<<<< HEAD
                schedules: dummySchedules,
                scheduleLikes: dummyScheduleLikes,
                destinations: dummyDestinations,
                scrollController: scrollController,
                users: fakeUsers,
                userId: 'anh-tuan-unique-id-1234',
=======
                scheduleLikes: dummyScheduleLikes,
                destinations: dummyDestinations,
                userId: widget.myUser.userId,
                users: Provider.of<UsersProvider>(context, listen: false).users,
>>>>>>> TuanNTA2k
              ),
            );
          case '/map':
            return MaterialPageRoute(builder: (context) => const MapPage());
<<<<<<< HEAD
          case '/account':
            return MaterialPageRoute(builder: (context) => const AccountPage());
=======
>>>>>>> TuanNTA2k
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
<<<<<<< HEAD
=======
      home: BasePage(
        body: screens[currentIndex],
        title: titles[currentIndex],
        currentIndex: currentIndex,
        onTabTapped: onTabTapped,
      ),
>>>>>>> TuanNTA2k
    );
  }
}
