// lib/providers/review_provider.dart

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:localtourapp/models/places/placefeedback.dart';
import 'package:localtourapp/models/places/placefeedbackhelpful.dart';
import 'package:localtourapp/models/places/placefeedbackmedia.dart';
import 'package:localtourapp/provider/count_provider.dart';

class ReviewProvider with ChangeNotifier {
  // Private lists to hold reviews and their media
  List<PlaceFeedback> _placeFeedbacks = [];
  List<PlaceFeedbackMedia> _placeFeedbackMedia = [];
  List<PlaceFeedbackHelpful> _placeFeedbackHelpfuls = [];

  // Constructor to initialize with optional initial data
  ReviewProvider({
    List<PlaceFeedback>? placeFeedbacks,
    List<PlaceFeedbackMedia>? placeFeedbackMedia,
    List<PlaceFeedbackHelpful>? placeFeedbackHelpfuls,
  }) {
    _placeFeedbacks = placeFeedbacks ?? [];
    _placeFeedbackMedia = placeFeedbackMedia ?? [];
    _placeFeedbackHelpfuls = placeFeedbackHelpfuls ?? [];
  }

  // Getters to access the private lists
  List<PlaceFeedback> get placeFeedbacks => _placeFeedbacks;
  List<PlaceFeedbackMedia> get placeFeedbackMedia => _placeFeedbackMedia;
  List<PlaceFeedbackHelpful> get placeFeedbackHelpful => _placeFeedbackHelpfuls;
  // --------------------------
  // Methods to Manage Reviews
  // --------------------------



  int getHelpfulCount(int feedbackId) {
    return _placeFeedbackHelpfuls.where((helpful) => helpful.placeFeedbackId == feedbackId).length;
  }

  bool isFavorited(int feedbackId, String userId) {
    return _placeFeedbackHelpfuls.any((helpful) =>
    helpful.placeFeedbackId == feedbackId && helpful.userId == userId);
  }

  // Toggle favorite status by adding/removing from placeFeedbackHelpfuls
  void toggleFavorite(int feedbackId, String userId) {
    if (isFavorited(feedbackId, userId)) {
      _placeFeedbackHelpfuls.removeWhere((helpful) =>
      helpful.placeFeedbackId == feedbackId && helpful.userId == userId);
    } else {
      _placeFeedbackHelpfuls.add(PlaceFeedbackHelpful(
        placeFeedbackHelpfulId: _placeFeedbackHelpfuls.length + 1,
        userId: userId,
        placeFeedbackId: feedbackId,
        createdDate: DateTime.now(),
      ));
    }
    notifyListeners();
  }
  void removeReviewByFeedbackId(int feedbackId, CountProvider countProvider) {
    _placeFeedbacks.removeWhere((placeFeedback) => placeFeedback.placeFeedbackId == feedbackId);
    // Also remove associated media
    _placeFeedbackMedia.removeWhere((media) => media.feedbackId == feedbackId);
    // Remove helpful/favorite data related to this feedback
    _placeFeedbackHelpfuls.removeWhere((helpful) => helpful.placeFeedbackId == feedbackId);
    notifyListeners();
    countProvider.decrementReviewCount();
  }

  void addOrUpdateReview(PlaceFeedback placeFeedback, CountProvider countProvider) {
    // Check if there’s an existing review by the user for the same place
    int index = _placeFeedbacks.indexWhere((feedback) =>
    feedback.userId == placeFeedback.userId &&
        feedback.placeId == placeFeedback.placeId
    );

    if (index != -1) {
      // Update existing review
      _placeFeedbacks[index] = placeFeedback;
    } else {
      // Add a new review
      _placeFeedbacks.add(placeFeedback);
      countProvider.incrementReviewCount(); // Increment count for a new review
    }

    notifyListeners();
  }

  List<PlaceFeedbackHelpful> getHelpfulsByFeedbackId(int feedbackId) {
    return _placeFeedbackHelpfuls.where((helpful) => helpful.placeFeedbackId == feedbackId).toList();
  }

  List<PlaceFeedbackMedia> getMediaByPlaceId(int placeId) {
    return _placeFeedbackMedia.where((media) =>
        _placeFeedbacks.any((feedback) => feedback.placeFeedbackId == media.feedbackId && feedback.placeId == placeId)
    ).toList();
  }

  // Retrieve a review by its ID
  PlaceFeedback? getReviewById(int id) {
    return _placeFeedbacks.firstWhereOrNull((placeFeedback) => placeFeedback.placeFeedbackId == id);
  }

  // Get all reviews by a specific userId
  List<PlaceFeedback> getReviewsByUserId(String userId) {
    return _placeFeedbacks.where((placeFeedback) => placeFeedback.userId == userId).toList();
  }

  List<PlaceFeedback> getReviewsByUserIdAndPlaceId(String userId, int placeId) {
    return _placeFeedbacks.where((feedback) => feedback.userId == userId && feedback.placeId == placeId).toList();
  }

  // Get all reviews for a specific placeId
  List<PlaceFeedback> getReviewsByPlaceId(int placeId) {
    return _placeFeedbacks.where((placeFeedback) => placeFeedback.placeId == placeId).toList();
  }

  // --------------------------
  // Methods to Manage Review Media
  // --------------------------

  // Add media to a review
  void addReviewMedia(PlaceFeedbackMedia media) {
    _placeFeedbackMedia.add(media);
    notifyListeners();
  }

  // Remove media from a review
  void removeReviewMedia(int mediaId) {
    _placeFeedbackMedia.removeWhere((media) => media.id == mediaId);
    notifyListeners();
  }

  // Update media
  void updateReviewMedia(PlaceFeedbackMedia updatedMedia) {
    int index = _placeFeedbackMedia.indexWhere((m) => m.id == updatedMedia.id);
    if (index != -1) {
      _placeFeedbackMedia[index] = updatedMedia;
      notifyListeners();
    }
  }

  // Get media by reviewId
  List<PlaceFeedbackMedia> getMediaByReviewId(int reviewId) {
    return _placeFeedbackMedia.where((media) => media.feedbackId == reviewId).toList();
  }
}
