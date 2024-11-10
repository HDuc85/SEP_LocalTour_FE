import 'dart:math';

// Assuming you have these classes and imports
import '../users/users.dart';
import 'place.dart';

class PlaceFeedback {
  final int placeFeedbackId;
  final int placeId; // Maps to placeId in Place
  final String userId; // GUID stored as String
  final double rating; //Random from 0-5
  final String? content; // Nullable field
  final DateTime createdAt;
  final DateTime? updatedAt;

  PlaceFeedback({
    required this.placeFeedbackId,
    required this.placeId,
    required this.userId,
    required this.rating,
    this.content, // Nullable
    required this.createdAt,
    this.updatedAt,
  });

  // Factory method to create a PlaceFeedback object from JSON
  factory PlaceFeedback.fromJson(Map<String, dynamic> json) {
    return PlaceFeedback(
      placeFeedbackId: json['placeFeedbackId'],
      placeId: json['placeId'],
      userId: json['userId'], // GUID stored as a String
      rating: json['rating'].toDouble(),
      content: json['content'], // Nullable field
      createdAt: DateTime.parse(json['createdDate']),
      updatedAt: DateTime.parse(json['createdDate']),
    );
  }

  // Method to convert a PlaceFeedback object to JSON
  Map<String, dynamic> toJson() {
    return {
      'placeFeedbackId': placeFeedbackId,
      'placeId': placeId,
      'userId': userId, // GUID stored as String
      'rating': rating,
      'content': content, // Nullable field
      'createdDate': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

// Function to generate random PlaceFeedback data
List<PlaceFeedback> generatePlaceFeedbacks(int count, List<Place> places, List<User> users) {

  final random = Random();
  List<PlaceFeedback> feedbacks = [];
  int placeFeedbackId = 1; // Sequential placeFeedbackId

  // Set to track existing (userId, placeId) pairs to prevent duplicates
  Set<String> existingFeedbacks = {};

  // Generate feedbacks with random distribution across places
  for (int i = 0; i < count; i++) {
    int placeId = places[random.nextInt(places.length)].placeId; // Random placeId

    String userId = users[random.nextInt(users.length)].userId; // Random userId
    String key = '$userId-$placeId';

    if (existingFeedbacks.contains(key)) {
      continue; // Avoid duplicate feedback for same user and place
    }

    double rating = (random.nextDouble() * 4 + 1).roundToDouble(); // Random rating 1-5
    String? content = random.nextBool() ? 'Great place to visit! ($placeId)' : null;
    DateTime createdDate = DateTime.now().subtract(Duration(days: random.nextInt(30)));
    DateTime updatedAt = DateTime.now().subtract(Duration(days: random.nextInt(60)));

    feedbacks.add(PlaceFeedback(
      placeFeedbackId: placeFeedbackId++,
      placeId: placeId,
      userId: userId,
      rating: rating,
      content: content,
      createdAt: createdDate,
      updatedAt: updatedAt,
    ));

    existingFeedbacks.add(key);

  }

  return feedbacks;

}


//Usage

List<PlaceFeedback> feedbacks = generatePlaceFeedbacks(500, dummyPlaces, fakeUsers);
