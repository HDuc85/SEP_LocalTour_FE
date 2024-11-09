import 'dart:math';

import 'package:localtourapp/models/posts/post.dart';

class PostMedia {
  int id;
  int postId; // Maps to id in Post
  String type; // e.g., 'image', 'video'
  String url;
  DateTime createdDate;

  PostMedia({
    required this.id,
    required this.postId,
    required this.type,
    required this.url,
    required this.createdDate,
  });

  factory PostMedia.fromJson(Map<String, dynamic> json) {
    return PostMedia(
      id: json['id'],
      postId: json['postId'],
      type: json['type'],
      url: json['url'],
      createdDate: DateTime.parse(json['createdDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'type': type,
      'url': url,
      'createdDate': createdDate.toIso8601String(),
    };
  }
}

List<PostMedia> generateDummyPostMedia(int count, List<Post> posts) {
  final random = Random();
  List<String> mediaTypes = ['image', 'video'];

  return List.generate(count, (index) {
    return PostMedia(
      id: index + 1,
      postId: posts[random.nextInt(posts.length)].id,
      type: mediaTypes[random.nextInt(mediaTypes.length)],
      url: 'https://picsum.photos/seed/${random.nextInt(1000)}/600/400',
      createdDate: DateTime.now().subtract(Duration(days: random.nextInt(365))),
    );
  });
}

List<PostMedia> dummyPostMedia = generateDummyPostMedia(50, dummyPosts);