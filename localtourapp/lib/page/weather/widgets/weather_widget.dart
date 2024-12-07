// lib/weather/widgets/weather_widget.dart

import 'package:flutter/material.dart';

import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../weather_detail_page.dart';

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
  WeatherService _service = WeatherService();
  late WeatherResponse weatherResponse;
  bool isloading = true;
  @override
  void initState() {
    super.initState();
    // Fetch weather data after the first frame is rendered
    fetchInit();
  }

  Future<void> fetchInit() async {
    var response = await _service.fetchWeather(latitude: widget.latitude, longitude: widget.longitude);
    setState(() {
      weatherResponse = response!;
      isloading = false;
    });
  }

  String getWeatherDescription(int code) {
    switch (code) {
      case 0:
        return 'Clear Sky';
      case 1:
      case 2:
      case 3:
        return 'Mainly Clear';
      case 45:
      case 48:
        return 'Fog';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rain';
      case 71:
      case 73:
      case 75:
        return 'Snow';
      case 80:
      case 81:
      case 82:
        return 'Rain Showers';
      case 95:
      case 96:
      case 99:
        return 'Thunderstorm';
      default:
        return 'Unknown';
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


        return
          isloading ? SizedBox() :
          Card(
          elevation: 4,
          margin: const EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Weather Title and Icon
                Row(
                  children: [
                    Text(
                      'Current Weather',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    Text(
                      getWeatherIcon(weatherResponse.current.weathercode),
                      style: TextStyle(fontSize: 24),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                // Temperature
                Text(
                  '${weatherResponse.current.temperature.toStringAsFixed(1)}°C',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                // Weather Description
                Text(
                  getWeatherDescription(weatherResponse.current.weathercode),
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                // Additional Weather Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Wind Speed
                    Column(
                      children: [
                        Icon(Icons.wind_power),
                        SizedBox(height: 5),
                        Text('${weatherResponse.current.windspeed} m/s'),
                        Text('Wind Speed'),
                      ],
                    ),
                    // Day/Night Indicator
                    Column(
                      children: [
                        Icon(
                          weatherResponse.current.isDay ? Icons.wb_sunny : Icons.nights_stay,
                        ),
                        SizedBox(height: 5),
                        Text(weatherResponse.current.isDay ? 'Day' : 'Night'),
                      ],
                    ),
                    // Weather Code
                    Column(
                      children: [
                        Icon(Icons.cloud),
                        SizedBox(height: 5),
                        Text('${weatherResponse.current.weathercode}'),
                        Text('Code'),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                // Weather Advice
                Text(
                  'Advice: ${weatherResponse.current.weathercode >= 61 && weatherResponse.current.weathercode <= 65 ? "Take an umbrella!" : "Enjoy your day!"}',
                  style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                ),
                SizedBox(height: 10),
                // Navigate to Detailed Forecast
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WeatherDetailPage(
                          hourlyWeather: weatherResponse.hourly,
                        ),
                      ),
                    );
                  },
                  child: Text('View Hourly Forecast'),
                ),
              ],
            ),
          ),
        );
  }
}
