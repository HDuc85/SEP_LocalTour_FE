import 'dart:math';
import '../models/places/place.dart';
import '../models/places/placetag.dart';
import '../models/places/placetranslation.dart';
import 'place_score_manager.dart';

class CardInfo {
  final int placeCardInfoId;
  final String placeName;
  final int wardId;
  final String photoDisplay;
  final String iconUrl;
  final int score;
  final double distance;
  final List<int> tagIds;

  CardInfo({
    required this.placeCardInfoId,
    required this.placeName,
    required this.wardId,
    required this.photoDisplay,
    required this.iconUrl,
    required this.score,
    required this.distance,
    required this.tagIds,
  });
}

// Define the calculateDistance function here if not using a utility file
double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  var p = 0.017453292519943295; // Pi / 180
  var a = 0.5 -
      cos((lat2 - lat1) * p) / 2 +
      cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a));
}

CardInfo mapPlaceToCardInfo(Place place, double latitude, double longitude) {
  double distance =
      calculateDistance(latitude, longitude, place.latitude, place.longitude);

  PlaceTranslation translation = translations.firstWhere(
    (trans) => trans.placeId == place.placeId,
    orElse: () => PlaceTranslation(
      placeTranslationId: 0,
      placeId: place.placeId,
      languageCode: 'en',
      placeName: 'Unknown Place',
      address: '',
    ),
  );

  int score = PlaceScoreManager.instance.getScore(place.placeId);

  List<int> associatedTagIds = placeTags
      .where((pt) => pt.placeId == place.placeId)
      .map((pt) => pt.tagId)
      .toList();

  return CardInfo(
    placeCardInfoId: place.placeId,
    placeName: translation.placeName,
    wardId: place.wardId,
    photoDisplay: place.photoDisplay,
    iconUrl: 'assets/icons/logo.png',
    score: score,
    distance: distance,
    tagIds: associatedTagIds,
  );
}

List<CardInfo> getNearestPlaces(
    List<Place> places, double latitude, double longitude) {
  List<CardInfo> nearest = places
      .map((place) => mapPlaceToCardInfo(place, latitude, longitude))
      .toList();

  nearest.sort((a, b) => a.distance.compareTo(b.distance));

  return nearest.take(5).toList();
}

List<CardInfo> getFeaturedPlaces(
    List<Place> places, double latitude, double longitude) {
  List<CardInfo> featured = places
      .map((place) => mapPlaceToCardInfo(place, latitude, longitude))
      .toList();

  featured.sort((a, b) => b.score.compareTo(a.score));

  return featured.take(5).toList();
}

List<CardInfo> getNearestPlacesForTag(
    int tagId, List<Place> places, double latitude, double longitude) {
  List<Place> placesForTag = places.where((place) {
    return placeTags.any((placeTag) =>
        placeTag.tagId == tagId && placeTag.placeId == place.placeId);
  }).toList();
  return getNearestPlaces(placesForTag, latitude, longitude);
}

List<CardInfo> getFeaturedPlacesForTag(
    int tagId, List<Place> places, double latitude, double longitude) {
  List<Place> placesForTag = places.where((place) {
    return placeTags.any((placeTag) =>
        placeTag.tagId == tagId && placeTag.placeId == place.placeId);
  }).toList();
  return getFeaturedPlaces(placesForTag, latitude, longitude);
}

// Class representing a Tag Section (nearest and featured places for a tag)
class TagSection {
  final int tagId;
  final String tagPhotoUrl;
  final String tagName;
  final List<CardInfo> nearestPlaces;
  final List<CardInfo> featuredPlaces;

  TagSection({
    required this.tagId,
    required this.tagPhotoUrl,
    required this.tagName,
    required this.nearestPlaces,
    required this.featuredPlaces,
  });
}
