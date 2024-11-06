import 'dart:async';

class PlaceScoreManager {
  PlaceScoreManager._privateConstructor();
  static final PlaceScoreManager _instance = PlaceScoreManager._privateConstructor();
  static PlaceScoreManager get instance => _instance;

  final Map<int, int> _placeScores = {};

  // Stream to notify listeners on updates (if needed)
  final StreamController<int> _scoreUpdates = StreamController<int>.broadcast();
  Stream<int> get scoreUpdates => _scoreUpdates.stream;

  // Method to set a score for a place
  void setScore(int placeId, int score) {
    _placeScores[placeId] = score;
    _scoreUpdates.add(placeId);
  }

  // Method to get a score for a place with logging
  int getScore(int placeId) {
    int score = _placeScores[placeId] ?? 0;
    return score;
  }

  // Optional cleanup for streams
  void dispose() => _scoreUpdates.close();
}
