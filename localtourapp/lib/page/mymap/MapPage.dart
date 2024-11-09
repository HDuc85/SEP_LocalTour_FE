import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vietmap_flutter_navigation/vietmap_flutter_navigation.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late MapOptions _navigationOption;
  LatLng? _destinationLocation;
  final _vietmapNavigationPlugin = VietMapNavigationPlugin();
  Widget instructionImage = const SizedBox.shrink();
  Widget recenterButton = const SizedBox.shrink();
  RouteProgressEvent? routeProgressEvent;
  MapNavigationViewController? _navigationController;
  LatLng? _currentLocation;
  int? _destinationMarkerId;
  List<LatLng> destinationLocations = [];
  List<int?> destinationMarkerIds = [];

  @override
  void initState() {
    super.initState();
    _navigationOption = _vietmapNavigationPlugin.getDefaultOptions();
    _navigationOption.simulateRoute = false;
    _navigationOption.apiKey = '9e37b843f972388f80a9e51612cad4c1bc3877c71c107e46';
    _navigationOption.mapStyle = 'https://maps.vietmap.vn/api/maps/light/styles.json?apikey=9e37b843f972388f80a9e51612cad4c1bc3877c71c107e46';

    _getCurrentLocation();
  }
  void _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, handle accordingly
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      setState(() {
        _currentLocation =
        const LatLng(10.759091, 106.675817); // Default location
      });
      return;
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, handle accordingly
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied.')),
        );
        setState(() {
          _currentLocation =
          const LatLng(10.759091, 106.675817); // Default location
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle accordingly
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Location permissions are permanently denied.')),
      );
      setState(() {
        _currentLocation =
        const LatLng(10.759091, 106.675817); // Default location
      });
      return;
    }

    try {
      // Get the current location using the new locationSettings parameter
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      // Handle exceptions, such as timeouts
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error obtaining current location: $e')),
      );
      setState(() {
        _currentLocation =
        const LatLng(10.759091, 106.675817); // Default location
      });
    }
  }
  Future<void> _addMarkers() async {
    if (_navigationController == null) return;

    LatLng currentLocation = _currentLocation ?? const LatLng(10.759091, 106.675817);

    // Add current position marker
    await _navigationController!.addImageMarkers([
      NavigationMarker(
        imagePath: 'assets/icons/marker_start.png',
        latLng: currentLocation,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (_currentLocation == null) {
      // Show a loading indicator or a placeholder while _currentLocation is being fetched
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          NavigationView(
            mapOptions: _navigationOption,
            onMapCreated: (controller) {
              _navigationController = controller;
            },
            onMapRendered: () async {
              // Add markers here
              await _addMarkers();
            },
            onRouteProgressChange: (RouteProgressEvent event) {
              setState(() {
                routeProgressEvent = event;
              });
              _setInstructionImage(
                event.currentModifier,
                event.currentModifierType,
              );
            },
            onMapLongClick: (LatLng? latLng, Point? point) async {
              if (latLng == null) return;

              if (_currentLocation == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Current location not available')),
                );
                return;
              }

              _destinationLocation = latLng;

              // Build the route from the current location to the point the user clicked
              await _navigationController?.buildRoute(
                waypoints: [
                  _currentLocation!,
                  latLng,
                ],
                profile: DrivingProfile.cycling,
              );

              // Remove previous destination marker if it exists
              if (_destinationMarkerId != null) {
                await _navigationController?.removeMarkers([_destinationMarkerId!]);
                _destinationMarkerId = null;
              }

              // Add new destination marker and store its ID
              final List<dynamic>? markerIds = await _navigationController?.addImageMarkers([
                NavigationMarker(
                  imagePath: 'assets/icons/marker_destination.png',
                  latLng: latLng,
                  width: 80,
                  height: 80,
                ),
              ]);

              if (markerIds != null && markerIds.isNotEmpty) {
                _destinationMarkerId = markerIds.first as int?;
              }
            },

            onArrival: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Arrival'),
                  content: const Text('You have arrived at your destination.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        instructionImage = const SizedBox.shrink();
                        routeProgressEvent = null;
                        Navigator.pop(context);
                        setState(() {
                          instructionImage = const SizedBox.shrink();
                          routeProgressEvent = null;
                        });
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
          BannerInstructionView(
            routeProgressEvent: routeProgressEvent,
            instructionIcon: instructionImage,
          ),
          Positioned(
            bottom: 0,
            child: BottomActionView(
              onStopNavigationCallback: () {
                setState(() {
                  instructionImage = const SizedBox.shrink();
                  routeProgressEvent = null;
                });
              },
              recenterButton: recenterButton,
              controller: _navigationController,
              routeProgressEvent: routeProgressEvent,
            ),
          )
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              if (_navigationController != null && _currentLocation != null && _destinationLocation != null) {
                _navigationController!.buildAndStartNavigation(
                  waypoints: [
                    _currentLocation!,
                    _destinationLocation!,
                    _destinationLocation!,
                  ],
                  profile: DrivingProfile.drivingTraffic,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select a destination.')),
                );
              }
            },
            child: const Icon(Icons.navigation),
          ),
          FloatingActionButton(
            onPressed: () {
              // Recenter the map to the current location
              _navigationController?.recenter();
            },
            child: const Icon(Icons.location_on),
          ),
          FloatingActionButton(
            onPressed: _deleteDestination,
            child: const Icon(Icons.delete),
          ),
          const SizedBox(
            height: 100,
          ),
        ],
      ),
    );
  }

  void _deleteDestination() async {
    // Attempt to clear the route and any markers without using IDs
    await _navigationController?.clearRoute(); // Clear any routes
    await _navigationController?.removeAllMarkers(); // Remove all markers, if available

    setState(() {
      _destinationLocation = null;
      instructionImage = const SizedBox.shrink();
      routeProgressEvent = null;
      _destinationMarkerId = null; // Reset marker ID
    });
  }


  void _setInstructionImage(String? modifier, String? type) {
    if (modifier != null && type != null) {
      List<String> data = [
        type.replaceAll(' ', '_'),
        modifier.replaceAll(' ', '_'),
      ];
      String path = 'assets/navigation_symbol/${data.join('_')}.svg';
      setState(() {
        instructionImage = SvgPicture.asset(
          path,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        );
      });
    }
  }
}