import 'dart:math';

class PostMedia {
  int id;
  int? postId; // Maps to id in Post
  String type; // e.g., 'image', 'video'
  String url;
  DateTime createdAt;

  PostMedia({
    required this.id,
    this.postId,
    required this.type,
    required this.url,
    required this.createdAt,
  });

  factory PostMedia.fromJson(Map<String, dynamic> json) {
    return PostMedia(
      id: json['id'],
      postId: json['postId'],
      type: json['type'],
      url: json['url'],
      createdAt: DateTime.parse(json['createdDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'type': type,
      'url': url,
      'createdDate': createdAt.toIso8601String(),
    };
  }
}

