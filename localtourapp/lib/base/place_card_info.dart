import 'dart:math';

class CardInfo {
  final int placeCardInfoId;
  final String placeName;
  final int wardId;
  final String photoDisplay;
  final String iconUrl;
  final double score;
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
