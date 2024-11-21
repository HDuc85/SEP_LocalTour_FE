import 'package:flutter/material.dart';

class PlaceCardModel {
  int placeId;
  String wardName;
  String photoDisplayUrl;
  String placeName;
  double rateStar;
  int countFeedback;
  double distance;
  TimeOfDay? timeClose;

  PlaceCardModel({
    required this.placeId,
    required this.wardName,
    required this.photoDisplayUrl,
    required this.placeName,
    required this.rateStar,
    required this.countFeedback,
    required this.distance,
    this.timeClose,
  });

  factory PlaceCardModel.fromJson(Map<String, dynamic> json) {
    return PlaceCardModel(
      placeId: json['id'],
      wardName: json['wardName']?.toString() ?? 'Unknown Ward',
      photoDisplayUrl: json['photoDisplay'] ?? '',
      placeName: json['placeTranslation'][0]['name'] ?? 'Unknown Place',
      rateStar: (json['rating'] ?? 0).toDouble(),
      countFeedback: json['totalPlaceFeedback'] ?? 0,
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

List<PlaceCardModel> mapJsonToPlaceCardModels(List<dynamic> jsonData) {
  return jsonData.map((data) => PlaceCardModel.fromJson(data)).toList();
}
