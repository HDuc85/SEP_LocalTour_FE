import 'dart:math';
import 'package:localtourvn/models/users/users.dart';

class Schedule {
  final int id;
  final String userId; // Maps to userId in User
  String scheduleName;
  DateTime? startDate;
  DateTime? endDate;
  final DateTime createdDate;
  bool isPublic;

  Schedule({
    required this.id,
    required this.userId,
    required this.scheduleName,
    this.startDate,
    this.endDate,
    required this.createdDate,
    this.isPublic = false,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      userId: json['userId'],
      scheduleName: json['scheduleName'],
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      createdDate: DateTime.parse(json['createdDate']),
      isPublic: json['isPublic'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'scheduleName': scheduleName,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'createdDate': createdDate.toIso8601String(),
      'isPublic': isPublic,
    };
  }
}

List<Schedule> generateFakeSchedules(int count, List<User> users) {
  final random = Random();
  return List.generate(count, (index) {
    String userId = users[random.nextInt(users.length)].userId;
    return Schedule(
      id: index + 1,
      userId: userId,
      scheduleName: 'Schedule ${index + 1}',
      startDate: DateTime.now().add(Duration(days: random.nextInt(30))),
      endDate: DateTime.now().add(Duration(days: random.nextInt(60) + 30)),
      createdDate: DateTime.now().subtract(Duration(days: random.nextInt(30))),
      isPublic: random.nextBool(),
    );
  });
}

List<Schedule> dummySchedules = generateFakeSchedules(50, fakeUsers);
