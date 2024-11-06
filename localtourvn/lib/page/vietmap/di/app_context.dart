import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppContext {
  static final AppContext _singleton = AppContext._internal();

  factory AppContext() {
    return _singleton;
  }
  AppContext._internal();

  // Corrected: Use the variable name 'VIETMAP_API_KEY'
  static String getVietmapAPIKey() {
    if (!dotenv.isInitialized) {
      throw NotInitializedError();
    }
    final apiKey = dotenv.env['VIETMAP_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('VIETMAP_API_KEY is missing or empty in .env file.');
    }
    return apiKey;
  }

  static String getVietmapBaseUrl() {
    return 'https://maps.vietmap.vn/api/';
  }

  // Corrected: Use the variable name 'VIETMAP_MAP_STYLE_URL'
  static String getVietmapMapStyleUrl() {
    if (!dotenv.isInitialized) {
      throw NotInitializedError();
    }
    final url = dotenv.env['VIETMAP_MAP_STYLE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception(
          'VIETMAP_MAP_STYLE_URL is missing or empty in .env file.');
    }
    return url;
  }
}

class NotInitializedError extends Error {
  @override
  String toString() =>
      'DotEnv is not initialized. Ensure dotenv.load() is called before accessing environment variables.';
}
