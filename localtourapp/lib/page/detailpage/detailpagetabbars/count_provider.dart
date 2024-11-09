import 'package:flutter/material.dart';

class CountProvider with ChangeNotifier {
  int _scheduleCount = 0;
  int _reviewCount = 0;

  int get scheduleCount => _scheduleCount;
  int get reviewCount => _reviewCount;

  void setScheduleCount(int count) {
    _scheduleCount = count;
    notifyListeners();
  }

  void setReviewCount(int count) {
    _reviewCount = count;
    notifyListeners();
  }
}
