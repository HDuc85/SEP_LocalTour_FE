import 'dart:math';
import 'place.dart'; // Assuming you have the Place class defined

class PlaceMedia {
  int placeMediaId;
  int placeId; // Maps with placeId in Place
  String type; // Either "Video" or "Photo"
  String placeMediaUrl; // URL for the media
  DateTime createDate;

  PlaceMedia({
    required this.placeMediaId,
    required this.placeId,
    required this.type,
    required this.placeMediaUrl,
    required this.createDate,
  });

  factory PlaceMedia.fromJson(Map<String, dynamic> json) => PlaceMedia(
    placeMediaId: json['placeMediaId'] as int,
    placeId: json['placeId'] as int,
    type: json['type'] as String,
    placeMediaUrl: json['mediaUrl'] as String,
    createDate: DateTime.parse(json['createDate'] as String),
  );

  Map<String, dynamic> toJson() => {
    'placeMediaId': placeMediaId,
    'placeId': placeId,
    'type': type,
    'mediaUrl': placeMediaUrl,
    'createDate': createDate.toIso8601String(),
  };
}

// Function to generate random PlaceMedia data
List<PlaceMedia> generatePlaceMediaForAllPlaces(List<Place> places) {
  final random = Random();
  List<String> mediaTypes = ['Photo'];
  List<PlaceMedia> placeMedias = [];

  for (var place in places) {
    // Decide how many media items this place will have (e.g., 10 to 15)
    int mediaCount = random.nextInt(6) + 10; // Generates a number between 10 and 15

    for (int i = 0; i < mediaCount; i++) {
      int placeMediaId = placeMedias.length + 1; // Unique ID for each media item
      String type = mediaTypes[random.nextInt(mediaTypes.length)];

      String placeMediaUrl = 'https://picsum.photos/seed/${random.nextInt(1000)}/600/400';

      DateTime createDate = DateTime.now().subtract(Duration(days: random.nextInt(30)));

      PlaceMedia placeMedia = PlaceMedia(
        placeMediaId: placeMediaId,
        placeId: place.placeId,
        type: type,
        placeMediaUrl: placeMediaUrl,
        createDate: createDate,
      );

      placeMedias.add(placeMedia);
    }
  }
  return placeMedias;
}

  List<PlaceMedia> mediaList = generatePlaceMediaForAllPlaces(dummyPlaces);
