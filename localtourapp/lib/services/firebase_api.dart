import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:localtourapp/main.dart';

import '../page/home_screen/notification_page.dart';

Future<void> handleBackGroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print("Title: ${message.notification?.title}");
    print("Body: ${message.notification?.body}");
  }
}

class FireBaseAPI {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final _androidChannel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This Channel is used for important notification',
    importance: Importance.high,
  );
  final _localNotifications = FlutterLocalNotificationsPlugin();
  // Handle messages
  void handleMessage(RemoteMessage? message) {
    if (message == null) return;

    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => NotificationPage(message: message),
      ),
    );
  }

  // Initialize push notifications
  Future<void> initPushNotifications() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackGroundMessage);
    FirebaseMessaging.onMessage.listen((message){
      final notification = message.notification;
      _localNotifications.show(
        notification.hashCode,
        notification?.title,
        notification?.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            icon: '@drawable/ic_launcher',
          )
        ),
          payload: jsonEncode(message.toMap())
      );
    });
  }

  Future initLocalNotifications() async {
    const iOS  = DarwinInitializationSettings();
    const android = AndroidInitializationSettings('@drawable/ic_launcher');
    const settings = InitializationSettings(android: android, iOS: DarwinInitializationSettings());

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (payload) {
        final message = RemoteMessage.fromMap(jsonDecode(payload as String));
        handleMessage(message);
      }
    );
    final platform = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidChannel);
  }

  // Initialize notifications and fetch FCM token
  Future<void> initNotification() async {
    await _firebaseMessaging.requestPermission();

    final fcmToken = await _firebaseMessaging.getToken();
    if (kDebugMode) {
      print("Token: $fcmToken");
    }
    initPushNotifications();
    initLocalNotifications();
  }
}
