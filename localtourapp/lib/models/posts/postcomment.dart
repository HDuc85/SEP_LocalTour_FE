<<<<<<< HEAD
class PostComment {
  int id;
  int postId;
  int? parentId;
  String userId;
=======
import 'dart:math';

import 'package:localtourapp/models/posts/post.dart';

import '../users/users.dart';

class PostComment {
  int id;
  int postId; // Maps to id in Post
  int? parentId; // Maps to another comment's id in PostComment for nested comments
  String userId; // Maps to userId in User
>>>>>>> TuanNTA2k
  String content;
  DateTime createdDate;

  PostComment({
    required this.id,
    required this.postId,
    this.parentId,
    required this.userId,
    required this.content,
    required this.createdDate,
  });

<<<<<<< HEAD
  factory PostComment.fromJson(Map<String, dynamic> json) => PostComment(
    id: json['Id'] as int,
    postId: json['PostId'] as int,
    parentId: json['ParentId'] != null ? json['ParentId'] as int : null,
    userId: json['UserId'] as String,
    content: json['Content'] as String,
    createdDate: DateTime.parse(json['CreatedDate'] as String),
  );

  Map<String, dynamic> toJson() => {
    'Id': id,
    'PostId': postId,
    'ParentId': parentId,
    'UserId': userId,
    'Content': content,
    'CreatedDate': createdDate.toIso8601String(),
  };
}
=======
  // Factory method to create a PostComment from JSON
  factory PostComment.fromJson(Map<String, dynamic> json) {
    return PostComment(
      id: json['id'],
      postId: json['postId'],
      parentId: json['parentId'],
      userId: json['userId'],
      content: json['content'],
      createdDate: DateTime.parse(json['createdDate']),
    );
  }

  // Method to convert a PostComment to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'parentId': parentId,
      'userId': userId,
      'content': content,
      'createdDate': createdDate.toIso8601String(),
    };
  }
}

// Function to generate dummy PostComment data
List<PostComment> generateDummyComments(int count, List<Post> posts, List<User> users) {
  final random = Random();
  List<PostComment> comments = [];

  for (int i = 0; i < count; i++) {
    // Randomly select an existing post and user for the comment
    final selectedPost = posts[random.nextInt(posts.length)];
    final selectedUser = users[random.nextInt(users.length)];

    // Create the comment
    comments.add(
      PostComment(
        id: i + 1,
        postId: selectedPost.id, // Maps to the Post id
        parentId: i > 0 && random.nextBool() ? comments[random.nextInt(i)].id : null, // Randomly add parentId
        userId: selectedUser.userId, // Maps to User userId
        content: 'This is a comment content for post ${selectedPost.id} by ${selectedUser.userName}',
        createdDate: DateTime.now().subtract(Duration(days: random.nextInt(365))),
      ),
    );
  }

  return comments;
}

// Usage example
List<PostComment> dummyComments = generateDummyComments(100, dummyPosts, fakeUsers);
>>>>>>> TuanNTA2k
