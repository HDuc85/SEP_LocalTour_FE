import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService = WeatherService();

  WeatherResponse? _weatherResponse;
  bool _isLoading = false;
  String? _errorMessage;

  WeatherResponse? get weatherResponse => _weatherResponse;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchWeather({required double latitude, required double longitude}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      WeatherResponse? response = await _weatherService.fetchWeather(
        latitude: latitude,
        longitude: longitude,
        timezone: 'Asia/Bangkok',
      );

      if (response != null) {
        _weatherResponse = response;
      } else {
        _errorMessage = 'Failed to fetch weather data';
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
    }

    _isLoading = false;
    notifyListeners();
  }
}
