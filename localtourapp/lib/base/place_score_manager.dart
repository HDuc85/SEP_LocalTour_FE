import 'dart:async';

class PlaceScoreManager {
  PlaceScoreManager._privateConstructor();
  static final PlaceScoreManager _instance = PlaceScoreManager._privateConstructor();
  static PlaceScoreManager get instance => _instance;

  final Map<int, double> _placeScores = {};
  final Map<int, int> _placeReviewCounts = {};

  void setReviewCount(int placeId, int count) {
    _placeReviewCounts[placeId] = count;
    _scoreUpdates.add(placeId);
  }

  int getReviewCount(int placeId) {
    return _placeReviewCounts[placeId] ?? 0;
  }

  // Stream to notify listeners on updates (if needed)
  final StreamController<int> _scoreUpdates = StreamController<int>.broadcast();
  Stream<int> get scoreUpdates => _scoreUpdates.stream;

  // Method to set a score for a place
  void setScore(int placeId, double score) {
    _placeScores[placeId] = score;
    _scoreUpdates.add(placeId);
  }

  // Method to get a score for a place with logging
  double getScore(int placeId) {
    double score = _placeScores[placeId] ?? 0;
    return score;
  }

  // Optional cleanup for streams
  void dispose() => _scoreUpdates.close();
}
