// users_provider.dart
import 'package:flutter/material.dart';
import '../models/users/users.dart';

class UsersProvider with ChangeNotifier {
  final List<User> _users;

  UsersProvider(this._users);

  List<User> get users => _users;

  User? getUserById(String userId) {
    try {
      return _users.firstWhere((user) => user.userId == userId);
    } catch (e) {
      return null;
    }
  }
}
