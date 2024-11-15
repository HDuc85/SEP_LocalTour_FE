<<<<<<< HEAD
class PostLike {
  int id;
  int postId;
  String userId;
=======
import 'dart:math';


import 'package:localtourapp/models/posts/post.dart';

import '../users/users.dart';

class PostLike {
  int id;
  int postId; // Maps to id in Post
  String userId; // Maps to userId in User
>>>>>>> TuanNTA2k
  DateTime createdDate;

  PostLike({
    required this.id,
    required this.postId,
    required this.userId,
    required this.createdDate,
  });

<<<<<<< HEAD
  factory PostLike.fromJson(Map<String, dynamic> json) => PostLike(
    id: json['Id'] as int,
    postId: json['PostId'] as int,
    userId: json['UserId'] as String,
    createdDate: DateTime.parse(json['CreatedDate'] as String),
  );

  Map<String, dynamic> toJson() => {
    'Id': id,
    'PostId': postId,
    'UserId': userId,
    'CreatedDate': createdDate.toIso8601String(),
  };
}
=======
  factory PostLike.fromJson(Map<String, dynamic> json) {
    return PostLike(
      id: json['id'],
      postId: json['postId'],
      userId: json['userId'],
      createdDate: DateTime.parse(json['createdDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'createdDate': createdDate.toIso8601String(),
    };
  }
}

List<PostLike> generateDummyPostLikes(int count, List<Post> posts, List<User> users) {
  final random = Random();
  return List.generate(count, (index) {
    return PostLike(
      id: index + 1,
      postId: posts[random.nextInt(posts.length)].id,
      userId: users[random.nextInt(users.length)].userId,
      createdDate: DateTime.now().subtract(Duration(days: random.nextInt(365))),
    );
  });
}

List<PostLike> dummyPostLikes = generateDummyPostLikes(1000, dummyPosts, fakeUsers);
>>>>>>> TuanNTA2k
