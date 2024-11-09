class PostCommentLike {
  int id;
  int postCommentId;
  String userId;
  DateTime createdDate;

  PostCommentLike({
    required this.id,
    required this.postCommentId,
    required this.userId,
    required this.createdDate,
  });

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
