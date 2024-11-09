import 'dart:math';

class TraveledPlace {
  int traveledPlaceId;
  String userId;
  int placeId;
  DateTime timeArrive;

  TraveledPlace({
    required this.traveledPlaceId,
    required this.userId,
    required this.placeId,
    required this.timeArrive,
  });

  factory TraveledPlace.fromJson(Map<String, dynamic> json) => TraveledPlace(
    traveledPlaceId: json['traveledPlaceId'] as int,
    userId: json['userId'] as String,
    placeId: json['placeId'] as int,
    timeArrive: DateTime.parse(json['timeArrive'] as String),
  );

  Map<String, dynamic> toJson() => {
    'traveledPlaceId': traveledPlaceId,
    'userId': userId,
    'placeId': placeId,
    'timeArrive': timeArrive.toIso8601String(),
  };
}

// Function to generate random TraveledPlace data with a timeArrive from any date in the past
List<TraveledPlace> generateDummyTraveledPlaces(int count, int maxPlaceId) {
  final random = Random();
  List<TraveledPlace> traveledPlaces = [];

  // Define the maximum range (e.g., the past 10 years = 3650 days)
  int maxDaysInPast = 365 * 10; // Adjust this value for the range you want

  for (int i = 0; i < count; i++) {
    int traveledPlaceId = i + 1; // Sequential traveledPlaceId
    String userId = (i + 1).toString(); // User ID as a string based on the index
    int placeId = i + 1; // Sequential placeId
    DateTime timeArrive = DateTime.now().subtract(Duration(days: random.nextInt(maxDaysInPast))); // Time of arrival within the past 10 years

    TraveledPlace traveledPlace = TraveledPlace(
      traveledPlaceId: traveledPlaceId,
      userId: userId,
      placeId: placeId,
      timeArrive: timeArrive,
    );

    traveledPlaces.add(traveledPlace);
  }

  return traveledPlaces;
}

// Usage
List<TraveledPlace> dummyTraveledPlaces = generateDummyTraveledPlaces(20, 40);

