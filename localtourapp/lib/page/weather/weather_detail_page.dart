import 'package:flutter/material.dart';
import '../../config/appConfig.dart';
import '../../config/secure_storage_helper.dart';
import 'models/weather_model.dart';

class WeatherDetailPage extends StatefulWidget {
  final HourlyWeather hourlyWeather;

  const WeatherDetailPage({Key? key, required this.hourlyWeather}) : super(key: key);

  @override
  _WeatherDetailPageState createState() => _WeatherDetailPageState();
}

class _WeatherDetailPageState extends State<WeatherDetailPage> {
  String _languageCode = 'vi';

  @override
  void initState() {
    super.initState();
    fetchLanguageCode();
  }

  Future<void> fetchLanguageCode() async {
    var languageCode = await SecureStorageHelper().readValue(AppConfig.language);
    setState(() {
      _languageCode = languageCode ?? 'vi';
    });
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _languageCode == 'vi' ? 'Dự báo theo giờ' : 'Hourly Forecast',
        ),
      ),
      body: ListView.builder(
        itemCount: widget.hourlyWeather.time.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Text(
              getWeatherIcon(widget.hourlyWeather.weathercode[index]),
              style: const TextStyle(fontSize: 24),
            ),
            title: Text(widget.hourlyWeather.time[index]),
            subtitle: Text(
              _languageCode == 'vi'
                  ? 'Nhiệt độ: ${widget.hourlyWeather.temperature2m[index].toStringAsFixed(1)}°C, Mưa: ${widget.hourlyWeather.rain[index].toStringAsFixed(1)} mm'
                  : 'Temp: ${widget.hourlyWeather.temperature2m[index].toStringAsFixed(1)}°C, Rain: ${widget.hourlyWeather.rain[index].toStringAsFixed(1)} mm',
            ),
          );
        },
      ),
    );
  }
}
