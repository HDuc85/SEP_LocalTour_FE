import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:localtourapp/config/appConfig.dart';
import 'package:localtourapp/config/secure_storage_helper.dart';
import 'package:localtourapp/models/markPlace/markPlaceModel.dart';
import 'package:localtourapp/services/location_Service.dart';
import 'package:localtourapp/services/mark_place_service.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart'; // Import for firstWhereOrNull
import '../../base/back_to_top_button.dart';
import '../../base/weather_icon_button.dart';
import '../detail_page/detail_page.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({Key? key}) : super(key: key);

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  final MarkplaceService _markplaceService = MarkplaceService();
  List<markPlaceModel> markPlaces = [];
  late String userId;
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;
  String _language = 'vi';

  @override
  void initState() {
    _scrollController.addListener(_scrollListener);
    _fetchMarkPlaceData();
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

  Future<void> _fetchMarkPlaceData() async {
    final fetchedmarkData = await _markplaceService.getAllMarkPlace();
    var language = await SecureStorageHelper().readValue(AppConfig.language);
    
    setState(() {
      _language = language!;
      markPlaces = fetchedmarkData;
    });
  }

  @override
  Widget build(BuildContext context) {
    
    
    if (markPlaces.isEmpty) {
      return const Center(
        child: Text(
          "No bookmarks yet.",
          style: TextStyle(fontSize: 18),
        ),
      );
    }
    return Stack(
      children: [
        ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 16.0),
                itemCount: markPlaces.length,
                itemBuilder: (context, index) {
                  final place = markPlaces[index];
                  return GestureDetector(
                    onTap: () {
                      _navigateToDetail(place.placeId);
                    },
                    child: Column(
                      children: [
                        // Place Image and Details
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
                              const SizedBox(
                                width: 8,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      place.placeName,
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        // Bookmark Actions Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.bookmark,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                // xóa bookmark Fuction
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Bookmark removed')),
                                );
                              },
                            ),
                            Text(
                              '${_language != 'vi' ? 'Added on': 'Thêm vào lúc:'}: ${place.createdDate.toLocal().toShortDateString()}',
                              style: const TextStyle(
                                  fontSize: 12.0, color: Colors.black),
                            ),
                            Row(
                              children: [
                                 Text(_language != 'vi' ? 'Visited' : 'Đã đi',
                                    style: TextStyle(fontSize: 12.0)),
                                Checkbox(
                                  value: place.isVisited,
                                  onChanged: (bool? value) {
                                    // Update isVisited Function
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) => const Divider(
                  color: Colors.black, // Divider color
                  thickness: 2,
                  height: 2, // Divider thickness
                ),
              ),

        // Positioned Weather Icon Button (Bottom Left)
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
  }

  // Navigation method to DetailPage using named routes
  void _navigateToDetail(int placeId) {
    final selectedPlace =
        markPlaces.firstWhereOrNull((place) => place.placeId == placeId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailPage(
          placeId: selectedPlace!.placeId,
        ),
      ),
    );
  }
}

// Extension to format DateTime
extension DateHelpers on DateTime {
  String toShortDateString() {
    return "$day/$month/$year";
  }
}

// Ensure you have a DetailPage that can accept the arguments
