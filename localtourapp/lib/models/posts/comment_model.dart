class CommentModel {
  final int id;
  final int postId;
  final String userId;
  final String content;
  final DateTime createdDate;
  final int? parentId;
  final List<CommentModel> childComments;
  final int totalLikes;
  final bool likedByUser;
  final String? userFullName;
  final String? userProfilePictureUrl;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdDate,
    this.parentId,
    required this.childComments,
    required this.totalLikes,
    required this.likedByUser,
    this.userFullName,
    this.userProfilePictureUrl,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      postId: json['postId'],
      userId: json['userId'],
      content: json['content'],
      createdDate: DateTime.parse(json['createdDate']).toUtc(),
      parentId: json['parentId'],
      childComments: (json['childComments'] as List<dynamic>)
          .map((child) => CommentModel.fromJson(child))
          .toList(),
      totalLikes: json['totalLikes'],
      likedByUser: json['likedByUser'],
      userFullName: json['userFullName'],
      userProfilePictureUrl: json['userProfilePictureUrl'],
    );
  }
}

List<CommentModel> mapJsonToCommentModels(List<dynamic> jsonData) {
  return jsonData.map((data) => CommentModel.fromJson(data)).toList();
}