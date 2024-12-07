import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  final String baseUrl = 'https://api.open-meteo.com/v1/forecast';

  Future<WeatherResponse?> fetchWeather({
    required double latitude,
    required double longitude,
    String timezone = 'Asia/Bangkok',
  }) async {
    final uri = Uri.parse(baseUrl).replace(queryParameters: {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'current_weather': 'true',
      'hourly': 'temperature_2m,rain,weathercode',
      'daily': 'weathercode',
      'timezone': timezone,
    });

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return WeatherResponse.fromJson(jsonData);
      } else {
        if (kDebugMode) {
          print('Failed to load weather data: ${response.statusCode}');
        }
        if (kDebugMode) {
          print('Response body: ${response.body}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching weather data: $e');
      }
      return null;
    }
  }
}
