import 'dart:math';
import '../users/users.dart';
import 'placefeedback.dart';

class PlaceFeedbackHelpful {
  final int placeFeedbackHelpfulId;
  final String userId; // GUID as String
  final int placeFeedbackId; // Maps to placeFeedbackId in PlaceFeedback
  final DateTime createdDate;

  PlaceFeedbackHelpful({
    required this.placeFeedbackHelpfulId,
    required this.userId,
    required this.placeFeedbackId,
    required this.createdDate,
  });

  // Factory method to create a PlaceFeedbackHelpful object from JSON
  factory PlaceFeedbackHelpful.fromJson(Map<String, dynamic> json) {
    return PlaceFeedbackHelpful(
      placeFeedbackHelpfulId: json['placeFeedbackHelpfulId'],
      userId: json['userId'], // GUID as String
      placeFeedbackId: json['placeFeedbackId'],
      createdDate: DateTime.parse(json['createdDate']),
    );
  }

  // Method to convert a PlaceFeedbackHelpful object to JSON
  Map<String, dynamic> toJson() {
    return {
      'placeFeedbackHelpfulId': placeFeedbackHelpfulId,
      'userId': userId, // GUID as String
      'placeFeedbackId': placeFeedbackId,
      'createdDate': createdDate.toIso8601String(),
    };
  }
}

// Function to generate random PlaceFeedbackHelpful data
List<PlaceFeedbackHelpful> generatePlaceFeedbackHelpfuls(
    int count, List<PlaceFeedback> feedbacks, List<User> users) {
  final random = Random();
  List<PlaceFeedbackHelpful> feebBackHelpfuls = [];
  int placeFeedbackHelpfulId = 1; // Initialize the helpful ID counter

  // Use a Set to track unique combinations of userId and placeFeedbackId
  Set<String> existingHelpfuls = {};

  while (feebBackHelpfuls.length < count) {
    // Randomly select a PlaceFeedback
    PlaceFeedback selectedFeedback =
    feedbacks[random.nextInt(feedbacks.length)];
    int placeFeedbackId = selectedFeedback.placeFeedbackId;

    // Get the userId of the selected feedback
    String feedbackUserId = selectedFeedback.userId;

    // Create a list of users excluding the one who wrote the feedback
    List<User> otherUsers =
    users.where((user) => user.userId != feedbackUserId).toList();

    // If no other users are available, break the loop
    if (otherUsers.isEmpty) {
      break;
    }

    // Randomly select a userId from otherUsers
    String userId = otherUsers[random.nextInt(otherUsers.length)].userId;

    // Create a unique key for the combination
    String key = '$userId-$placeFeedbackId';

    // Check if this combination already exists
    if (existingHelpfuls.contains(key)) {
      continue; // Skip if already exists
    }

    // Randomly generate a createdDate within the past 30 days
    DateTime createdDate =
    DateTime.now().subtract(Duration(days: random.nextInt(30)));

    PlaceFeedbackHelpful feebBackHelpful = PlaceFeedbackHelpful(
      placeFeedbackHelpfulId: placeFeedbackHelpfulId++,
      userId: userId,
      placeFeedbackId: placeFeedbackId,
      createdDate: createdDate,
    );

    feebBackHelpfuls.add(feebBackHelpful);
    existingHelpfuls.add(key);
  }

  return feebBackHelpfuls;
}

  List<PlaceFeedbackHelpful> feebBackHelpfuls = generatePlaceFeedbackHelpfuls(1000, feedbacks, fakeUsers);

