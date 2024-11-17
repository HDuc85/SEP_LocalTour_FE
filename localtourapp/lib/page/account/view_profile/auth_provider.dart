// auth_provider.dart

import 'package:flutter/material.dart';

import '../../../models/users/users.dart';

class AuthProvider with ChangeNotifier {
  String? _currentUserId;

  String? get currentUserId => _currentUserId;

  bool get isLoggedIn => _currentUserId != null;

  // Simulated login method
  void login(String userId) {
    _currentUserId = userId;
    notifyListeners();
  }

  // Simulated logout method
  void logout() {
    _currentUserId = null;
    notifyListeners();
  }

// Implement actual authentication logic as needed
}