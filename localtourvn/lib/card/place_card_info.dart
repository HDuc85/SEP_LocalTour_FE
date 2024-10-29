import 'dart:math';
import '../models/places/place.dart';
import '../models/places/placetag.dart';
import '../models/places/placetranslation.dart';

class CardInfo {
  final int placeCardInfoId;
  final String placeName;
  final int wardId;
  final String photoDisplay;
  final String iconUrl;
  final double rating;
  final int reviews;
  final double distance;

  CardInfo({
    required this.placeCardInfoId,
    required this.placeName,
    required this.wardId,
    required this.photoDisplay,
    required this.iconUrl,
    required this.rating,
    required this.reviews,
    required this.distance,
  });
}

// Define the calculateDistance function here if not using a utility file
double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  var p = 0.017453292519943295; // Pi / 180
  var a = 0.5 - cos((lat2 - lat1) * p) / 2 +
      cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a));
}

// Function to get nearest places based on user location
List<CardInfo> getNearestPlaces(List<Place> places, double userLatitude, double userLongitude) {
  // Create a list of CardInfo with calculated distances
  List<CardInfo> nearest = places.map((place) {
    // Calculate the distance between the user and this place
    double distance = calculateDistance(userLatitude, userLongitude, place.latitude, place.longitude);

    // Find the corresponding place translation for the placeId
    PlaceTranslation translation = translations.firstWhere(
          (trans) => trans.placeId == place.placeId,
      orElse: () => PlaceTranslation(
        placeTranslationId: 0,
        placeId: place.placeId,
        languageCode: 'en',
        placeName: 'Unknown Place', // Default if translation is missing
        address: '',
      ),
    );
    // Add a check to print missing translations
    if (translation.placeName == 'Unknown Place') {
      print('Missing translation for placeId: ${place.placeId}');
    }
    // Create and return a CardInfo object for this place
    return CardInfo(
      placeCardInfoId: place.placeId,
      placeName: translation.placeName,  // Get name from PlaceTranslation
      wardId: place.wardId,
      photoDisplay: place.photoDisplay,
      iconUrl: 'assets/icons/logo.png', // Adjust icon URL if needed
      rating: 4.5,  // Placeholder for rating, adjust as needed
      reviews: 1000,  // Placeholder for reviews, adjust as needed
      distance: distance,  // Use calculated distance
    );
  }).toList();

  // Sort the list by distance (ascending order)
  nearest.sort((a, b) => a.distance.compareTo(b.distance));

  // Return the top 5 nearest Places
  return nearest.take(5).toList();
}

// Function to get featured places
List<CardInfo> getFeaturedPlaces(List<Place> places, double userLatitude, double userLongitude) {
  List<CardInfo> featured = places.map((place) {
    double distance = calculateDistance(userLatitude, userLongitude, place.latitude, place.longitude);

    // Find the corresponding place translation for the placeId
    PlaceTranslation translation = translations.firstWhere(
          (trans) => trans.placeId == place.placeId,
      orElse: () => PlaceTranslation(
        placeTranslationId: 0,
        placeId: place.placeId,
        languageCode: 'en',
        placeName: 'Unknown Place', // Default if translation is missing
        address: '',
      ),
    );

    return CardInfo(
      placeCardInfoId: place.placeId,
      placeName: translation.placeName,
      wardId: place.wardId,
      photoDisplay: place.photoDisplay,
      iconUrl: 'assets/icons/logo.png', // Adjust as needed
      rating: 4.5, // Placeholder for rating
      reviews: 1000, // Placeholder for reviews
      distance: distance, // Use calculated distance
    );
  }).toList();

  featured.sort((a, b) => b.rating.compareTo(a.rating)); // Sort by rating
  return featured.take(5).toList(); // Return top 5 featured places
}

// Function to get nearest places for a specific tag
List<CardInfo> getNearestPlacesForTag(int tagId, List<Place> places) {
  // Filter places that match the tagId
  List<Place> placesForTag = places.where((place) {
    return placeTags.any((placeTag) => placeTag.tagId == tagId && placeTag.placeId == place.placeId);
  }).toList();
  // Call the nearest places function
  return getNearestPlaces(placesForTag, 10.77689, 106.701981);
}

// Function to get featured places for a specific tag
List<CardInfo> getFeaturedPlacesForTag(int tagId, List<Place> places) {
  // Filter places that match the tagId
  List<Place> placesForTag = places.where((place) {
    return placeTags.any((placeTag) => placeTag.tagId == tagId && placeTag.placeId == place.placeId);
  }).toList();
  // Call the featured places function
  return getFeaturedPlaces(placesForTag, 10.77689, 106.701981);
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
