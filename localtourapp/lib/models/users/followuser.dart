import 'dart:math';

import 'package:localtourapp/models/users/users.dart';


class FollowUserModel {
  String userId; // The user who follows another user
  String userFollow; // The user being followed
  String userName;
  String? userProfileUrl;

  FollowUserModel({
    required this.userId,
    required this.userFollow, // Default value for optional fields
    required this.userName,
    this.userProfileUrl,
  });

  factory FollowUserModel.fromJson(Map<String, dynamic> json) {
    return FollowUserModel(
      userId: json['userId'], // Required field from API
      userFollow: json['userFollow'] ?? '', // Use default if not provided
      userName: json['userName'], // Required field from API
      userProfileUrl: json['userProfileUrl'] ?? '', // Required field from API
    );
  }
}
