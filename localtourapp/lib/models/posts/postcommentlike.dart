<<<<<<< HEAD
class PostCommentLike {
  int id;
  int postCommentId;
  String userId;
=======
import 'dart:math';

import '../users/users.dart';
import 'postcomment.dart';

class PostCommentLike {
  int id;
  int postCommentId; // Maps to id in PostComment
  String userId; // Maps to userId in User
>>>>>>> TuanNTA2k
  DateTime createdDate;

  PostCommentLike({
    required this.id,
    required this.postCommentId,
    required this.userId,
    required this.createdDate,
  });

<<<<<<< HEAD
  factory PostCommentLike.fromJson(Map<String, dynamic> json) =>
      PostCommentLike(
        id: json['Id'] as int,
        postCommentId: json['PostCommentId'] as int,
        userId: json['UserId'] as String,
        createdDate: DateTime.parse(json['CreatedDate'] as String),
      );

  Map<String, dynamic> toJson() => {
    'Id': id,
    'PostCommentId': postCommentId,
    'UserId': userId,
    'CreatedDate': createdDate.toIso8601String(),
  };
}
=======
  factory PostCommentLike.fromJson(Map<String, dynamic> json) {
    return PostCommentLike(
      id: json['id'],
      postCommentId: json['postCommentId'],
      userId: json['userId'],
      createdDate: DateTime.parse(json['createdDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postCommentId': postCommentId,
      'userId': userId,
      'createdDate': createdDate.toIso8601String(),
    };
  }
}

List<PostCommentLike> generateDummyPostCommentLikes(int count, List<PostComment> comments, List<User> users) {
  final random = Random();
  return List.generate(count, (index) {
    return PostCommentLike(
      id: index + 1,
      postCommentId: comments[random.nextInt(comments.length)].id,
      userId: users[random.nextInt(users.length)].userId,
      createdDate: DateTime.now().subtract(Duration(days: random.nextInt(365))),
    );
  });
}

List<PostCommentLike> dummyPostCommentLikes = generateDummyPostCommentLikes(50, dummyComments, fakeUsers);
>>>>>>> TuanNTA2k
