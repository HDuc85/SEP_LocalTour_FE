import 'dart:math';
import 'package:localtourvn/models/schedule/schedule.dart';
import 'package:localtourvn/models/users/users.dart';

class ScheduleLike {
  final int id;
  final int scheduleId; // Maps to scheduleId in Schedule
  final String userId; // Maps to userId in User
  final DateTime createdDate;

  ScheduleLike({
    required this.id,
    required this.scheduleId,
    required this.userId,
    required this.createdDate,
  });

  factory ScheduleLike.fromJson(Map<String, dynamic> json) {
    return ScheduleLike(
      id: json['id'],
      scheduleId: json['scheduleId'],
      userId: json['userId'],
      createdDate: DateTime.parse(json['createdDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scheduleId': scheduleId,
      'userId': userId,
      'createdDate': createdDate.toIso8601String(),
    };
  }
}

List<ScheduleLike> generateFakeScheduleLikes(int count, List<Schedule> schedules, List<User> users) {
  final random = Random();
  return List.generate(count, (index) {
    Schedule schedule = schedules[random.nextInt(schedules.length)];
    String userId = users[random.nextInt(users.length)].userId;
    return ScheduleLike(
      id: index + 1,
      scheduleId: schedule.id,
      userId: userId,
      createdDate: DateTime.now().subtract(Duration(days: index)),
    );
  });
}

List<ScheduleLike> dummyScheduleLikes = generateFakeScheduleLikes(500, dummySchedules, fakeUsers);
