class PostComment {
  int id;
  int postId;
  int? parentId;
  String userId;
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
