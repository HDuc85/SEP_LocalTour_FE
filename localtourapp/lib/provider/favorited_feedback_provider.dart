// lib/providers/favorited_feedback_provider.dart

import 'package:flutter/material.dart';

class FavoritedFeedbackProvider with ChangeNotifier {
  final Set<int> _favoritedFeedbackIds = {};

  Set<int> get favoritedFeedbackIds => _favoritedFeedbackIds;

  void toggleFavorite(int feedbackId, bool isFavorited) {
    if (isFavorited) {
      _favoritedFeedbackIds.add(feedbackId);
    } else {
      _favoritedFeedbackIds.remove(feedbackId);
    }
    notifyListeners();
  }

  bool isFavorited(int feedbackId) {
    return _favoritedFeedbackIds.contains(feedbackId);
  }
}
