import 'package:flutter/material.dart';
import '../../../config/appConfig.dart';
import '../../../config/secure_storage_helper.dart';
import '../models/weather_model.dart';

class WeatherCard extends StatefulWidget {
  final CurrentWeather currentWeather;
  final VoidCallback onViewDetails;

  const WeatherCard({
    Key? key,
    required this.currentWeather,
    required this.onViewDetails,
  }) : super(key: key);

  @override
  _WeatherCardState createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
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
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: widget.onViewDetails,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Weather Title and Icon
              Row(
                children: [
                  Text(
                    _languageCode == 'vi' ? 'Thời tiết hiện tại' : 'Current Weather',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    getWeatherIcon(widget.currentWeather.weathercode),
                    style: const TextStyle(fontSize: 30),
                  ),
                ],
              ),
              // Temperature
              Text(
                '${widget.currentWeather.temperature.toStringAsFixed(1)}°C',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w300,
                  color: Colors.pinkAccent,
                ),
              ),
              // Weather Description
              Text(
                getWeatherDescription(widget.currentWeather.weathercode),
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              // Additional Weather Details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Wind Speed
                  _WeatherDetailItem(
                    icon: Icons.wind_power,
                    label: _languageCode == 'vi' ? "Tốc độ gió" : 'Wind Speed',
                    value: '${widget.currentWeather.windspeed} m/s',
                    iconColor: Colors.blue,
                  ),
                  // Day/Night Indicator
                  _WeatherDetailItem(
                    icon: widget.currentWeather.isDay ? Icons.wb_sunny : Icons.nights_stay,
                    label: widget.currentWeather.isDay
                        ? (_languageCode == 'vi' ? 'Ban ngày' : 'Day')
                        : (_languageCode == 'vi' ? 'Ban đêm' : 'Night'),
                    value: '',
                    iconColor: widget.currentWeather.isDay ? Colors.orange : Colors.blueGrey,
                  ),
                ],
              ),
              // Weather Advice
              Text(
                _languageCode == 'vi'
                    ? (widget.currentWeather.weathercode >= 61 && widget.currentWeather.weathercode <= 65
                    ? "Mang theo ô!"
                    : "Tận hưởng ngày mới của bạn!")
                    : (widget.currentWeather.weathercode >= 61 && widget.currentWeather.weathercode <= 65
                    ? "Take an umbrella!"
                    : "Enjoy your day!"),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.blueGrey,
                ),
              ),
              // Navigate to Detailed Forecast
              ElevatedButton(
                onPressed: widget.onViewDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Text(
                  _languageCode == 'vi' ? "Xem Dự báo hàng giờ" : 'View Hourly Forecast',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeatherDetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const _WeatherDetailItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor = Colors.pinkAccent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 28),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
