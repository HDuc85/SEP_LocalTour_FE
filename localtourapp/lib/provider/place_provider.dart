// lib/base/schedule_provider.dart

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:localtourapp/models/places/markplace.dart';
import 'package:localtourapp/models/places/placereport.dart';
import 'package:localtourapp/models/places/placetag.dart';
import 'package:localtourapp/models/places/placetranslation.dart';
import 'package:localtourapp/models/places/place.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlaceProvider with ChangeNotifier {
  // Private lists to hold schedules, likes, destinations, places, and translations
  List<Place> _places = [];
  List<PlaceTranslation> _translations = [];
  List<PlaceTag> _placeTags = [];
  Set<int> _bookmarkedPlaces = {};
  List<MarkPlace> _markPlaces = [];
  List<PlaceReport> _placeReports = [];
  // Constructor to initialize with optional initial data
  PlaceProvider({
    List<Place>? places,
    List<PlaceTranslation>? translations,
    List<PlaceTag>? placeTags,
    List<MarkPlace>? markPlace,
    List<PlaceReport>? placeReport,
  }) {
    _places = places ?? [];
    _translations = translations ?? [];
    _placeTags = placeTags ?? [];
    _markPlaces = markPlace ?? [];
    _placeReports = placeReport ?? [];
  }

  // Getters to access the private lists
  List<Place> get places => _places;
  List<PlaceTranslation> get translations => _translations;
  List<PlaceTag> get placeTags => _placeTags;
  List<int> get bookmarkedPlaceIds => _bookmarkedPlaces.toList();
  List<MarkPlace> get markPlaces => _markPlaces;
  List<PlaceReport> get placeReports => _placeReports;

  // ----------------------------

  void addPlaceReport(PlaceReport report) {
    _placeReports.add(report);
    notifyListeners();
  }

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
  // Retrieve place details by placeId
  Place? getPlaceById(int placeId) {
    return _places.firstWhereOrNull((place) => place.placeId == placeId);
  }

  // Retrieve place translation by placeId
  PlaceTranslation? getTranslationByPlaceId(int placeId) {
    return _translations.firstWhereOrNull((t) => t.placeId == placeId);
  }

  PlaceTranslation? getPlaceTranslationById(int id) {
    try {
      return _translations.firstWhere((placeTranslation) => placeTranslation.placeTranslationId == id);
    } catch (e) {
      // If no place is found with the given ID, return null
      return null;
    }
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

  bool isBookmarked(int placeId) {
    return _bookmarkedPlaces.contains(placeId);
  }

  Future<void> addBookmark(MarkPlace markPlace) async {
    _bookmarkedPlaces.add(markPlace.placeId);
    _markPlaces.add(markPlace);
    await _saveToPreferences();
    notifyListeners();
  }

  Future<void> removeBookmark(int placeId) async {
    _bookmarkedPlaces.remove(placeId);
    _markPlaces.removeWhere((mp) => mp.placeId == placeId);
    await _saveToPreferences();
    notifyListeners();
  }

  Future<void> loadBookmarks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Deserialize bookmarked place IDs
    List<String>? savedBookmarks = prefs.getStringList('bookmarkedPlaces');
    if (savedBookmarks != null) {
      try {
        _bookmarkedPlaces.addAll(savedBookmarks.map(int.parse));
      } catch (e) {
        print('Error parsing bookmarkedPlaceIds: $e');
      }
    }

    // Deserialize markPlaces
    List<String>? savedMarkPlaces = prefs.getStringList('markPlaces');
    if (savedMarkPlaces != null) {
      List<MarkPlace> parsedMarkPlaces = [];

      for (String str in savedMarkPlaces) {
        if (str.trim().startsWith('{')) {
          // JSON format
          try {
            Map<String, dynamic> json = jsonDecode(str);
            MarkPlace mp = MarkPlace.fromJson(json);
            parsedMarkPlaces.add(mp);
          } catch (e) {
            print('Failed to parse MarkPlace as JSON: $str, error: $e');
          }
        } else {
          // Assume pipe-delimited string
          List<String> parts = str.split('|');
          if (parts.length >= 4) { // Adjust based on previous format
            try {
              MarkPlace mp = MarkPlace(
                markPlaceId: parts.length >= 1 ? int.parse(parts[0]) : 0,
                userId: parts.length >= 2 ? parts[1] : 'unknown',
                placeId: parts.length >= 3 ? int.parse(parts[2]) : 0,
                createdDate: parts.length >= 4 ? DateTime.parse(parts[3]) : DateTime.now(),
                isVisited: parts.length >= 5 ? (parts[4].toLowerCase() == 'true') : false,
              );
              parsedMarkPlaces.add(mp);
            } catch (e) {
              print('Failed to parse MarkPlace as pipe-delimited string: $str, error: $e');
            }
          } else {
            print('Invalid MarkPlace format: $str');
          }
        }
      }

      if (parsedMarkPlaces.isNotEmpty) {
        _markPlaces.addAll(parsedMarkPlaces);
        notifyListeners();

        // Migrate to JSON by re-serializing and saving back
        List<String> newSerializedMarkPlaces = _markPlaces.map((mp) => jsonEncode(mp.toJson())).toList();
        await prefs.setStringList('markPlaces', newSerializedMarkPlaces);
        print('Data migration to JSON completed.');
      }
    }

    notifyListeners();
  }

  Future<void> _saveToPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Serialize bookmarked place IDs
    List<String> bookmarkedIds = _bookmarkedPlaces.map((id) => id.toString()).toList();
    await prefs.setStringList('bookmarkedPlaces', bookmarkedIds);

    // Serialize markPlaces as JSON strings
    List<String> serializedMarkPlaces = _markPlaces.map((mp) => jsonEncode(mp.toJson())).toList();
    await prefs.setStringList('markPlaces', serializedMarkPlaces);
  }

  Future<void> toggleVisited(int placeId) async {
    int index = _markPlaces.indexWhere((mp) => mp.placeId == placeId);
    if (index != -1) {
      _markPlaces[index].isVisited = !_markPlaces[index].isVisited;
      await _saveToPreferences();
      notifyListeners();
    }
  }
}
