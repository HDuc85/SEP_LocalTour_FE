import 'package:flutter/material.dart';
import '../../config/appConfig.dart';
import '../../config/secure_storage_helper.dart';
import 'models/weather_model.dart';
import 'package:weather_icons/weather_icons.dart';

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

  IconData getWeatherIcon(int code) {
    if (code == 0) {
      return WeatherIcons.day_sunny;
    } else if (code >= 1 && code <= 3) {
      return WeatherIcons.day_cloudy;
    } else if (code >= 45 && code <= 48) {
      return WeatherIcons.fog;
    } else if (code >= 51 && code <= 55) {
      return WeatherIcons.sprinkle;
    } else if (code >= 61 && code <= 65) {
      return WeatherIcons.rain;
    } else if (code >= 71 && code <= 75) {
      return WeatherIcons.snow;
    } else if (code >= 80 && code <= 82) {
      return WeatherIcons.showers;
    } else if (code >= 95 && code <= 99) {
      return WeatherIcons.thunderstorm;
    } else {
      return WeatherIcons.na;
    }
  }

  Color getWeatherColor(int code) {
    if (code == 0) {
      return Colors.orangeAccent;
    } else if (code >= 1 && code <= 3) {
      return Colors.blueGrey.shade700;
    } else if (code >= 45 && code <= 48) {
      return Colors.grey.shade700;
    } else if (code >= 51 && code <= 55) {
      return Colors.blue.shade300;
    } else if (code >= 61 && code <= 65) {
      return Colors.blue.shade700;
    } else if (code >= 71 && code <= 75) {
      return Colors.lightBlueAccent;
    } else if (code >= 80 && code <= 82) {
      return Colors.blue.shade500;
    } else if (code >= 95 && code <= 99) {
      return Colors.deepPurple;
    } else {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _languageCode == 'vi' ? 'Dự báo theo giờ' : 'Hourly Forecast',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.teal.shade700,
        elevation: 0,
        centerTitle: true,
      ),
      body: widget.hourlyWeather.time.isEmpty
          ? Center(
        child: Text(
          _languageCode == 'vi' ? "Không có dữ liệu dự báo." : 'No forecast data available.',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: widget.hourlyWeather.time.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              color: getWeatherColor(widget.hourlyWeather.weathercode[index]).withOpacity(0.1),
              child: InkWell(
                onTap: () {
                  // Optionally, handle tap to show more details
                },
                borderRadius: BorderRadius.circular(15),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Weather Icon
                      Icon(
                        getWeatherIcon(widget.hourlyWeather.weathercode[index]),
                        size: 40,
                        color: getWeatherColor(widget.hourlyWeather.weathercode[index]),
                      ),
                      const SizedBox(width: 20),
                      // Time and Description
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.hourlyWeather.time[index],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: Colors.teal.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              getWeatherDescription(widget.hourlyWeather.weathercode[index]),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.teal.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Temperature and Rain
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${widget.hourlyWeather.temperature2m[index].toStringAsFixed(1)}°C',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _languageCode == 'vi'
                                ? 'Mưa: ${widget.hourlyWeather.rain[index].toStringAsFixed(1)} mm'
                                : 'Rain: ${widget.hourlyWeather.rain[index].toStringAsFixed(1)} mm',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.teal.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
