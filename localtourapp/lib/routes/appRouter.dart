import 'package:flutter/material.dart';
import 'package:localtourapp/page/bookmark/bookmark_page.dart';
import '../features/home/screens/homeScreen.dart';

class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case '/bookmark':
        return MaterialPageRoute(builder: (_) => BookmarkPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('404: Page not found')),
          ),
        );
    }
  }
}
