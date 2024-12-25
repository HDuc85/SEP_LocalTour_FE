import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:localtourapp/config/appConfig.dart';
import 'package:localtourapp/config/secure_storage_helper.dart';
import 'package:localtourapp/models/markPlace/markPlaceModel.dart';
import 'package:localtourapp/services/mark_place_service.dart';
import 'package:collection/collection.dart';
import 'package:shimmer/shimmer.dart';
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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          _language == 'vi' ? 'Trang đánh dấu' : 'Bookmark Page',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchMarkPlaceData,
            tooltip: _language == 'vi' ? 'Làm mới' : 'Refresh',
          ),
        ],
      ),
      body: Stack(
        children: [
          markPlaces.isEmpty
              ? Center(
            child: Text(
              _language == 'vi' ? 'Chưa có dấu trang nào' : "No bookmarks yet.",
              style: const TextStyle(fontSize: 18),
            ),
          )
              : ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 80.0),
            itemCount: markPlaces.length,
            itemBuilder: (context, index) {
              final place = markPlaces[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () => _navigateToDetail(place.placeId),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          // Image Section
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: place.photoDisplay,
                              width: 75,
                              height: 75,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(
                                  width: 75,
                                  height: 75,
                                  color: Colors.white,
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: 75,
                                height: 75,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Details Section
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Place Name
                                Text(
                                  place.placeName,
                                  style: Theme.of(context).textTheme.titleSmall,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                // Bookmark Actions
                                Row(
                                  children: [
                                    // Remove Bookmark Button
                                    IconButton(
                                      icon: const Icon(Icons.bookmark, color: Colors.red),
                                      onPressed: () async {
                                        bool success = await _markplaceService.deleteMarkPlace(place.placeId);
                                        if (success) {
                                          setState(() {
                                            markPlaces.removeAt(index);
                                          });
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                _language != 'vi'
                                                    ? 'Bookmark removed'
                                                    : 'Đã xóa dấu trang',
                                              ),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                _language != 'vi'
                                                    ? 'Failed to remove bookmark'
                                                    : 'Xóa dấu trang thất bại',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                    // Visited Checkbox
                                    Row(
                                      children: [
                                        Text(
                                          _language != 'vi' ? 'Visited' : 'Đã đi',
                                          style: const TextStyle(fontSize: 12.0),
                                        ),
                                        Checkbox(
                                          value: place.isVisited,
                                          onChanged: (bool? value) async {
                                            bool success = await _markplaceService.updateMarkPlace(place.placeId, value ?? false);
                                            if (success) {
                                              setState(() {
                                                place.isVisited = value ?? false;
                                              });
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    _language != 'vi'
                                                        ? 'Failed to update the status.'
                                                        : 'Cập nhật trạng thái thất bại.',
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                // Added Date
                                Text(
                                  '${_language != 'vi' ? 'Added on' : 'Thêm vào lúc'}: ${place.createdDate.toLocal().toShortDateString()}',
                                  style: const TextStyle(
                                      fontSize: 12.0, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
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
            left: 160,
            child: AnimatedOpacity(
              opacity: _showBackToTopButton ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: _showBackToTopButton
                  ? BackToTopButton(
                onPressed: _scrollToTop, languageCode: 'vi',
              )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
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
