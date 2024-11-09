// user_provider.dart
import 'package:flutter/material.dart';
import '../models/users/users.dart';

class UserProvider with ChangeNotifier {
  late User _currentUser;

  User get currentUser => _currentUser;

  void setCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  bool isCurrentUser(String userId) {
    return _currentUser.userId == userId;
  }
}
