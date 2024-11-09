// lib/page/bookmarkpage.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart'; // Import for firstWhereOrNull
import '../../base/backtotopbutton.dart';
import '../../base/place_card_info.dart';
import '../../base/weathericonbutton.dart';
import '../../models/places/markplace.dart';
import '../../models/places/place.dart';
import '../../models/places/placetranslation.dart';
import '../../base/place_score_manager.dart';
import 'bookmarkmanager.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({Key? key}) : super(key: key);

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;

  Position? _currentPosition;

  @override
  void initState() {
    _scrollController.addListener(_scrollListener);
    _fetchCurrentPosition();
    super.initState();
  }

  @override
  void dispose() {
    // Remove listener and dispose the controller to prevent memory leaks
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  // Listener to handle scroll events
  void _scrollListener() {
    if (_scrollController.offset >= 200 && !_showBackToTopButton) {
      setState(() {
        _showBackToTopButton = true;
      });
    } else if (_scrollController.offset < 200 && _showBackToTopButton) {
      setState(() {
        _showBackToTopButton = false;
      });
    }
  }

  // Function to navigate to the Weather page
  void _navigateToWeatherPage() {
    Navigator.pushNamed(context, '/weather');
  }

  // Function to scroll back to the top
  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  // Method to fetch the current location once
  Future<void> _fetchCurrentPosition() async {
    try {
      Position? position = await _getCurrentPosition();
      if (position != null) {
        setState(() {
          _currentPosition = position;
        });
      }
    } catch (e) {
      // Handle exceptions, possibly set an error state
      print('Error fetching location: $e');
      setState(() {
        _currentPosition = null; // Or set an error flag
      });
    }
  }

  // Method to get the current location with permission handling
  Future<Position?> _getCurrentPosition() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Check if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled, handle accordingly.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled.')),
        );
        return null;
      }

      // Check for location permissions.
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied, handle accordingly.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle accordingly.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Location permissions are permanently denied, we cannot request permissions.')),
        );
        return null;
      }

      // When permissions are granted, get the position.
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      // Handle exceptions
      print('Error in _getCurrentPosition: $e');
      return null;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<BookmarkManager>(
      builder: (context, bookmarkManager, child) {
        final List<int> bookmarkedPlaceIds = bookmarkManager.bookmarkedPlaceIds;

        if (bookmarkedPlaceIds.isEmpty) {
          return const Center(
            child: Text(
              "No bookmarks yet.",
              style: TextStyle(fontSize: 18),
            ),
          );
        }

        return Stack(
          children: [
            _currentPosition == null
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    controller: _scrollController,
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
                      double score =
                          PlaceScoreManager.instance.getScore(place.placeId);

                      // Calculate distance from current location
                      double distance = calculateDistance(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
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
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                      width: 75,
                                      height: 75,
                                      color: Colors.grey,
                                      child: const Icon(Icons.image,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        translation?.placeName ??
                                            "Unknown Place",
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
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          Text('$score'),
                                          const Spacer(),
                                          const Icon(Icons.location_on,
                                              color: Colors.red, size: 16),
                                          const SizedBox(width: 8.0),
                                          Text(
                                            '${distance.toStringAsFixed(2)} km',
                                            style:
                                                const TextStyle(fontSize: 12),
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
                      height: 2, // Divider thickness
                    ),
                  ),

            Positioned(
              bottom: 0,
              left: 20,
              child: WeatherIconButton(
                onPressed: _navigateToWeatherPage,
                assetPath: 'assets/icons/weather.png',
              ),
            ),

            // Positioned Back to Top Button (Bottom Right) with AnimatedOpacity
            Positioned(
              bottom: 12,
              left: 110,
              child: AnimatedOpacity(
                opacity: _showBackToTopButton ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: _showBackToTopButton
                    ? BackToTopButton(
                        onPressed: _scrollToTop,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        );
      },
    );
  }
}
double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
    ) {
  const double earthRadius = 6371; // Radius of the Earth in kilometers
  double dLat = _degreesToRadians(endLatitude - startLatitude);
  double dLon = _degreesToRadians(endLongitude - startLongitude);

  double a =
      (sin(dLat / 2) * sin(dLat / 2)) +
          cos(_degreesToRadians(startLatitude)) *
              cos(_degreesToRadians(endLatitude)) *
              (sin(dLon / 2) * sin(dLon / 2));

  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadius * c;
}

double _degreesToRadians(double degrees) {
  return degrees * (pi / 180);
}
// Extension to format DateTime
extension DateHelpers on DateTime {
  String toShortDateString() {
    return "$day/$month/$year";
  }
}
