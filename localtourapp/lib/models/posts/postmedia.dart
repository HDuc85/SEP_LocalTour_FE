import 'dart:math';

import 'package:localtourapp/models/posts/post.dart';

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

List<PostMedia> generateDummyPostMedia(int count, List<Post> posts) {
  final random = Random();
  List<String> mediaTypes = ['photo', 'video'];

  return List.generate(count, (index) {
    String type = mediaTypes[random.nextInt(mediaTypes.length)];
    String url = (type == 'video')
        ? 'assets/videos/video_${random.nextInt(3) + 1}.mp4'
        : 'https://picsum.photos/seed/${random.nextInt(1000)}/600/400';

    return PostMedia(
      id: index + 1,
      postId: posts[random.nextInt(posts.length)].id,
      type: type,
      url: url,
      createdAt: DateTime.now().subtract(Duration(days: random.nextInt(365))),
    );
  });
}

List<PostMedia> dummyPostMedia = generateDummyPostMedia(200, dummyPosts);
