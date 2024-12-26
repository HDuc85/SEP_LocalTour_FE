import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:localtourapp/models/places/traveled_place_model.dart';
import 'package:localtourapp/page/bookmark/bookmark_page.dart';
import 'package:localtourapp/services/traveled_place_service.dart';

import '../../../base/back_to_top_button.dart';
import '../../../base/weather_icon_button.dart';
import '../../../config/appConfig.dart';
import '../../../config/secure_storage_helper.dart';
import '../../detail_page/detail_page.dart';

class HistoryTabbar extends StatefulWidget {
  const HistoryTabbar({super.key});

  @override
  State<HistoryTabbar> createState() => _HistoryTabbarState();
}

class _HistoryTabbarState extends State<HistoryTabbar> {
  bool _showBackToTopButton = false;
  final ScrollController _scrollController = ScrollController();
  final TraveledPlaceService _traveledPlaceService = TraveledPlaceService();
  List<TraveledPlaceModel> traveledPlaces = [];
  String _languageCode = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _fetchTraveledPlaceData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _navigateToWeatherPage() {
    Navigator.pushNamed(context, '/weather');
  }

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

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _fetchTraveledPlaceData() async {
    var languageCode =
    await SecureStorageHelper().readValue(AppConfig.language);
    try {
      final fetchedData = await _traveledPlaceService.getAllTraveledPlace();
      setState(() {
        traveledPlaces = fetchedData;
        _languageCode = languageCode!;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching traveled places: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          traveledPlaces.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.all(8.0),
            itemCount: traveledPlaces.length,
            itemBuilder: (context, index) {
              final place = traveledPlaces[index];
              return _buildPlaceCard(place);
            },
            separatorBuilder: (context, index) => const SizedBox(height: 16),
          ),

          // Positioned Weather Icon Button (Bottom Left)
          Positioned(
            bottom: 16,
            left: 16,
            child: WeatherIconButton(
              onPressed: _navigateToWeatherPage,
              assetPath: 'assets/icons/weather.png',
            ),
          ),

          // Positioned Back to Top Button (Bottom Right) with AnimatedOpacity
          Positioned(
            bottom: 16,
            right: 16,
            child: AnimatedOpacity(
              opacity: _showBackToTopButton ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: _showBackToTopButton
                  ? FloatingActionButton(
                backgroundColor: const Color(0xFF6A11CB),
                onPressed: _scrollToTop,
                child: const Icon(Icons.arrow_upward, color: Colors.white),
              )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/empty_state.png',
            height: 150,
          ),
          const SizedBox(height: 20),
          Text(
            _languageCode == 'vi'
                ? "Địa điểm đã đi đang trống.\nHãy đi đâu đó để thêm vào!"
                : "Traveled place is empty.\nGo somewhere to add it!",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceCard(TraveledPlaceModel place) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailPage(placeId: place.placeId),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 6,
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  place.placePhotoDisplay,
                  width: 75,
                  height: 75,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 75,
                    height: 75,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
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
                    const SizedBox(height: 4),
                    Text(
                      place.wardName,
                      style: const TextStyle(fontSize: 14.0, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        _buildVisitInfo(
                          _languageCode == 'vi' ? "Lần đầu" : "First Visit",
                          place.firstVisitDate.toShortDateString(),
                        ),
                        const SizedBox(width: 16),
                        _buildVisitInfo(
                          _languageCode == 'vi' ? "Lần cuối" : "Last Visit",
                          place.lastVisitDate.toShortDateString(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildVisitInfo(
                      _languageCode == 'vi' ? "Số lần ghé thăm" : "Visited Times",
                      place.traveledTimes.toString(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisitInfo(String label, String value) {
    return Row(
      children: [
        Text(
          "$label:",
          style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 12.0),
        ),
      ],
    );
  }
}

