class PostLike {
  int id;
  int postId;
  String userId;
  DateTime createdDate;

  PostLike({
    required this.id,
    required this.postId,
    required this.userId,
    required this.createdDate,
  });

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
