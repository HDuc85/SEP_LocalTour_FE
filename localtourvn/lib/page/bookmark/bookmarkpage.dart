// lib/page/bookmarkpage.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart'; // Import for firstWhereOrNull
import '../../base/place_card_info.dart';
import '../../models/places/markplace.dart';
import '../../models/places/place.dart';
import '../../models/places/placetranslation.dart';
import '../../base/place_score_manager.dart';
import 'bookmarkmanager.dart';

class BookmarkPage extends StatelessWidget {
  const BookmarkPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height,
      width: size.width,
      child: Scaffold(
        // AppBar with title
        appBar: AppBar(
          title: const Text("Bookmarks"),
        ),
        body: Consumer<BookmarkManager>(
          builder: (context, bookmarkManager, child) {
            final List<int> bookmarkedPlaceIds =
                bookmarkManager.bookmarkedPlaceIds;

            if (bookmarkedPlaceIds.isEmpty) {
              return const Center(
                child: Text(
                  "No bookmarks yet.",
                  style: TextStyle(fontSize: 18),
                ),
              );
            }

            return FutureBuilder<Position?>(
              future: _getCurrentPosition(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError || !snapshot.hasData) {
                  return const Center(child: Text("Unable to fetch location."));
                } else {
                  final currentPosition = snapshot.data!;
                  return ListView.separated(

                    padding: const EdgeInsets.only(bottom: 16.0),
                    itemCount: bookmarkedPlaceIds.length,
                    itemBuilder: (context, index) {
                      int placeId = bookmarkedPlaceIds[index];
                      // Access MarkPlace associated with the placeId via the instance
                      MarkPlace? markPlace =
                          bookmarkManager.markPlaces.firstWhereOrNull(
                        (mp) => mp.placeId == placeId,
                      );

                      if (markPlace == null) {
                        // Handle missing MarkPlace
                        return ListTile(
                          leading: const Icon(Icons.error, color: Colors.red),
                          title: Text('Place ID $placeId not found'),
                          subtitle:
                              const Text('This place may have been removed.'),
                        );
                      }
                      // Find the corresponding Place
                      Place? place = dummyPlaces
                          .firstWhereOrNull((p) => p.placeId == placeId);

                      if (place == null) {
                        // Handle missing Place
                        return ListTile(
                          leading: const Icon(Icons.error, color: Colors.red),
                          title: Text('Place ID $placeId not found'),
                          subtitle:
                              const Text('This place may have been removed.'),
                        );
                      }

                      // Fetch translation
                      PlaceTranslation? translation =
                          translations.firstWhereOrNull(
                        (trans) => trans.placeId == place.placeId,
                      );

                      // Fetch score
                      int score =
                          PlaceScoreManager.instance.getScore(place.placeId);

                      // Calculate distance from current location
                      double distance = calculateDistance(
                        currentPosition.latitude,
                        currentPosition.longitude,
                        place.latitude,
                        place.longitude,
                      );

                      return Column(
                        children: [
                          // Place Image
                          Container(
                            color: Colors.white,
                            child: Row(
                              children: [
                                ClipRRect(
                                  child: Image.network(
                                    place.photoDisplay,
                                    width: 75,
                                    height: 75,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(
                                      width: 75,
                                      height: 75,
                                      color: Colors.grey,
                                      child: const Icon(Icons.image,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8,),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        translation?.placeName ?? "Unknown Place",
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'Ward ${place.wardId}',
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 14),
                                      ),
                                      Row(
                                        children: [
                                          Image.asset(
                                            'assets/icons/logo.png',
                                            width: 16,
                                            height: 16,
                                          ),
                                          const SizedBox(width: 8,),
                                          Text('$score'),
                                          const Spacer(),
                                          const Icon(Icons.location_on,
                                              color: Colors.red, size: 16),
                                          const SizedBox(width: 8.0),
                                          Text(
                                            '${distance.toStringAsFixed(2)} km',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          //row here:
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.bookmark,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  bookmarkManager.removeBookmark(place.placeId);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Bookmark removed')),
                                  );
                                },
                              ),
                              Text(
                                'Added on: ${markPlace.createdDate.toLocal().toShortDateString()}',
                                style: const TextStyle(
                                    fontSize: 12.0, color: Colors.black),
                              ),
                              Row(
                                children: [
                                  const Text('Visited',
                                      style: TextStyle(fontSize: 12.0)),
                                  Checkbox(
                                    value: markPlace.isVisited,
                                    onChanged: (bool? value) {
                                      bookmarkManager
                                          .toggleVisited(place.placeId);
                                    },
                                  ),
                                ],
                              ),

                            ],
                          ),
                        ],
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(
                      color: Colors.black, // Divider color
                      thickness: 2,
                      height: 2,// Divider thickness
                    ),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }

  // Method to get the current location
  Future<Position?> _getCurrentPosition() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Check if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled, handle accordingly.
        return null;
      }

      // Check for location permissions.
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied, handle accordingly.
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle accordingly.
        return null;
      }

      // When permissions are granted, get the position.
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      // Handle exceptions
      print('Error fetching location: $e');
      return null;
    }
  }
}

// Extension to format DateTime
extension DateHelpers on DateTime {
  String toShortDateString() {
    return "$day/$month/$year";
  }
}
