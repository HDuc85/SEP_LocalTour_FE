// lib/providers/count_provider.dart

import 'package:flutter/material.dart';
import 'package:localtourapp/models/places/placefeedback.dart';
import 'package:localtourapp/models/posts/post.dart';

class CountProvider with ChangeNotifier {
  int _scheduleCount = 0;
  int _reviewCount = 0;
  int _postCount = 0;

  int get scheduleCount => _scheduleCount;
  int get reviewCount => _reviewCount;
  int get postCount => _postCount;

  CountProvider();



  void setScheduleCount(int count) {
    if (_scheduleCount != count) {
      _scheduleCount = count;
      notifyListeners();
    }
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
    if (_reviewCount != count) {
      _reviewCount = count;
      notifyListeners();
    }
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
    if (_postCount != count) {
      _postCount = count;
      notifyListeners();
    }
  }

  void updatePostCount(List<Post> posts) {
    final int newCount = posts.length;
    if (_postCount != newCount) {
      _postCount = newCount;
      notifyListeners();
    }
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
