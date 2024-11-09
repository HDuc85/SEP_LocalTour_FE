// lib/weather/widgets/weather_card.dart

import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class WeatherCard extends StatelessWidget {
  final CurrentWeather currentWeather;

  const WeatherCard({Key? key, required this.currentWeather}) : super(key: key);

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
    return Card(
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
                  getWeatherIcon(currentWeather.weathercode),
                  style: TextStyle(fontSize: 24),
                ),
              ],
            ),
            SizedBox(height: 10),
            // Temperature
            Text(
              '${currentWeather.temperature.toStringAsFixed(1)}°C',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            // Weather Description
            Text(
              getWeatherDescription(currentWeather.weathercode),
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
                    Text('${currentWeather.windspeed} m/s'),
                    Text('Wind Speed'),
                  ],
                ),
                // Day/Night Indicator
                Column(
                  children: [
                    Icon(
                      currentWeather.isDay ? Icons.wb_sunny : Icons.nights_stay,
                    ),
                    SizedBox(height: 5),
                    Text(currentWeather.isDay ? 'Day' : 'Night'),
                  ],
                ),
                // Weather Code
                Column(
                  children: [
                    Icon(Icons.cloud),
                    SizedBox(height: 5),
                    Text('${currentWeather.weathercode}'),
                    Text('Code'),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            // Weather Advice
            Text(
              'Advice: ${currentWeather.weathercode >= 61 && currentWeather.weathercode <= 65 ? "Take an umbrella!" : "Enjoy your day!"}',
              style: TextStyle(fontSize: 16, color: Colors.blueGrey),
            ),
          ],
        ),
      ),
    );
  }
}
