// lib/providers/review_provider.dart

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:localtourapp/models/places/placefeedback.dart';
import 'package:localtourapp/models/places/placefeedbackmedia.dart';

class ReviewProvider with ChangeNotifier {
  // Private lists to hold reviews and their media
  List<PlaceFeedback> _placeFeedbacks = [];
  List<PlaceFeedbackMedia> _placeFeedbackMedia = [];

  // Constructor to initialize with optional initial data
  ReviewProvider({
    List<PlaceFeedback>? placeFeedbacks,
    List<PlaceFeedbackMedia>? placeFeedbackMedia,
  }) {
    _placeFeedbacks = placeFeedbacks ?? [];
    _placeFeedbackMedia = placeFeedbackMedia ?? [];
  }

  // Getters to access the private lists
  List<PlaceFeedback> get placeFeedbacks => _placeFeedbacks;
  List<PlaceFeedbackMedia> get placeFeedbackMedia => _placeFeedbackMedia;

  // --------------------------
  // Methods to Manage Reviews
  // --------------------------

  // Add a new review
  void addReview(PlaceFeedback placeFeedback) {
    _placeFeedbacks.add(placeFeedback);
    notifyListeners();
  }

  // Remove a review by its ID
  void removeReview(int id) {
    _placeFeedbacks.removeWhere((placeFeedback) => placeFeedback.placeFeedbackId == id);
    // Also remove associated media
    _placeFeedbackMedia.removeWhere((media) => media.feedbackId == id);
    notifyListeners();
  }

  // Update an existing review
  void updateReview(PlaceFeedback updatedReview) {
    int index = _placeFeedbacks.indexWhere((r) => r.placeFeedbackId == updatedReview.placeFeedbackId);
    if (index != -1) {
      _placeFeedbacks[index] = updatedReview;
      notifyListeners();
    }
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
