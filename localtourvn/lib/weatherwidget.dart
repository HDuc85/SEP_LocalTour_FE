import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  String weatherDescription = "Loading weather...";
  double currentTemperature = 0.0;
  String advice = "Loading advice...";

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  // Function to fetch weather data from OpenWeatherMap API
  Future<void> fetchWeather() async {
    String apiKey = 'YOUR_API_KEY'; // Replace with your actual API key
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=${widget.latitude}&lon=${widget.longitude}&units=metric&appid=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        weatherDescription = data['weather'][0]['description'];
        currentTemperature = data['main']['temp'];
        advice = _getAdvice(weatherDescription, currentTemperature);
      });
    } else {
      setState(() {
        weatherDescription = "Unable to fetch weather";
        advice = "No advice available";
      });
    }
  }

  // Function to generate advice based on weather conditions and temperature
  String _getAdvice(String weather, double temperature) {
    if (weather.contains("rain")) {
      return "It's raining. Take an umbrella!";
    } else if (weather.contains("clear")) {
      return temperature > 25
          ? "It's sunny and warm, perfect for outdoor activities."
          : "It's sunny but a bit cool, dress warmly.";
    } else if (weather.contains("clouds")) {
      return "It's cloudy, a good day for indoor activities.";
    } else {
      return "Current weather is $weather. Make sure to dress appropriately.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/icons/weather.png',  // Path to your asset icon
            width: 30,  // Set the width of the icon
            height: 30, // Set the height of the icon
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Weather: $weatherDescription",
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                "Current temperature: ${currentTemperature.toStringAsFixed(1)}°C",
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                advice,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
