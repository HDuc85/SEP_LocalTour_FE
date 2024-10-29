import 'dart:math';

// Assuming you have these classes and imports
import 'place.dart';
import '../../users/users.dart';

class PlaceFeedback {
  final int placeFeedbackId;
  final int placeId; // Maps to placeId in Place
  final String userId; // GUID stored as String
  final double rating; // Fixed at 4.5
  final String? content; // Nullable field
  final DateTime createdDate;

  PlaceFeedback({
    required this.placeFeedbackId,
    required this.placeId,
    required this.userId,
    required this.rating,
    this.content, // Nullable
    required this.createdDate,
  });

  // Factory method to create a PlaceFeedback object from JSON
  factory PlaceFeedback.fromJson(Map<String, dynamic> json) {
    return PlaceFeedback(
      placeFeedbackId: json['placeFeedbackId'],
      placeId: json['placeId'],
      userId: json['userId'], // GUID stored as a String
      rating: json['rating'].toDouble(),
      content: json['content'], // Nullable field
      createdDate: DateTime.parse(json['createdDate']),
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
      'createdDate': createdDate.toIso8601String(),
    };
  }
}

// Function to generate random PlaceFeedback data
List<PlaceFeedback> generatePlaceFeedbacks(
    int count, List<Place> places, List<User> users) {
  final random = Random();
  List<PlaceFeedback> feedbacks = [];
  int placeFeedbackId = 1; // Sequential placeFeedbackId

  // Set to track existing (userId, placeId) pairs to prevent duplicates
  Set<String> existingFeedbacks = {};

  int attempts = 0;
  int maxAttempts = count * 10; // Prevent infinite loops

  while (feedbacks.length < count && attempts < maxAttempts) {
    attempts++;

    // Randomly select a placeId from the provided Place list
    int placeId = places[random.nextInt(places.length)].placeId;

    // Randomly select a userId from the provided Users list
    String userId = users[random.nextInt(users.length)].userId;

    // Create a unique key for the combination of userId and placeId
    String key = '$userId-$placeId';

    // Check if this user has already given feedback for this place
    if (existingFeedbacks.contains(key)) {
      continue; // Skip this iteration and try again
    }

    // Fixed rating at 4.5
    double rating = 4.5;

    // Optionally generate feedback content (nullable)
    String? content = random.nextBool() ? 'Great place to visit!' : null;

    // Randomly generate a createdDate within the past 30 days
    DateTime createdDate =
    DateTime.now().subtract(Duration(days: random.nextInt(30)));

    PlaceFeedback feedback = PlaceFeedback(
      placeFeedbackId: placeFeedbackId++,
      placeId: placeId,
      userId: userId,
      rating: rating,
      content: content,
      createdDate: createdDate,
    );

    feedbacks.add(feedback);
    existingFeedbacks.add(key);
  }

  // Check if we were unable to generate enough unique feedbacks
  if (feedbacks.length < count) {
    print(
        'Warning: Only ${feedbacks.length} unique feedbacks could be generated.');
  }

  return feedbacks;
}
//Usage

List<PlaceFeedback> feedbacks = generatePlaceFeedbacks(400, dummyPlaces, fakeUsers);
