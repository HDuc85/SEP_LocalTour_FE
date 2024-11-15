<<<<<<< HEAD
class Post {
  int id;
  String authorId;
  int? placeId;
  int? scheduleId;
  double longitude;
  double latitude;
  String title;
  DateTime createdDate;
  DateTime updateDate;
  String content;
=======
import 'dart:math';

import '../places/place.dart';
import '../schedule/schedule.dart';
import '../users/users.dart';

class Post {
  int id;
  String authorId; // Should map to userId in User
  int? placeId; // Should map to placeId in Place
  int? scheduleId; // Should map to id in Schedule
  String title;
  DateTime createdAt;
  DateTime updatedAt;
  String? content;
>>>>>>> TuanNTA2k
  bool isPublic;

  Post({
    required this.id,
    required this.authorId,
    this.placeId,
    this.scheduleId,
<<<<<<< HEAD
    required this.longitude,
    required this.latitude,
    required this.title,
    required this.createdDate,
    required this.updateDate,
=======
    required this.title,
    required this.createdAt,
    required this.updatedAt,
>>>>>>> TuanNTA2k
    required this.content,
    required this.isPublic,
  });

<<<<<<< HEAD
=======
  // Factory method to create a Post object from JSON
>>>>>>> TuanNTA2k
  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: json['Id'] as int,
    authorId: json['AuthorId'] as String,
    placeId: json['PlaceId'] != null ? json['PlaceId'] as int : null,
<<<<<<< HEAD
    scheduleId:
    json['ScheduleId'] != null ? json['ScheduleId'] as int : null,
    longitude: (json['Longitude'] as num).toDouble(),
    latitude: (json['Latitude'] as num).toDouble(),
    title: json['Title'] as String,
    createdDate: DateTime.parse(json['CreatedDate'] as String),
    updateDate: DateTime.parse(json['UpdateDate'] as String),
=======
    scheduleId: json['ScheduleId'] != null ? json['ScheduleId'] as int : null,
    title: json['Title'] as String,
    createdAt: DateTime.parse(json['CreatedDate'] as String),
    updatedAt: DateTime.parse(json['UpdateDate'] as String),
>>>>>>> TuanNTA2k
    content: json['Content'] as String,
    isPublic: json['Public'] as bool,
  );

<<<<<<< HEAD
=======
  // Method to convert a Post object to JSON
>>>>>>> TuanNTA2k
  Map<String, dynamic> toJson() => {
    'Id': id,
    'AuthorId': authorId,
    'PlaceId': placeId,
    'ScheduleId': scheduleId,
<<<<<<< HEAD
    'Longitude': longitude,
    'Latitude': latitude,
    'Title': title,
    'CreatedDate': createdDate.toIso8601String(),
    'UpdateDate': updateDate.toIso8601String(),
=======
    'Title': title,
    'CreatedAt': createdAt.toIso8601String(),
    'UpdateAt': updatedAt.toIso8601String(),
>>>>>>> TuanNTA2k
    'Content': content,
    'Public': isPublic,
  };
}
<<<<<<< HEAD
=======

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
      title: 'Post Title ${index + 1}',
      createdAt: DateTime.now().subtract(Duration(days: random.nextInt(365))),
      updatedAt: DateTime.now().subtract(Duration(days: random.nextInt(100))),
      content: 'This is a sample content for postThis is a sample content for postThis is a sample content for post'
          'This is a sample content for postThis is a sample content for postThis is a sample content for post'
          'This is a sample content for postThis is a sample content for postThis is a sample content for post'
          'This is a sample content for postThis is a sample content for postThis is a sample content for post'
          'This is a sample content for postThis is a sample content for postThis is a sample content for post'
          'This is a sample content for postThis is a sample content for postThis is a sample content for post'
          'This is a sample content for postThis is a sample content for postThis is a sample content for post'
          'This is a sample content for postThis is a sample content for postThis is a sample content for post'
          'This is a sample content for postThis is a sample content for postThis is a sample content for post'
          'This is a sample content for postThis is a sample content for postThis is a sample content for post'
          'This is a sample content for postThis is a sample content for postThis is a sample content for post'
          'This is a sample content for postThis is a sample content for postThis is a sample content for post'
          'This is a sample content for postThis is a sample content for postThis is a sample content for post ${index + 1}.',
      isPublic: random.nextBool(),
    );
  });
}

// Generate 100 dummy posts using existing users, places, and schedules
List<Post> dummyPosts = generateDummyPosts(20, fakeUsers, dummyPlaces, dummySchedules);
>>>>>>> TuanNTA2k
