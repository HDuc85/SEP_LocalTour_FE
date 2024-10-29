// // utils/place_utils.dart
// import 'dart:math';
//
// import '../models/place.dart'; // Import the Place model
//
// class PlaceUtils {
//   static List<Place> getNearestPlaces(List<Place> places, double userLongitude, double userLatitude) {
//     places.sort((a, b) {
//       double distanceA = calculateDistance(userLatitude, userLongitude, a.latitude, a.longitude);
//       double distanceB = calculateDistance(userLatitude, userLongitude, b.latitude, b.longitude);
//       return distanceA.compareTo(distanceB);
//     });
//     return places.take(5).toList(); // For demonstration, we return 3 nearest places
//   }
//
//   static List<Place> getFeaturedPlaces(List<Place> places) {
//     places.sort((a, b) => b.rating.compareTo(a.rating)); // Sort by rating
//     return places.take(5).toList(); // Return 3 featured places
//   }
//
//   // Simple method to calculate distance (you can use more accurate methods if needed)
//   static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
//     var p = 0.017453292519943295; // Pi / 180
//     var a = 0.5 - cos((lat2 - lat1) * p) / 2 +
//         cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
//     return 12742 * asin(sqrt(a)); // 2 * R * asin...
//   }
// }
