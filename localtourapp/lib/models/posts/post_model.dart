import 'package:localtourapp/models/media_model.dart';

class PostModel {
  final int id;
  final String authorId;
  final String? authorFullName;
  final String? authorProfilePictureUrl;
  final int? placeId;
  final int? scheduleId;
  final double? longitude;
  final double? latitude;
  final String title;
  final DateTime? createdDate;
  final DateTime? updateDate;
  final String content;
  final bool isPublic;
  final bool isLiked;
  final int totalLikes;
  final int totalComments;
  final String? placeName;
  final String? scheduleName;
  final String? placePhotoDisplay;
  //final List<Comment> comments;
  final List<MediaModel> media;

  PostModel({
    required this.id,
    required this.authorId,
    this.authorFullName,
    this.authorProfilePictureUrl,
    this.placeId,
    this.placeName,
    this.scheduleName,
    this.scheduleId,
    this.placePhotoDisplay,
    this.longitude,
    this.latitude,
    required this.title,
    this.createdDate,
    this.updateDate,
    required this.content,
    required this.isPublic,
    required this.isLiked,
    required this.totalLikes,
    required this.totalComments,
    required this.media,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      authorId: json['authorId'],
      authorFullName: json['authorFullName']??'',
      placeName: json['placeName']??'',
      scheduleName: json['scheduleName']??'',
      placePhotoDisplay: json['placePhotoDisplay']??'',
      authorProfilePictureUrl: json['authorProfilePictureUrl']??'',
      placeId: json['placeId']??null,
      scheduleId: json['scheduleId']??null,
      longitude: json['longitude'] != null? json['longitude'].toDouble() : null,
      latitude: json['latitude'] != null? json['latitude'].toDouble():null,
      title: json['title'],
      createdDate:json['createdDate'] != null ? DateTime.parse(json['createdDate']).toUtc() : null,
      updateDate: json['updateDate'] != null ? DateTime.parse(json['updateDate']).toUtc() : null,
      content: json['content'],
      isPublic: json['public'],
      isLiked: json['isLiked'],
      totalLikes: json['totalLikes'],
      totalComments: json['totalComments'],
      media: (json['media'] as List<dynamic>)
          .map((media) => MediaModel.fromJson(media))
          .toList(),
    );
  }
}

List<PostModel> mapJsonToPostModels(List<dynamic> jsonData) {
  return jsonData.map((data) => PostModel.fromJson(data)).toList();
}