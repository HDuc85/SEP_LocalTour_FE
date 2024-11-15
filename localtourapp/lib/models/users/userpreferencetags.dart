import 'dart:math';

class UserPreferenceTags {
  int id;
  int? tagId;
  String userId;

  UserPreferenceTags({
    required this.id,
    this.tagId,
    required this.userId,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tagId': tagId,
      'userId': userId,
    };
  }

  // Construct from JSON
  factory UserPreferenceTags.fromJson(Map<String, dynamic> json) {
    return UserPreferenceTags(
      id: json['id'],
      tagId: json['tagId'],
      userId: json['userId'],
    );
  }


}