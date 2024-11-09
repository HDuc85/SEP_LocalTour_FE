import 'dart:math';

import '../places/place.dart';
import '../schedule/schedule.dart';
import '../users/users.dart';

class Post {
  int id;
  String authorId; // Should map to userId in User
  int? placeId; // Should map to placeId in Place
  int? scheduleId; // Should map to id in Schedule
  double longitude;
  double latitude;
  String title;
  DateTime createdDate;
  DateTime updateDate;
  String content;
  bool isPublic;

  Post({
    required this.id,
    required this.authorId,
    this.placeId,
    this.scheduleId,
    required this.longitude,
    required this.latitude,
    required this.title,
    required this.createdDate,
    required this.updateDate,
    required this.content,
    required this.isPublic,
  });

  // Factory method to create a Post object from JSON
  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: json['Id'] as int,
    authorId: json['AuthorId'] as String,
    placeId: json['PlaceId'] != null ? json['PlaceId'] as int : null,
    scheduleId: json['ScheduleId'] != null ? json['ScheduleId'] as int : null,
    longitude: (json['Longitude'] as num).toDouble(),
    latitude: (json['Latitude'] as num).toDouble(),
    title: json['Title'] as String,
    createdDate: DateTime.parse(json['CreatedDate'] as String),
    updateDate: DateTime.parse(json['UpdateDate'] as String),
    content: json['Content'] as String,
    isPublic: json['Public'] as bool,
  );

  // Method to convert a Post object to JSON
  Map<String, dynamic> toJson() => {
    'Id': id,
    'AuthorId': authorId,
    'PlaceId': placeId,
    'ScheduleId': scheduleId,
    'Longitude': longitude,
    'Latitude': latitude,
    'Title': title,
    'CreatedDate': createdDate.toIso8601String(),
    'UpdateDate': updateDate.toIso8601String(),
    'Content': content,
    'Public': isPublic,
  };
}

List<Post> generateDummyPosts(int count, List<User> users, List<Place> places, List<Schedule> schedules) {
  final random = Random();

  return List.generate(count, (index) {
    // Randomly select an existing user, place, and schedule for the post
    final selectedUser = users[random.nextInt(users.length)];
    final selectedPlace = places[random.nextInt(places.length)];
    final selectedSchedule = schedules[random.nextInt(schedules.length)];

    return Post(
      id: index + 1,
      authorId: selectedUser.userId, // Maps to userId in User
      placeId: selectedPlace.placeId, // Maps to placeId in Place
      scheduleId: selectedSchedule.id, // Maps to id in Schedule
      longitude: selectedPlace.longitude,
      latitude: selectedPlace.latitude,
      title: 'Post Title ${index + 1}',
      createdDate: DateTime.now().subtract(Duration(days: random.nextInt(365))),
      updateDate: DateTime.now().subtract(Duration(days: random.nextInt(100))),
      content: 'This is a sample content for post ${index + 1}.',
      isPublic: random.nextBool(),
    );
  });
}

// Generate 100 dummy posts using existing users, places, and schedules
List<Post> dummyPosts = generateDummyPosts(50, fakeUsers, dummyPlaces, dummySchedules);

