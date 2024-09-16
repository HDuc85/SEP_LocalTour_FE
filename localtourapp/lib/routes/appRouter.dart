import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localtourapp/features/home/screens/homeScreen.dart';
// ... import các màn hình khác

final GoRouter router = GoRouter(
  routes: <GoRoute>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return HomeScreen();
      },
    ),
    // ... các route khác
  ],
);
