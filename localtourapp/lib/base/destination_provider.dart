// lib/base/destination_provider.dart

import 'package:flutter/material.dart';
import 'package:localtourapp/models/schedule/destination.dart';

class DestinationProvider with ChangeNotifier {
  List<Destination> _destinations = [];

  List<Destination> get destinations => _destinations;

  void addDestination(Destination destination) {
    _destinations.add(destination);
    notifyListeners();
  }

  void removeDestination(int destinationId) {
    _destinations.removeWhere((d) => d.id == destinationId);
    notifyListeners();
  }

  void removeDestinationsByScheduleId(int scheduleId) {
    _destinations.removeWhere((d) => d.scheduleId == scheduleId);
    notifyListeners();
  }
}
