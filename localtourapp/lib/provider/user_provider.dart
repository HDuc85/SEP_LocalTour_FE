import 'package:flutter/material.dart';
import 'package:localtourapp/models/places/tag.dart';
import 'package:localtourapp/models/users/userreport.dart';
import 'package:localtourapp/models/users/users.dart';

class UserProvider with ChangeNotifier {
  User _currentUser;
  Set<int> _preferredTagIds = {}; // Store preferred tag IDs independently
  List<UserReport> _userReports = [];
  List<Tag> _tags = [];

  UserProvider({
    required User initialUser,
    List<Tag>? tags,
    List<UserReport>? userReports,
    Set<int>? preferredTagIds,
  }) : _currentUser = initialUser,
        _preferredTagIds = preferredTagIds ?? <int>{},
  // Initialize as Set<int>
        _userReports = userReports ?? [],
        _tags = tags ?? [];

  List<Tag> get tags => _tags;
  List<UserReport> get userReport => _userReports;
  Set<int> get preferredTagIds => _preferredTagIds;
  User get currentUser => _currentUser;
  String get userId => _currentUser.userId;

  void addUserReport(UserReport report) {
    _userReports.add(report);
    notifyListeners();
  }

  // Add a tag to the preferred tags
  void addTag(int tagId) {
    if (!_preferredTagIds.contains(tagId)) {
      _preferredTagIds.add(tagId);
      notifyListeners();
      _saveUserPreferencesToDatabase();
    }
  }

  // Remove a tag from the preferred tags
  void removeTag(int tagId) {
    if (_preferredTagIds.contains(tagId)) {
      _preferredTagIds.remove(tagId);
      notifyListeners();
      _saveUserPreferencesToDatabase();
    }
  }

  // Check if a tag is selected
  bool isTagSelected(int tagId) {
    return _preferredTagIds.contains(tagId);
  }

  Future<void> _saveUserPreferencesToDatabase() async {
    // Save _preferredTagIds to a database or shared preferences if needed
  }

  // Method to update user's information
  void updateUser(User updatedUser) {
    if (updatedUser.userId != _currentUser.userId) {
      throw ArgumentError(
          'Cannot update user: userId does not match the current user.');
    }

    _currentUser = updatedUser;
    notifyListeners();
  }

  // Check if a given userId is the current user
  bool isCurrentUser(String userId) {
    return _currentUser.userId == userId;
  }

  // Retrieve all user preferred tags
  List<int> getUserPreferredTags() {
    return _preferredTagIds.toList();
  }

// Optional: Set the current user by userId
  void setCurrentUserById(String userId, List<User> allUsers) {
    User? user = allUsers.firstWhere(
          (user) => user.userId == userId,
      orElse: () => _currentUser,
    );
    if (user.userId != _currentUser.userId) {
      _currentUser = user;
      notifyListeners();
    }
  }
}