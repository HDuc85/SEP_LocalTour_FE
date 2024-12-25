import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../config/appConfig.dart';
import '../../../config/secure_storage_helper.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../weather_detail_page.dart';
import 'weather_card.dart'; // Ensure this import points to the WeatherCard file

class WeatherWidget extends StatefulWidget {
  final double latitude;
  final double longitude;

  const WeatherWidget({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  _WeatherWidgetState createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  String _languageCode = 'vi';
  final WeatherService _service = WeatherService();
  WeatherResponse? weatherResponse;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchInit();
  }

  Future<void> fetchLanguageCode() async {
    var languageCode = await SecureStorageHelper().readValue(AppConfig.language);
    setState(() {
      _languageCode = languageCode ?? 'vi';
    });
  }

  Future<void> fetchInit() async {
    try {
      await fetchLanguageCode();
      var response = await _service.fetchWeather(
        latitude: widget.latitude,
        longitude: widget.longitude,
      );
      if (response != null) {
        setState(() {
          weatherResponse = response;
          isLoading = false;
          hasError = false;
        });
      } else {
        throw Exception("Failed to fetch weather data");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
      // Optionally, log the error or show a message
      if (kDebugMode) {
        print('Weather fetch error: $e');
      }
    }
  }

  String getWeatherDescription(int code) {
    switch (code) {
      case 0:
        return _languageCode == 'vi' ? 'Trời quang' : 'Clear Sky';
      case 1:
      case 2:
      case 3:
        return _languageCode == 'vi' ? 'Trời trong' : 'Mainly Clear';
      case 45:
      case 48:
        return _languageCode == 'vi' ? 'Sương mù' : 'Fog';
      case 51:
      case 53:
      case 55:
        return _languageCode == 'vi' ? 'Mưa phùn' : 'Drizzle';
      case 61:
      case 63:
      case 65:
        return _languageCode == 'vi' ? 'Mưa' : 'Rain';
      case 71:
      case 73:
      case 75:
        return _languageCode == 'vi' ? 'Tuyết' : 'Snow';
      case 80:
      case 81:
      case 82:
        return _languageCode == 'vi' ? 'Mưa rào' : 'Rain Showers';
      case 95:
      case 96:
      case 99:
        return _languageCode == 'vi' ? 'Dông bão' : 'Thunderstorm';
      default:
        return _languageCode == 'vi' ? 'Không xác định' : 'Unknown';
    }
  }

  String getWeatherIcon(int code) {
    if (code == 0) {
      return '☀️'; // Clear Sky
    } else if (code >= 1 && code <= 3) {
      return '🌤️'; // Mainly Clear to Partly Cloudy
    } else if (code >= 45 && code <= 48) {
      return '🌫️'; // Fog
    } else if (code >= 51 && code <= 55) {
      return '🌦️'; // Drizzle
    } else if (code >= 61 && code <= 65) {
      return '🌧️'; // Rain
    } else if (code >= 71 && code <= 75) {
      return '❄️'; // Snow
    } else if (code >= 80 && code <= 82) {
      return '🌦️'; // Rain Showers
    } else if (code >= 95 && code <= 99) {
      return '⛈️'; // Thunderstorm
    } else {
      return '❓'; // Unknown Weather Code
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (hasError || weatherResponse == null) {
      return Center(
        child: Text(
          _languageCode == 'vi'
              ? 'Không thể tải dữ liệu thời tiết.'
              : 'Unable to load weather data.',
          style: const TextStyle(fontSize: 16, color: Colors.red),
        ),
      );
    }

    return WeatherCard(
      currentWeather: weatherResponse!.current,
      onViewDetails: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WeatherDetailPage(
              hourlyWeather: weatherResponse!.hourly,
            ),
          ),
        );
      },
    );
  }
}
