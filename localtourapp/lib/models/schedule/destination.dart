import 'dart:math';
import '../places/place.dart';
import 'schedule.dart';

class Destination {
  int id;
  int scheduleId; // Maps to scheduleId in Schedule
  int placeId; // Maps to placeId in Place
  DateTime? startDate;
  DateTime? endDate;
  String? detail;
  bool isArrived;

  Destination({
    required this.id,
    required this.scheduleId,
    required this.placeId,
    this.startDate,
    this.endDate,
    this.detail,
    this.isArrived = false,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: json['id'],
      scheduleId: json['scheduleId'],
      placeId: json['placeId'],
      startDate:
          json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      detail: json['detail'],
      isArrived: json['isArrived'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scheduleId': scheduleId,
      'placeId': placeId,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'detail': detail,
      'isArrived': isArrived,
    };
  }
}

List<Destination> generateFakeDestinations(
    int count, List<Schedule> schedules, List<Place> places) {
  final random = Random();
  return List.generate(count, (index) {
    Schedule schedule = schedules[random.nextInt(schedules.length)];
    Place place = places[random.nextInt(places.length)];
    return Destination(
      id: index + 1,
      scheduleId: schedule.id,
      placeId: place.placeId,
      startDate: DateTime.now().add(Duration(days: index)),
      endDate: DateTime.now().add(Duration(days: index + 2)),
      detail: 'Visit Visit Visit Visit Visit Visit Visit Visit Visit Visit Visit Visit Visit Visit Visit Visit Visit Visit'
          ' Visit Visit Visit Visit Visit Visit Visit Visit Visit Visit Visit Visit Visit Visit Visit Visit Visit Visit Visit'
          ' Visit Visit Visit Visit Visit Visit Visit Visit Visit Visit Visit Visit Visit Visit Visit Visit Visit Visit Visit'
          ' Visit Visit Visit Visit Visit Visit Visit Visit Visit Visit Visit Visit Visit Visit Visit Visit Visit Visit Visit  ${place.placeId}',
      isArrived: random.nextBool(),
    );
  });
}

List<Destination> dummyDestinations =
    generateFakeDestinations(100, dummySchedules, dummyPlaces);
