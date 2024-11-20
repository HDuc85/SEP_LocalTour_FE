import 'package:flutter/material.dart';
import 'models/weather_model.dart';

class WeatherDetailPage extends StatelessWidget {
  final HourlyWeather hourlyWeather;

  const WeatherDetailPage({Key? key, required this.hourlyWeather}) : super(key: key);

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hourly Forecast'),
      ),
      body: Container(
        color: Colors.white, // Set the background color to white
        child: ListView.separated(
          itemCount: hourlyWeather.time.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Text(
                getWeatherIcon(hourlyWeather.weathercode[index]),
                style: const TextStyle(fontSize: 24),
              ),
              title: Text('${hourlyWeather.time[index]}'),
              subtitle: Text(
                  'Temp: ${hourlyWeather.temperature2m[index].toStringAsFixed(1)}°C, Rain: ${hourlyWeather.rain[index].toStringAsFixed(1)} mm'),
            );
          },
          separatorBuilder: (context, index) => const Divider(
            thickness: 1, // Thickness of the divider line
            color: Colors.grey, // Color of the divider line
            height: 1, // Space around the divider line
          ),
        ),
      ),
    );
  }
}
