class PostMedia {
  int id;
  int postId;
  String type;
  String url;
  DateTime createDate;

  PostMedia({
    required this.id,
    required this.postId,
    required this.type,
    required this.url,
    required this.createDate,
  });

  factory PostMedia.fromJson(Map<String, dynamic> json) => PostMedia(
    id: json['Id'] as int,
    postId: json['PostId'] as int,
    type: json['Type'] as String,
    url: json['Url'] as String,
    createDate: DateTime.parse(json['CreateDate'] as String),
  );

  Map<String, dynamic> toJson() => {
    'Id': id,
    'PostId': postId,
    'Type': type,
    'Url': url,
    'CreateDate': createDate.toIso8601String(),
  };
}
