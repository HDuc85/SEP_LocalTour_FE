import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../../config/appConfig.dart';
import '../../config/secure_storage_helper.dart';

class NotificationPage extends StatefulWidget {
  final RemoteMessage? message;

  const NotificationPage({
    Key? key, this.message,
  }) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  String _languageCode = 'vi';

  @override
  void initState() {
    super.initState();
    fetchLanguageCode();
  }

  Future<void> fetchLanguageCode() async {
    var languageCode = await SecureStorageHelper().readValue(AppConfig.language);
    setState(() {
      _languageCode = languageCode ?? 'en';
    });
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    return Scaffold(
      appBar: AppBar(
        title: Text(_languageCode == 'vi' ? "Thông báo" : "Notification"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message?.notification?.title ?? 'No Title',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              message?.notification?.body ?? 'No Message',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              jsonEncode(message?.data),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
