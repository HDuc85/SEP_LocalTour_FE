import 'dart:convert';

import 'package:localtourapp/models/media_model.dart';

class FeedBackModel {
  final int id;
  final String userId;
  final String profileUrl;
  final String userName;
  final int rating;
  final String content;
  final int totalLike;
  final DateTime createDate;
  final DateTime? updateDate;
  final bool isLiked;
  final String placeName;
  final String placePhotoDisplay;
  final int placeId;
  final List<MediaModel> placeFeedbackMedia;

  FeedBackModel({
    required this.id,
    required this.userId,
    required this.profileUrl,
    required this.userName,
    required this.rating,
    required this.content,
    required this.totalLike,
    required this.createDate,
    this.updateDate,
    required this.isLiked,
    required this.placeFeedbackMedia,
    required this.placeId,
    required this.placeName,
    required this.placePhotoDisplay,
  });

  factory FeedBackModel.fromJson(Map<String, dynamic> json) {
    return FeedBackModel(
      id: json['id']??0,
      userId: json['userId']??'',
      profileUrl: json['profileUrl']??'',
      userName: json['userName']??'',
      rating: json['rating'].toInt(),
      content: json['content']??'',
      totalLike: json['totalLike'].toInt(),
      createDate: DateTime.parse(json['createDate']),
      updateDate: json['updateDate'] != null ? DateTime.parse(json['updateDate']) : null,
      isLiked: json['isLiked'],
      placePhotoDisplay: json['placePhotoDisplay'],
      placeName: json['placeName'],
      placeId: json['placeId'],
      placeFeedbackMedia: (json['placeFeeedbackMedia'] as List)
          .map((media) => MediaModel.fromJson(media))
          .toList(),
    );
}
}

List<FeedBackModel> jsonToFeedbackList(List<dynamic> jsonData) {
  return jsonData.map((json) => FeedBackModel.fromJson(json)).toList();
}
