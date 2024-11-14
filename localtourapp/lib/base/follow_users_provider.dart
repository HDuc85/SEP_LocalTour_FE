// lib/providers/follow_users_provider.dart

import 'package:flutter/material.dart';
import 'package:localtourapp/models/users/followuser.dart';
import 'package:localtourapp/models/users/users.dart';

class FollowUsersProvider with ChangeNotifier {
  List<FollowUser> _followUsers = [];

  FollowUsersProvider({List<FollowUser>? initialFollowUsers}) {
    _followUsers = initialFollowUsers ?? [];
  }

  List<FollowUser> get followUsers => _followUsers;

  // Add a new follow relationship
  void addFollowUser(FollowUser followUser) {
    _followUsers.add(followUser);
    notifyListeners();
  }

  // Remove a follow relationship
  void removeFollowUser(String followerId, String followingId) {
    _followUsers.removeWhere((fu) =>
    fu.userId == followerId && fu.userFollow == followingId);
    notifyListeners();
  }

  // Get followers for a specific user
  List<FollowUser> getFollowers(String userId) {
    return _followUsers.where((fu) => fu.userFollow == userId).toList();
  }

  // Get followings for a specific user
  List<FollowUser> getFollowings(String userId) {
    return _followUsers.where((fu) => fu.userId == userId).toList();
  }

  // Check if a user is following another user
  bool isFollowing(String followerId, String followingId) {
    return _followUsers.any(
            (fu) => fu.userId == followerId && fu.userFollow == followingId);
  }
}
