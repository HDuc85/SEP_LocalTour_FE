import 'package:flutter/material.dart';

class PlaceCardModel {
  int placeId;
  String wardName;
  String photoDisplayUrl;
  double longitude;
  double latitude;
  String placeName;
  double rateStar;
  int countFeedback;
  double distance;
  TimeOfDay? timeClose;
  String address;

  PlaceCardModel({
    required this.placeId,
    required this.wardName,
    required this.photoDisplayUrl,
    required this.latitude,
    required this.longitude,
    required this.placeName,
    required this.rateStar,
    required this.countFeedback,
    required this.distance,
    required this.address,
    this.timeClose,
  });

  factory PlaceCardModel.fromJson(Map<String, dynamic> json) {

    bool hasValue = json['placeTranslation'].isNotEmpty ? true: false;

    return PlaceCardModel(
      placeId: json['id'],
      wardName: json['wardName']?.toString() ?? 'Unknown Ward',
      photoDisplayUrl: json['photoDisplay'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      placeName: hasValue ? json['placeTranslation'][0]['name'] : 'Unknown Place',
      address: hasValue ? json['placeTranslation'][0]['address'] : 'Unknown Address',
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
