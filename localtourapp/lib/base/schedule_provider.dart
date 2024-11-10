// lib/base/schedule_provider.dart

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:localtourapp/models/places/placetranslation.dart';
import 'package:localtourapp/models/schedule/schedule.dart';
import 'package:localtourapp/models/schedule/schedulelike.dart';
import 'package:localtourapp/models/schedule/destination.dart';
import 'package:localtourapp/models/places/place.dart';

class ScheduleProvider with ChangeNotifier {
  // Private lists to hold schedules, likes, destinations, places, and translations
  List<Schedule> _schedules = dummySchedules;
  List<ScheduleLike> _scheduleLikes = dummyScheduleLikes;
  List<Destination> _destinations = dummyDestinations;
  List<Place> _places = dummyPlaces;
  List<PlaceTranslation> _translations = dummyTranslations;

  // Constructor to initialize with optional initial data
  ScheduleProvider({
    List<Schedule>? initialSchedules,
    List<ScheduleLike>? initialScheduleLikes,
    List<Destination>? initialDestinations,
    List<Place>? initialPlaces,
    List<PlaceTranslation>? initialTranslations,
  }) {
    if (initialSchedules != null) {
      _schedules = initialSchedules;
    }
    if (initialScheduleLikes != null) {
      _scheduleLikes = initialScheduleLikes;
    }
    if (initialDestinations != null) {
      _destinations = initialDestinations;
    }
    if (initialPlaces != null) {
      _places = initialPlaces;
    }
    if (initialTranslations != null) {
      _translations = initialTranslations;
    }
  }

  // Getters to access the private lists
  List<Schedule> get schedules => _schedules;
  List<ScheduleLike> get scheduleLikes => _scheduleLikes;
  List<Destination> get destinations => _destinations;
  List<Place> get places => _places;
  List<PlaceTranslation> get translations => _translations;

  // --------------------------
  // Methods to Manage Schedules
  // --------------------------

  // Add a new schedule
  void addSchedule(Schedule schedule) {
    _schedules.add(schedule);
    notifyListeners();
  }

  // Remove a schedule by its ID
  void removeSchedule(int scheduleId) {
    _schedules.removeWhere((schedule) => schedule.id == scheduleId);
    // Also remove associated likes and destinations
    _scheduleLikes.removeWhere((like) => like.scheduleId == scheduleId);
    _destinations.removeWhere((dest) => dest.scheduleId == scheduleId);
    notifyListeners();
  }

  // Update an existing schedule
  void updateSchedule(Schedule updatedSchedule) {
    int index = _schedules.indexWhere((s) => s.id == updatedSchedule.id);
    if (index != -1) {
      _schedules[index] = updatedSchedule;
      notifyListeners();
    }
  }

  // Retrieve a schedule by its ID
  Schedule? getScheduleById(int id) {
    return _schedules.firstWhereOrNull((schedule) => schedule.id == id);
  }

  // ----------------------------
  // Methods to Manage Schedule Likes
  // ----------------------------

  // Add a schedule like
  void addScheduleLike(ScheduleLike scheduleLike) {
    _scheduleLikes.add(scheduleLike);
    notifyListeners();
  }

  // Remove a schedule like based on scheduleId and userId
  void removeScheduleLike(int scheduleId, String userId) {
    _scheduleLikes.removeWhere(
            (like) => like.scheduleId == scheduleId && like.userId == userId);
    notifyListeners();
  }

  // ----------------------------
  // Methods to Manage Destinations
  // ----------------------------

  // Add a new destination
  void addDestination(Destination destination) {
    _destinations.add(destination);
    notifyListeners();
  }

  // Remove a destination by its ID
  void removeDestination(int destinationId) {
    _destinations.removeWhere((dest) => dest.id == destinationId);
    notifyListeners();
  }

  // Update an existing destination
  void updateDestination(Destination updatedDestination) {
    int index = _destinations.indexWhere((d) => d.id == updatedDestination.id);
    if (index != -1) {
      _destinations[index] = updatedDestination;
      notifyListeners();
    }
  }

  // Retrieve a destination by its ID
  Destination? getDestinationById(int id) {
    return _destinations.firstWhereOrNull((dest) => dest.id == id);
  }

  // ----------------------------
  // Methods to Manage Places and Translations
  // ----------------------------

  // Add a new place
  void addPlace(Place place) {
    _places.add(place);
    notifyListeners();
  }

  // Remove a place by its ID
  void removePlace(int placeId) {
    _places.removeWhere((place) => place.placeId == placeId);
    notifyListeners();
  }

  // Add a new place translation
  void addPlaceTranslation(PlaceTranslation translation) {
    _translations.add(translation);
    notifyListeners();
  }

  // Remove a place translation by placeId
  void removePlaceTranslation(int placeId) {
    _translations.removeWhere((t) => t.placeId == placeId);
    notifyListeners();
  }

  // ----------------------------
  // Additional Utility Methods
  // ----------------------------

  // Retrieve all likes for a specific schedule
  List<ScheduleLike> getLikesForSchedule(int scheduleId) {
    return _scheduleLikes.where((like) => like.scheduleId == scheduleId).toList();
  }

  // Retrieve all destinations for a specific schedule
  List<Destination> getDestinationsForSchedule(int scheduleId) {
    return _destinations.where((dest) => dest.scheduleId == scheduleId).toList();
  }

  // Retrieve place details by placeId
  Place? getPlaceById(int placeId) {
    return _places.firstWhereOrNull((place) => place.placeId == placeId);
  }

  // Retrieve place translation by placeId
  PlaceTranslation? getTranslationByPlaceId(int placeId) {
    return _translations.firstWhereOrNull((t) => t.placeId == placeId);
  }
}
