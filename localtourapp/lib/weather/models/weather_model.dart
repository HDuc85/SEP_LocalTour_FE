// lib/weather/models/weather_model.dart

class WeatherResponse {
  final CurrentWeather current;
  final HourlyWeather hourly;
  final DailyWeather daily;

  WeatherResponse({
    required this.current,
    required this.hourly,
    required this.daily,
  });

  factory WeatherResponse.fromJson(Map<String, dynamic> json) {
    return WeatherResponse(
      current: CurrentWeather.fromJson(json['current_weather']),
      hourly: HourlyWeather.fromJson(json['hourly']),
      daily: DailyWeather.fromJson(json['daily']),
    );
  }
}

class CurrentWeather {
  final double temperature;
  final double windspeed;
  final int winddirection;
  final int weathercode;
  final bool isDay;
  final String time;

  CurrentWeather({
    required this.temperature,
    required this.windspeed,
    required this.winddirection,
    required this.weathercode,
    required this.isDay,
    required this.time,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: (json['temperature'] as num).toDouble(),
      windspeed: (json['windspeed'] as num).toDouble(),
      winddirection: json['winddirection'] as int,
      weathercode: json['weathercode'] as int,
      isDay: json['is_day'] == 1,
      time: json['time'] as String,
    );
  }
}

class HourlyWeather {
  final List<String> time;
  final List<double> temperature2m;
  final List<double> rain;
  final List<int> weathercode;

  HourlyWeather({
    required this.time,
    required this.temperature2m,
    required this.rain,
    required this.weathercode,
  });

  factory HourlyWeather.fromJson(Map<String, dynamic> json) {
    return HourlyWeather(
      time: List<String>.from(json['time']),
      temperature2m:
      List<double>.from(json['temperature_2m'].map((x) => (x as num).toDouble())),
      rain: List<double>.from(json['rain'].map((x) => (x as num).toDouble())),
      weathercode: List<int>.from(json['weathercode']),
    );
  }
}

class DailyWeather {
  final List<String> time;
  final List<int> weathercode;

  DailyWeather({
    required this.time,
    required this.weathercode,
  });

  factory DailyWeather.fromJson(Map<String, dynamic> json) {
    return DailyWeather(
      time: List<String>.from(json['time']),
      weathercode: List<int>.from(json['weathercode']),
    );
  }
}
