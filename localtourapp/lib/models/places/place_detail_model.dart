
import 'package:flutter/material.dart';
import 'package:localtourapp/models/media_model.dart';

import 'place_activity_model.dart';

class PlaceDetailModel {
  final int id;
  final String name;
  final String description;
  final String address;
  final String contact;
  final String photoDisplay;
  final TimeOfDay? timeOpen;
  final TimeOfDay? timeClose;
  final double longitude;
  final double latitude;
  final String contactLink;
  final double rating;
  final List<PlaceActivityModel> placeActivities;
  final List<MediaModel> placeMedias;
  final String brc;

  PlaceDetailModel({
    required this.id,
    required this.photoDisplay,
    required this.timeOpen,
    required this.timeClose,
    required this.longitude,
    required this.latitude,
    required this.contactLink,
    required this.placeActivities,
    required this.placeMedias,
    required this.name,
    required this.description,
    required this.address,
    required this.contact,
    required this.rating,
    required this.brc,
  });


  factory PlaceDetailModel.fromJson(Map<String, dynamic> json) {
    bool hasValue = (json['placeTranslations'] as List).isNotEmpty;

    return PlaceDetailModel(
      id: json['id'],
      photoDisplay: json['photoDisplay'],
      timeOpen: _parseTimeOfDay(json['timeOpen']),
      timeClose: _parseTimeOfDay(json['timeClose']),
      longitude: json['longitude'].toDouble(),
      latitude: json['latitude'].toDouble(),
      contactLink: json['contactLink'],
      address: hasValue ? json['placeTranslations'][0]['address'] : '',
      contact: hasValue ? json['placeTranslations'][0]['contact']:'',
      description: hasValue ? json['placeTranslations'][0]['description'] : '',
      name: hasValue ? json['placeTranslations'][0]['name']:'',
      placeMedias: (json['placeMedia'] as List)
                    .map((e) => MediaModel.fromJson(e))
                    .toList(),
      placeActivities: (json['placeActivities'] as List)
          .map((e) => PlaceActivityModel.fromJson(e))
          .toList(),
      rating: json['rating'].toDouble(),
      brc: json['brc']??'',
    );
  }

  static TimeOfDay? _parseTimeOfDay(String? time) {
    if (time == null || time.isEmpty) return null;
    final parts = time.split(':');
    if (parts.length != 3) return null;
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}