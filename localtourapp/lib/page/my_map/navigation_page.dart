import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:localtourapp/config/appConfig.dart';
import 'package:localtourapp/services/location_Service.dart';
import 'package:vietmap_flutter_navigation/models/options.dart';
import 'package:vietmap_flutter_navigation/navigation_plugin.dart';
import 'package:vietmap_flutter_navigation/vietmap_flutter_navigation.dart';

class NavigationPage extends StatefulWidget{
  final double lat;
  final double long;
  const NavigationPage (
      {Key? key,
        required this.lat,
        required this.long}) : super(key: key);

  @override
  State<StatefulWidget> createState()  => _NavigationState();
}
class _NavigationState extends State<NavigationPage>{
  final LocationService _locationService = LocationService();
  late MapOptions _navigationOption;
  Position? _currentPosition;
  final _vietmapNavigationPlugin = VietMapNavigationPlugin();

  List<LatLng> waypoints = [];
  Widget instructionImage = const SizedBox.shrink();

  Widget recenterButton = const SizedBox.shrink();

  RouteProgressEvent? routeProgressEvent;

  MapNavigationViewController? _navigationController;



  @override
  void initState() {
    super.initState();
    initialize();
    _getCurrentPosition();
  }

  Future<void> _getCurrentPosition() async {
    Position? position = await _locationService.getCurrentPosition();
    double long = position != null ? position.longitude : 106.8096761;
    double lat = position != null ? position.latitude : 10.8411123;
    if (position != null) {
     setState(() {
       _currentPosition = position;
     });
    } else {
      setState(() {
        _currentPosition = new Position(longitude: long,
            latitude: lat,
            timestamp: DateTime.timestamp(),
            accuracy: 1,
            altitude: 1,
            altitudeAccuracy: 1,
            heading: 1,
            headingAccuracy: 1,
            speed: 1,
            speedAccuracy: 1);
      });
    }

    _navigationController?.buildRoute(waypoints: [
      LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      LatLng(widget.lat, widget.long)
    ], profile: DrivingProfile.cycling);
    setState(() {

    });

  }

      Future<void> initialize() async {
    if (!mounted) return;
    _navigationOption = _vietmapNavigationPlugin.getDefaultOptions();
    /// set the simulate route to true to test the navigation without the real location
    _navigationOption.simulateRoute = false;

    _navigationOption.apiKey = AppConfig.vietMapApiKey;
    _navigationOption.mapStyle = AppConfig.vietMapStyleUrl;

    _vietmapNavigationPlugin.setDefaultOptions(_navigationOption);
  }

  @override
  void dispose() {
    _navigationController?.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return
        Stack(
          children: [
            NavigationView(
              mapOptions: _navigationOption,
              onMapCreated: (controller) {
                _navigationController = controller;
              },
              onRouteProgressChange: (RouteProgressEvent routeProgressEvent) {
                setState(() {
                  this.routeProgressEvent = routeProgressEvent;
                });
                _setInstructionImage(routeProgressEvent.currentModifier,
                    routeProgressEvent.currentModifierType);
              },
              onMapClick: (LatLng? latLng, Point? point) {
                if (latLng == null) return;

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
            ),
            Positioned(
              right: 10,
              bottom: 100,
              child: Column(
                children: [
                  FloatingActionButton(
                    mini: true,
                    child: const Icon(Icons.directions),
                    onPressed: () {
                    _navigationController?.startNavigation();
                  },),
                  FloatingActionButton(
                    mini: true,
                    child: const Icon(Icons.alt_route),
                    onPressed: () {
                      _navigationController?.overview();
                    },),
                  FloatingActionButton(
                    mini: true,
                    child: const Icon(Icons.gps_fixed),
                    onPressed: () {
                      _navigationController?.recenter();
                    },),
                  FloatingActionButton(
                    mini: true,
                    child: const Icon(Icons.close),
                    onPressed: () {
                      _searchFocusNode.unfocus();
                      Navigator.pop(context);
                    },),
                ],
              ),
            )
          ],
        );

  }

  _setInstructionImage(String? modifier, String? type) {
    if (modifier != null && type != null) {
      List<String> data = [
        type.replaceAll(' ', '_'),
        modifier.replaceAll(' ', '_')
      ];
      String path = 'assets/navigation_symbol/${data.join('_')}.svg';
      setState(() {
        instructionImage = SvgPicture.asset(path, color: Colors.white);
      });
    }
  }

}