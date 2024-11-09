// lib/account/user_provider.dart

import 'package:flutter/material.dart';
import '../models/users/users.dart';

class UserProvider with ChangeNotifier {
  late User _currentUser;

  // Getter for currentUser
  User get currentUser => _currentUser;

  // Setter for currentUser
  void setCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  // Method to check if a given userId is the current user
  bool isCurrentUser(String userId) {
    return _currentUser.userId == userId;
  }
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
  }
}
