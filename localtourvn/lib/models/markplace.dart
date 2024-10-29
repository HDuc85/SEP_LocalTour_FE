import 'dart:math';

import 'places/place.dart';

class MarkPlace {
  int markPlaceId;
  String userId;
  int placeId;
  DateTime createdDate;
  bool isVisited;

  MarkPlace({
    required this.markPlaceId,
    required this.userId,
    required this.placeId,
    required this.createdDate,
    required this.isVisited,
  });

  factory MarkPlace.fromJson(Map<String, dynamic> json) => MarkPlace(
    markPlaceId: json['markPlaceId'] as int,
    userId: json['userId'] as String,
    placeId: json['placeId'] as int,
    createdDate: DateTime.parse(json['createdDate'] as String),
    isVisited: json['isVisited'] as bool,
  );

  Map<String, dynamic> toJson() => {
    'markPlaceId': markPlaceId,
    'userId': userId,
    'placeId': placeId,
    'createdDate': createdDate.toIso8601String(),
    'isVisited': isVisited,
  };
}

// Function to generate random MarkPlace data
List<MarkPlace> generateMarkPlaces(int count, List<Place> places) {
  final random = Random();
  List<MarkPlace> markPlaces = [];

  for (int i = 0; i < count; i++) {
    int markPlaceId = i + 1; // Sequential markPlaceId
    String userId = '1'; // Fixed user ID as a string
    // Select a random place from the provided places list
    int placeId = places[random.nextInt(places.length)].placeId;
    DateTime createdDate = DateTime.now().subtract(Duration(days: random.nextInt(30))); // Created within the last 30 days
    bool isVisited = random.nextBool(); // Random true or false

    MarkPlace markPlace = MarkPlace(
      markPlaceId: markPlaceId,
      userId: userId,
      placeId: placeId,
      createdDate: createdDate,
      isVisited: isVisited,
    );

    markPlaces.add(markPlace);
  }

  return markPlaces;
}

  List<Place> dummyPlaces = generateDummyPlaces(40);
  List<MarkPlace> markPlaces = generateMarkPlaces(10, dummyPlaces);
