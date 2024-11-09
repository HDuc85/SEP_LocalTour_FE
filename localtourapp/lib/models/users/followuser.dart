import 'dart:math';

import 'package:localtourapp/models/users/users.dart';

class FollowUser {
  int id;
  String userId; // The user who follows another user
  String userFollow; // The user being followed
  DateTime dateCreated;

  FollowUser({
    required this.id,
    required this.userId,
    required this.userFollow,
    required this.dateCreated,
  });

  factory FollowUser.fromJson(Map<String, dynamic> json) {
    return FollowUser(
      id: json['id'],
      userId: json['userId'],
      userFollow: json['userFollow'],
      dateCreated: DateTime.parse(json['dateCreated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userFollow': userFollow,
      'dateCreated': dateCreated.toIso8601String(),
    };
  }

  // Method to count followers of a specific user
  static int countFollowers(String userId, List<FollowUser> followUsers) {
    return followUsers.where((follow) => follow.userFollow == userId).length;
  }

  // Method to count the number of users a specific user is following
  static int countFollowing(String userId, List<FollowUser> followUsers) {
    return followUsers.where((follow) => follow.userId == userId).length;
  }
}

// Dummy Data Generator for FollowUser
List<FollowUser> generateDummyFollowUsers(int count, List<User> users) {
  final random = Random();
  return List.generate(count, (index) {
    String follower = users[random.nextInt(users.length)].userId;
    String following;

    // Ensure the follower is not the same as the following user
    do {
      following = users[random.nextInt(users.length)].userId;
    } while (following == follower);

    return FollowUser(
      id: index + 1,
      userId: follower,
      userFollow: following,
      dateCreated: DateTime.now().subtract(Duration(days: random.nextInt(365))),
    );
  });
}

// Example usage
List<FollowUser> dummyFollowUsers = generateDummyFollowUsers(10, fakeUsers);
