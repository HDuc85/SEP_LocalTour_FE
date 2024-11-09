class FollowUser {
  int id;
  String userId;
  String userFollow;
  DateTime dateCreated;

  FollowUser({
    required this.id,
    required this.userId,
    required this.userFollow,
    required this.dateCreated,
  });

  factory FollowUser.fromJson(Map<String, dynamic> json) => FollowUser(
    id: json['Id'] as int,
    userId: json['UserId'] as String,
    userFollow: json['UserFollow'] as String,
    dateCreated: DateTime.parse(json['DateCreated'] as String),
  );

  Map<String, dynamic> toJson() => {
    'Id': id,
    'UserId': userId,
    'UserFollow': userFollow,
    'DateCreated': dateCreated.toIso8601String(),
  };
}
