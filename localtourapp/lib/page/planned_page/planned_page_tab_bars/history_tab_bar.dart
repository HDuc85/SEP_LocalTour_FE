import 'package:flutter/material.dart';
import 'package:localtourapp/models/places/traveled_place_model.dart';
import 'package:localtourapp/page/bookmark/bookmark_page.dart';
import 'package:localtourapp/services/traveled_place_service.dart';

import '../../../base/back_to_top_button.dart';
import '../../../base/weather_icon_button.dart';

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
  final String _languageCode = 'vi';

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
    print('Fetching traveled places...');
    try {
      final fetchedData = await _traveledPlaceService.getAllTraveledPlace();
      print('Fetched Data: $fetchedData');
      setState(() {
        traveledPlaces = fetchedData;
      });
    } catch (e) {
      print('Error fetching traveled places: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        traveledPlaces.isEmpty
            ? Center(
                child: Text(
                  _languageCode == 'vi'
                      ? "Địa điểm đã đi đang trống. Hãy đi đâu đó để thêm vào!"
                      : "Traveled place is empty. Go somewhere to add it!",
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 16.0),
                itemCount: traveledPlaces.length,
                itemBuilder: (context, index) {
                  final place = traveledPlaces[index];
                  return Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              child: Image.network(
                                place.placePhotoDisplay,
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
                            const SizedBox(width: 8),
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
                                  Text(
                                    place.wardName,
                                    style: const TextStyle(fontSize: 14.0),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        _languageCode == 'vi'
                                            ? "Lần đầu: ${place.firstVisitDate.toShortDateString()}"
                                            : "First Visit: ${place.firstVisitDate.toShortDateString()}",
                                        style: const TextStyle(fontSize: 12.0),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _languageCode == 'vi'
                                            ? "Lần cuối: ${place.firstVisitDate.toShortDateString()}"
                                            : "First Visit: ${place.firstVisitDate.toShortDateString()}",
                                        style: const TextStyle(fontSize: 12.0),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    _languageCode == 'vi'
                                        ? "Visited Times: ${place.traveledTimes}"
                                        : "Số lần ghé thăm: ${place.traveledTimes}",
                                    style: const TextStyle(fontSize: 12.0),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) => const Divider(
                  color: Colors.black,
                  thickness: 2,
                  height: 2,
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
}
