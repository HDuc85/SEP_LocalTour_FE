
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../models/places/markplace.dart';


class BookmarkProvider extends ChangeNotifier {
  final Set<int> _bookmarkedPlaces = {};
  final List<MarkPlace> _markPlaces = [];

  List<int> get bookmarkedPlaceIds => _bookmarkedPlaces.toList();
  List<MarkPlace> get markPlaces => _markPlaces;

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
