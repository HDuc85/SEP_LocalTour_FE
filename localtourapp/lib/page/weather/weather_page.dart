import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/appConfig.dart';
import '../../config/secure_storage_helper.dart';
import 'providers/weather_provider.dart';
import 'widgets/weather_card.dart';
import 'weather_detail_page.dart';
import 'package:geolocator/geolocator.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({Key? key}) : super(key: key);

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  String _languageCode = 'vi';

  Future<void> fetchLanguageCode() async {
    var languageCode = await SecureStorageHelper().readValue(AppConfig.language);
    setState(() {
      _languageCode = languageCode!;    });
  }

  @override
  Widget build(BuildContext context) {
    // Provide the WeatherProvider to the widget tree
    return ChangeNotifierProvider(
      create: (_) => WeatherProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_languageCode == 'vi' ? "Thời tiết":'Weather'),
        ),
        body: WeatherContent(),
      ),
    );
  }
}

class WeatherContent extends StatefulWidget {
  @override
  _WeatherContentState createState() => _WeatherContentState();
}

class _WeatherContentState extends State<WeatherContent> {
  Position? _position;
  String _languageCode = 'vi';

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> fetchLanguageCode() async {
    var languageCode = await SecureStorageHelper().readValue(AppConfig.language);
    setState(() {
      _languageCode = languageCode!;    });
  }

  Future<void> _fetchWeather() async {
    try {
      // Check and request location permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_languageCode == 'vi' ? "Dịch vụ định vị đã bị vô hiệu hóa.":'Location services are disabled.')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_languageCode == 'vi' ? "Quyền vị trí bị từ chối":'Location permissions are denied')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied, we cannot request permissions.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_languageCode == 'vi' ? "Quyền vị trí bị từ chối vĩnh viễn, chúng tôi không thể yêu cầu quyền.":
                  'Location permissions are permanently denied, we cannot request permissions.')),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _position = position;
      });

      Provider.of<WeatherProvider>(context, listen: false).fetchWeather(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      print('Error fetching position: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_languageCode == 'vi' ? "Lỗi khi tìm vị trí:":'Error fetching position: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        if (weatherProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (weatherProvider.errorMessage != null) {
          return Center(child: Text(weatherProvider.errorMessage!));
        }

        if (weatherProvider.weatherResponse == null) {
          return Center(child: Text(_languageCode == 'vi' ? "Không có dữ liệu thời tiết.":'No weather data available.'));
        }

        final currentWeather = weatherProvider.weatherResponse!.current;

        return SingleChildScrollView(
          child: Column(
            children: [
              WeatherCard(currentWeather: currentWeather),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WeatherDetailPage(
                        hourlyWeather: weatherProvider.weatherResponse!.hourly,
                      ),
                    ),
                  );
                },
                child: Text(_languageCode == 'vi' ? "Xem Dự báo hàng giờ":'View Hourly Forecast', style: const TextStyle(color: Colors.black),),
              ),
            ],
          ),
        );
      },
    );
  }
}
