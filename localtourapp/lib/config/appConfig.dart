import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static final String apiUrl = dotenv.env['API_BASE_URL'] ?? '';
  static final String authUrl = dotenv.env['AUTH_URL'] ?? '';

  static const String accessToken = 'accesstoken';
  static const String refreshToken = 'refreshtoken';

  static final String fireBaseProjectId =
      dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
  static final String fireBaseProjectNumber =
      dotenv.env['FIREBASE_PROJECT_NUMBER'] ?? '';
  static final String fireBaseApiKey = dotenv.env['FIREBASE_API_KEY'] ?? '';

  static const int requestTimeout = 30; // Request timeout in seconds

  static const String appName = 'localtourapp';
  static const String appVersion = '1.0.0';
  static const String language = 'languageCode';
  static const String userId = 'userid';
  static const String isLogin = 'isLogin';
  static const String deviceId = 'deviceId';
  static const String isFirstLogin = 'isFirstLogin';
}
