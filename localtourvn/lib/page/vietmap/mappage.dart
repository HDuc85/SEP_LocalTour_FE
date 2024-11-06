import 'package:flutter/material.dart';
import 'features/map_screen/maps_screen.dart';
import 'features/pick_address_screen/pick_address_screen.dart';
import 'features/routing_screen/routing_screen.dart';
import 'features/routing_screen/search_address.dart';
import 'features/search_screen/search_screen.dart';

class MapPage extends StatelessWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/searchScreen':
            return MaterialPageRoute(builder: (context) => const SearchScreen());
          case '/mapScreen':
            return MaterialPageRoute(builder: (context) => const MapScreen());
          case '/routingScreen':
            return MaterialPageRoute(builder: (context) => const RoutingScreen());
          case '/pickAddressScreen':
            return MaterialPageRoute(builder: (context) => const PickAddressScreen());
          case '/searchAddressForRoutingScreen':
            return MaterialPageRoute(builder: (context) => const SearchAddress());
          default:
            return MaterialPageRoute(builder: (context) => const MapScreen());
        }
      },
      initialRoute: '/mapScreen',
    );
  }
}
