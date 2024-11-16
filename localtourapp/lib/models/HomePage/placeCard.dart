import 'package:flutter/material.dart';

class Placecard {
  int placeId;
  String wardName;
  String photoDisplayUrl;
  String placeName;
  double rateStar;
  int countFeedback;
  double distance;
  TimeOfDay? timeClose;

  Placecard({
    required this.placeId,
    required this.wardName,
    required this.photoDisplayUrl,
    required this.placeName,
    required this.rateStar,
    required this.countFeedback,
    required this.distance,
    this.timeClose,
  });

  factory Placecard.fromJson(Map<String, dynamic> json) {
    return Placecard(
      placeId: json['placeMedia'].isNotEmpty
          ? json['placeMedia'][0]['placeId'] ?? 0
          : 0,
      wardName: json['wardId']?.toString() ?? 'Unknown Ward',
      photoDisplayUrl: json['photoDisplay'] ?? '',
      placeName: json['contactLink'] ?? 'Unknown Place',
      rateStar: (json['rateStar'] ?? 0).toDouble(),
      countFeedback: json['countFeedback'] ?? 0,
      distance: json['distance']?.toDouble() ?? 0.0,
      timeClose: _parseTimeOfDay(json['timeClose']),
    );
  }

  static TimeOfDay? _parseTimeOfDay(String? time) {
    if (time == null || time.isEmpty) return null;
    final parts = time.split(':');
    if (parts.length != 3) return null;
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}

List<Placecard> mapJsonToPlacecards(List<dynamic> jsonData) {
  return jsonData.map((data) => Placecard.fromJson(data)).toList();
}
