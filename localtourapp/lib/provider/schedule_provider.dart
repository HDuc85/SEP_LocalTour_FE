// lib/base/schedule_provider.dart

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:localtourapp/models/places/placetag.dart';
import 'package:localtourapp/models/places/placetranslation.dart';
import 'package:localtourapp/models/schedule/schedule.dart';
import 'package:localtourapp/models/schedule/schedulelike.dart';
import 'package:localtourapp/models/schedule/destination.dart';
import 'package:localtourapp/models/places/place.dart';

class ScheduleProvider with ChangeNotifier {
  // Private lists to hold schedules, likes, destinations, places, and translations
  List<Schedule> _schedules = [];
  List<ScheduleLike> _scheduleLikes = [];
  List<Destination> _destinations = [];
  List<Place> _places = [];
  List<PlaceTranslation> _translations = [];
  List<PlaceTag> _placeTags = [];

  // Constructor to initialize with optional initial data
  ScheduleProvider({
    List<Schedule>? schedules,
    List<ScheduleLike>? scheduleLikes,
    List<Destination>? destinations,
    List<Place>? places,
    List<PlaceTranslation>? translations,
    List<PlaceTag>? placeTags,
  }) {
      _schedules = schedules ?? [];
      _scheduleLikes = scheduleLikes ?? [];
      _destinations = destinations ?? [];
      _places = places ?? [];
      _translations = translations ?? [];
      _placeTags = placeTags ?? [];
  }

  // Getters to access the private lists
  List<Schedule> get schedules => _schedules;
  List<ScheduleLike> get scheduleLikes => _scheduleLikes;
  List<Destination> get destinations => _destinations;
  List<Place> get places => _places;
  List<PlaceTranslation> get translations => _translations;
  List<PlaceTag> get placeTags => _placeTags;

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

  List<Destination> getDestinationsByUserId(String userId) {
    // Step 1: Get all schedules for the user
    List<Schedule> userSchedules = getSchedulesByUserId(userId);

    // Step 2: Extract scheduleIds
    Set<int> userScheduleIds = userSchedules.map((schedule) => schedule.id).toSet();

    // Step 3: Get all destinations linked to these scheduleIds
    return _destinations.where((dest) => userScheduleIds.contains(dest.scheduleId)).toList();
  }

  // Retrieve a schedule by its ID
  Schedule? getScheduleById(int id) {
    return _schedules.firstWhereOrNull((schedule) => schedule.id == id);
  }


  List<Schedule> getSchedulesByUserId(String userId) {
    return _schedules.where((schedule) => schedule.userId == userId).toList();
  }

  List<ScheduleLike> getScheduleLikesByUserId(String userId) {
    return _scheduleLikes.where((like) => like.userId == userId).toList();
  }
  // Add a schedule like
  void addScheduleLike(ScheduleLike scheduleLike) {
    _scheduleLikes.add(scheduleLike);
    notifyListeners();
  }

  void removeScheduleLike(int scheduleId, String userId) {
    _scheduleLikes.removeWhere(
          (like) => like.scheduleId == scheduleId && like.userId == userId,
    );
    notifyListeners();
  }

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

  // Method to update isArrived for a destination
  void toggleIsArrived(int destinationId) {
    final index = _destinations.indexWhere((dest) => dest.id == destinationId);
    if (index != -1) {
      _destinations[index].isArrived = !_destinations[index].isArrived;
      notifyListeners();
    }
  }

  // Retrieve all likes for a specific schedule
  List<ScheduleLike> getLikesForSchedule(int scheduleId) {
    return _scheduleLikes.where((like) => like.scheduleId == scheduleId).toList();
  }

  List<Destination> getFilteredDestinations(int scheduleId) {
    return destinations.where((destination) => destination.scheduleId == scheduleId).toList();
  }

  // Retrieve all destinations for a specific schedule
  List<Destination> getDestinationsForSchedule(int scheduleId) {
    return _destinations.where((dest) => dest.scheduleId == scheduleId).toList();
  }

  // Retrieve place details by placeId
  Place? getPlaceById(int placeId) {
    return _places.firstWhereOrNull((place) => place.placeId == placeId);
  }


  String getPlaceName(int placeId, String languageCode) {
    // Retrieve the Place object using placeId
    final Place? place = getPlaceById(placeId);
    if (place == null) {
      return 'Unknown Place'; // Fallback if Place is not found
    }

    // Retrieve the PlaceTranslation for the given languageCode
    final PlaceTranslation? translation = getTranslationByPlaceIdAndLanguage(placeId, languageCode);
    if (translation == null) {
      return 'Unknown Place'; // Fallback if Translation is not found
    }

    return translation.placeName; // Return the translated place name
  }


  String? getScheduleNameById(int scheduleId) {
    return schedules.firstWhereOrNull((s) => s.id == scheduleId)?.scheduleName;
  }

  // Method to add a place tag relationship
  void addPlaceTag(PlaceTag placeTag) {
    _placeTags.add(placeTag);
    notifyListeners();
  }

  // Method to remove a place tag relationship by its ID
  void removePlaceTag(int placeTagId) {
    _placeTags.removeWhere((pt) => pt.placeTagId == placeTagId);
    notifyListeners();
  }

  // Method to retrieve all tag IDs for a given placeId
  List<int> getTagsForPlace(int placeId) {
    return _placeTags
        .where((pt) => pt.placeId == placeId)
        .map((pt) => pt.tagId)
        .toList();
  }

  // Method to retrieve all places that match user preferred tags
  List<Place> getPlacesForUserPreferences(List<int> userTagIds) {
    if (userTagIds.isEmpty) {
      // If user has no preferred tags, return all places
      return _places;
    }

    // Return places that have at least one tag matching the user's preferences
    return _places.where((place) {
      final placeTags = getTagsForPlace(place.placeId);
      return placeTags.any((tagId) => userTagIds.contains(tagId));
    }).toList();
  }

  // Method to retrieve the place translation for a given placeId and language code
  PlaceTranslation? getTranslationByPlaceIdAndLanguage(int placeId, String languageCode) {
    return _translations.firstWhereOrNull(
          (translation) => translation.placeId == placeId && translation.languageCode == languageCode,
    );
  }

  /// Retrieves the photo URL for a given [placeId].
  /// If the [photoDisplay] is invalid or empty, returns a default image URL.
  String getPhotoDisplay(int placeId) {
    // Define your default image URL or asset path
    const String defaultImageUrl = 'https://example.com/default_image.png';
    // Retrieve the Place object
    final Place? place = getPlaceById(placeId);
    if (place == null) {
      // If place is not found, return the default image
      return defaultImageUrl; // Or defaultAssetImagePath if using local assets
    }

    // Validate the photoDisplay
    if (place.photoDisplay.isNotEmpty) {
      // Check if photoDisplay is a valid URL
      if (Uri.tryParse(place.photoDisplay)?.hasAbsolutePath ?? false) {
        return place.photoDisplay;
      } else {
        // Assume it's a local asset path
        return place.photoDisplay;
      }
    } else {
      // Fallback to default image if photoDisplay is empty
      return defaultImageUrl; // Or defaultAssetImagePath if using local assets
    }
  }

  void updatePlace(int id, Place updatedPlace) {
    final index = _places.indexWhere((place) => place.placeId == id);
    if (index != -1) {
      _places[index] = updatedPlace;
      notifyListeners();
    }
  }

}
