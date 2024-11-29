
import 'package:geolocator/geolocator.dart';

class LocationService {
  Position? _currentPosition;

  Future<Position?> getCurrentPosition() async {
    if (_currentPosition != null) {
      return _currentPosition;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if(permission == LocationPermission.deniedForever){
        return null;
      }

      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return null;
      }
    }

    _currentPosition = await Geolocator.getCurrentPosition();
    return _currentPosition;
  }
}
