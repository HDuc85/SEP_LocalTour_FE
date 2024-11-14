import 'package:flutter/material.dart';
import 'package:localtourapp/models/users/users.dart';

class UserProvider with ChangeNotifier {
  User _currentUser;
  final Set<int> _preferredTagIds = {}; // Store preferred tag IDs independently

  UserProvider({required User initialUser}) : _currentUser = initialUser;

  // Getter to access the current user
  User get currentUser => _currentUser;

  // Getter to access the userId directly
  String get userId => _currentUser.userId;

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
