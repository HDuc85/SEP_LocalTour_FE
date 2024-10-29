import 'dart:math';

import 'package:flutter/material.dart';

class Place {
  int placeId;
  int wardId;
  String photoDisplay;
  TimeOfDay? timeOpen;
  TimeOfDay? timeClose;
  double longitude;
  double latitude;
  String? placeUrl;

  Place({
    required this.placeId,
    required this.wardId,
    required this.photoDisplay,
    this.timeOpen,
    this.timeClose,
    required this.longitude,
    required this.latitude,
    this.placeUrl,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
        placeId: json['placeId'],
        wardId: json['wardId'],
        photoDisplay: json['photoDisplay'],
        timeOpen: json['timeOpen'] != null
            ? _timeOfDayFromString(json['timeOpen'])
            : null,
        timeClose: json['timeClose'] != null
            ? _timeOfDayFromString(json['timeClose'])
            : null,
        longitude: json['longitude'].toDouble(),
        latitude: json['latitude'].toDouble(),
        placeUrl: json['placeUrl']);
  }

  Map<String, dynamic> toJson() {
    return {
      'placeId': placeId,
      'wardId': wardId,
      'photoDisplay': photoDisplay,
      'timeOpen': timeOpen != null ? _timeOfDayToString(timeOpen!) : null,
      'timeClose': timeClose != null ? _timeOfDayToString(timeClose!) : null,
      'longitude': longitude,
      'latitude': latitude,
      'placeUrl': placeUrl,
    };
  }

  // Helper method to convert TimeOfDay to string
  static TimeOfDay _timeOfDayFromString(String time) {
    final split = time.split(':');
    return TimeOfDay(hour: int.parse(split[0]), minute: int.parse(split[1]));
  }

  // Helper method to convert TimeOfDay to a string in "HH:mm" format
  static String _timeOfDayToString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

List<Place> dummyPlaces = generateDummyPlaces(40);

List<Place> generateDummyPlaces(int count) {
  return List.generate(count, (index) {
    int id = index + 1;

    // Generate opening and closing times
    TimeOfDay timeOpen = TimeOfDay(
      hour: (8 + index) % 24, // Ensures hour stays within 0-23
      minute: Random().nextInt(60),
    );

    TimeOfDay timeClose = TimeOfDay(
      hour: (18 + index) % 24,
      minute: Random().nextInt(60),
    );

    return Place(
      placeId: id,
      wardId: 0 + id,
      photoDisplay: 'https://picsum.photos/200/300?random=$id',
      timeOpen: timeOpen,
      timeClose: timeClose,
      longitude: 100.0 + index * 0.5,
      latitude: 20.0 + index * 0.5,
      placeUrl: 'https://fap.fpt.edu.vn/',
    );
  });
}

// Helper function to check if current time is between open and close times
bool _isTimeBetween(TimeOfDay currentTime, TimeOfDay startTime, TimeOfDay endTime) {
  final currentMinutes = currentTime.hour * 60 + currentTime.minute;
  final startMinutes = startTime.hour * 60 + startTime.minute;
  final endMinutes = endTime.hour * 60 + endTime.minute;

  if (endMinutes < startMinutes) {
    // Handles cases where endTime is past midnight
    return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
  } else {
    return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
  }
}


