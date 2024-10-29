import 'dart:math';

import '../tag.dart';
import 'place.dart';

// Define PlaceTag class to map Place and Tag
class PlaceTag {
  int placeTagId;
  int placeId; // Maps to placeId in Place
  int tagId; // Maps to tagId in Tag

  PlaceTag({
    required this.placeTagId,
    required this.placeId,
    required this.tagId,
  });

  // Factory constructor to create a PlaceTag from JSON
  factory PlaceTag.fromJson(Map<String, dynamic> json) {
    return PlaceTag(
      placeTagId: json['placeTagId'],
      placeId: json['placeId'],
      tagId: json['tagId'],
    );
  }

  // Method to convert PlaceTag to JSON
  Map<String, dynamic> toJson() {
    return {
      'placeTagId': placeTagId,
      'placeId': placeId,
      'tagId': tagId,
    };
  }
}

// Function to generate 100 random PlaceTag objects
List<PlaceTag> generatePlaceTags(int count, List<Place> places, List<Tag> tags) {
  final random = Random();
  List<PlaceTag> placeTags = [];

  for (int i = 0; i < count; i++) {
    int placeTagId = i + 1; // Sequential placeTagId
    // Randomly select a placeId from 1 to 40 (assuming there are 40 places)
    int placeId = places[random.nextInt(places.length)].placeId;
    // Randomly select a tagId from 1 to 12 (assuming there are 12 tags)
    int tagId = tags[random.nextInt(tags.length)].tagId;

    PlaceTag placeTag = PlaceTag(
      placeTagId: placeTagId,
      placeId: placeId,
      tagId: tagId,
    );

    placeTags.add(placeTag);
  }

  return placeTags;
}

List<PlaceTag> placeTags = generatePlaceTags(100, dummyPlaces, listTag);

