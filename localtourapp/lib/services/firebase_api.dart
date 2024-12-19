import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:localtourapp/services/event_service.dart';
import 'package:localtourapp/services/location_Service.dart';

import '../constants/getListApi.dart';
import '../models/event/event_model.dart';
import '../page/detail_page/event_detail_page.dart';

Future<void> handleBackGroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print("Title: ${message.notification?.title}");
    print("Body: ${message.notification?.body}");
  }
}

class FireBaseAPI {
  late BuildContext appContext;
  final EventService eventService = EventService();
  final LocationService _locationService = LocationService();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final _androidChannel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This Channel is used for important notification',
    importance: Importance.high,
  );
  final _localNotifications = FlutterLocalNotificationsPlugin();
  // Handle messages
  void handleMessage(RemoteMessage? message, BuildContext context) async {
    if (message == null) return;

    // Fetch the event details using the eventId from the notification
    var eventId = int.tryParse(message.data['eventId'] ?? '');
    var placeId = int.parse(message.data['placeId'].toString());
    if (eventId != null) {
      Position? position = await _locationService.getCurrentPosition();
      double long = position != null ? position.longitude : 106.8096761;
      double lat = position != null ? position.latitude : 10.8411123;

      eventService.getEventInPlace(placeId, lat, long, SortOrder.asc, SortBy.distance).then((events) {

        var eventModel = events.firstWhere((element) => element.eventId == eventId,);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EventDetailPage(eventModel: eventModel),
            ),
          );
      }).catchError((e) {
        debugPrint("Error fetching event details: $e");
      });
    }
  }

  // Initialize push notifications
  Future<void> initPushNotifications(BuildContext context) async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      handleMessage(message, context);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      handleMessage(message, context);
    });

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
      handleMessage(message, context);
    });
  }

  Future initLocalNotifications(BuildContext context) async {
    const iOS  = DarwinInitializationSettings();
    const android = AndroidInitializationSettings('@drawable/ic_launcher');
    const settings = InitializationSettings(android: android, iOS: DarwinInitializationSettings());

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (payload) {
        final message = RemoteMessage.fromMap(jsonDecode(payload as String));
        handleMessage(message, appContext);
      }
    );
    final platform = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidChannel);
  }

  // Initialize notifications and fetch FCM token
  Future<void> initNotification(BuildContext context) async {
    await _firebaseMessaging.requestPermission();

    final fcmToken = await _firebaseMessaging.getToken();
    if (kDebugMode) {
      print("Token: $fcmToken");
    }
    await initPushNotifications(context);
    await initLocalNotifications(context);
  }
}
