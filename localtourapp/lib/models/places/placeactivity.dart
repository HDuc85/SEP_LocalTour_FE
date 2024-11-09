import 'dart:math';

import 'place.dart';

class PlaceActivity {
  final int id;
  final int placeId;
  final int displayNumber;
  final String? photoDisplay;

  PlaceActivity({
    required this.id,
    required this.placeId,
    required this.displayNumber,
    this.photoDisplay,
  });

  factory PlaceActivity.fromJson(Map<String, dynamic> json) {
    return PlaceActivity(
      id: json['id'],
      placeId: json['placeId'],
      displayNumber: json['displayNumber'],
      photoDisplay: json['photoDisplay'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'placeId': placeId,
      'displayNumber': displayNumber,
      'photoDisplay': photoDisplay,
    };
  }
}

// Function to generate random PlaceActivity data
List<PlaceActivity> generatePlaceActivities(int count, List<Place> places) {
  final random = Random();
  List<PlaceActivity> placeActivities = [];

  for (int i = 0; i < count; i++) {
    int id = i + 1; // Sequential id
    // Select a random place from the provided places list
    int placeId = places[random.nextInt(places.length)].placeId;
    int displayNumber = random.nextInt(10); // Random display number between 0 and 9
    String? photoDisplay = random.nextBool() // Randomly decide if there is a photo
        ? 'https://picsum.photos/200/300?random=$id'
        : null; // Random photo URL or null

    PlaceActivity placeActivity = PlaceActivity(
      id: id,
      placeId: placeId,
      displayNumber: displayNumber,
      photoDisplay: photoDisplay,
    );

    placeActivities.add(placeActivity);
  }

  return placeActivities;
}

  List<PlaceActivity> randomActivities = generatePlaceActivities(1000, dummyPlaces);

