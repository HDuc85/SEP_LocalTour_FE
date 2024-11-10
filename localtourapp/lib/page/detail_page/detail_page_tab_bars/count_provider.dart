import 'package:flutter/material.dart';

class CountProvider with ChangeNotifier {
  int _scheduleCount = 0;
  int _reviewCount = 0;
  int _postCount = 0;

  int get scheduleCount => _scheduleCount;
  int get reviewCount => _reviewCount;
  int get postCount => _postCount;

  void setScheduleCount(int count) {
    _scheduleCount = count;
    notifyListeners();
  }

  void incrementScheduleCount() {
    _scheduleCount += 1;
    notifyListeners();
  }

  void decrementScheduleCount() {
    if (_scheduleCount > 0) {
      _scheduleCount -= 1;
      notifyListeners();
    }
  }

  void setReviewCount(int count) {
    _reviewCount = count;
    notifyListeners();
  }

  void incrementReviewCount() {
    _reviewCount += 1;
    notifyListeners();
  }

  void decrementReviewCount() {
    if (_reviewCount > 0) {
      _reviewCount -= 1;
      notifyListeners();
    }
  }

  void setPostCount(int count) {
    _postCount = count;
    notifyListeners();
  }

  void incrementPostCount() {
    _postCount += 1;
    notifyListeners();
  }

  void decrementPostCount() {
    if (_postCount > 0) {
      _postCount -= 1;
      notifyListeners();
    }
  }
}
