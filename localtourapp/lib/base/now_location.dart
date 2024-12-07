import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class NowLocation extends StatefulWidget {
  const NowLocation({super.key});

  @override
  State<NowLocation> createState() => _NowLocationState();
}

class _NowLocationState extends State<NowLocation> {
  String _location = 'Fetching location...';
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    var status = await Permission.location.status;
    if (status.isDenied || status.isRestricted) {
      // You can request the permission
      if (await Permission.location.request().isGranted) {
        // Either the permission was already granted before or the user just granted it.
        _getCurrentPosition();
      } else {
        // Handle the case when the user denies the permission
        setState(() {
          _location = 'Location permissions are denied';
        });
      }
    } else if (status.isGranted) {
      _getCurrentPosition();
    } else {
      // Handle other status cases if needed
    }
  }

  Future<void> _getCurrentPosition() async {
    try {
      LocationSettings locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high, // Set the desired accuracy
        distanceFilter: 100,
        timeLimit: Duration(seconds: 10),
      );

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      setState(() {
        _currentPosition = position;
        _location = '${position.latitude}, ${position.longitude}';
      });
    } catch (e) {
      setState(() {
        _location = 'Unable to fetch current location';
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_currentPosition != null) {
          Navigator.pushNamed(
            context,
            '/map', // Assuming '/map' is your route name for MapPage
            arguments: {
              'latitude': _currentPosition!.latitude,
              'longitude': _currentPosition!.longitude,
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location not available")),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(top: 30),
        padding: const EdgeInsets.all(10),
        color: Colors.white,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your location',
                style: TextStyle(color: Colors.black, fontSize: 11),
              ),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.red),
                  Expanded( // Add Expanded to prevent overflow
                    child: Text(
                      _location,
                      style: const TextStyle(color: Colors.black, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ),

      ),
    );
  }
}