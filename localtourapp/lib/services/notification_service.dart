import 'dart:convert';
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

import '../config/appConfig.dart';
import '../config/secure_storage_helper.dart';

class NotificationService {
  final String baseUrl = 'https://api.localtour.space'; // Corrected API base URL
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final SecureStorageHelper _storage = SecureStorageHelper();

  // Singleton pattern
  NotificationService._privateConstructor();
  static final NotificationService _instance = NotificationService._privateConstructor();
  factory NotificationService() {
    return _instance;
  }

  // Request notification permissions
  Future<void> requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (kDebugMode) {
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('User granted provisional permission');
      } else {
        print('User declined or has not accepted permission');
      }
    }
  }

  // Get device token
  Future<String?> getDeviceToken() async {
    try {
      String? token = await _messaging.getToken();
      if (kDebugMode) {
        print("Device Token: $token");
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
        print("Error obtaining device token: $e");
      }
      return null;
    }
  }

  // Add device token
  Future<bool> addDeviceToken() async {
    String? token = await getDeviceToken();
    if (token == null) {
      if (kDebugMode) {
        print("Device token is null");
      }
      return false;
    }

    final url = Uri.parse('$baseUrl/api/Notification/AddDeviceToken');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await _storage.readValue(AppConfig.accessToken)}', // Updated key
      },
      body: jsonEncode({"token": token}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (kDebugMode) {
        print("Device token added successfully");
      }
      return true;
    } else {
      if (kDebugMode) {
        print("Failed to add device token: ${response.statusCode} ${response.body}");
      }
      return false;
    }
  }

  // Delete device token
  Future<bool> deleteDeviceToken() async {
    String? token = await getDeviceToken();
    if (token == null) {
      if (kDebugMode) {
        print("Device token is null");
      }
      return false;
    }

    final url = Uri.parse('$baseUrl/api/Notification/deleteNotification');
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await _storage.readValue(AppConfig.accessToken)}', // Updated key
      },
      body: jsonEncode({"token": token}),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      if (kDebugMode) {
        print("Device token deleted successfully");
      }
      return true;
    } else {
      if (kDebugMode) {
        print("Failed to delete device token: ${response.statusCode} ${response.body}");
      }
      return false;
    }
  }

  // Optional: Listen to token refresh
  void listenTokenRefresh() {
    _messaging.onTokenRefresh.listen((newToken) async {
      if (kDebugMode) {
        print("New Token: $newToken");
      }
      // Optionally, update the token on your backend
      await addDeviceToken();
    });
  }
}
