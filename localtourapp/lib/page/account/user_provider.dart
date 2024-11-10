// lib/page/account/user_provider.dart

import 'package:flutter/material.dart';
import 'package:localtourapp/models/users/users.dart';

class UserProvider with ChangeNotifier {
  // Private variable to hold the current user
  User _currentUser;

  // Constructor to initialize the current user
  UserProvider({required User initialUser}) : _currentUser = initialUser;

  // Getter to access the current user
  User get currentUser => _currentUser;

  // Getter to access the userId directly
  String get userId => _currentUser.userId;

  // Method to update the current user's information
  void updateUser(User updatedUser) {
    if (updatedUser.userId != _currentUser.userId) {
      throw ArgumentError(
          'Cannot update user: userId does not match the current user.');
    }

    _currentUser = updatedUser;
    notifyListeners();
    _saveUserToDatabase(updatedUser);
  }

  Future<void> _saveUserToDatabase(User user) async {
    // Implement your database saving logic here
  }

  // Method to check if a given userId is the current user
  bool isCurrentUser(String userId) {
    return _currentUser.userId == userId;
  }

  // Optional: Method to set the current user by userId (if needed)
  void setCurrentUserById(String userId, List<User> allUsers) {
    // Assuming you have access to all users, find the user by userId
    User? user = allUsers.firstWhere(
          (user) => user.userId == userId,
      orElse: () => _currentUser, // Fallback to current user if not found
    );
    if (user.userId != _currentUser.userId) {
      _currentUser = user;
      notifyListeners();
    }
  }
}
