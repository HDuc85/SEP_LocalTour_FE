// lib/page/search_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:localtourapp/page/searchpage/second_place_card.dart';
import '../../base/const.dart';
import '../../base/filter_option.dart';
import '../../base/place_card_info.dart';
import '../../base/place_score_manager.dart';
import '../../models/places/place.dart';
import '../../models/places/placemedia.dart';
import '../../models/places/placetag.dart';
import '../../models/places/placetranslation.dart';
import '../../models/places/tag.dart';
import 'tags_modal.dart'; // Ensure correct path

class SearchPage extends StatefulWidget {
  final FilterOption initialFilter;
  final List<int> initialTags;

  const SearchPage({
    Key? key,
    this.initialFilter = FilterOption.none,
    this.initialTags = const [],
  }) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Place> placeList = dummyPlaces;
  String searchText = "";
  List<CardInfo> cardInfoList = [];
  List<int> selectedTags = [];
  Position? _currentPosition;
  StreamSubscription<Position>? _positionSubscription;
  FilterOption _selectedFilter = FilterOption.none;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
    selectedTags = List.from(widget.initialTags);
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, handle accordingly.
      setState(() {});
      return;
    }

    // Check for location permissions.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, handle accordingly.
        setState(() {});
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle accordingly.
      setState(() {});
      return;
    }

    // When permissions are granted, get the position.
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentPosition = position;
      _generateCardInfoList();
    });

    // Optional: Listen to position changes.
    _positionSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        _currentPosition = position;
        _generateCardInfoList();
      });
    });
  }

  void _generateCardInfoList() {
    if (_currentPosition == null) {
      return; // Can't calculate distance without position.
    }

    cardInfoList = dummyPlaces.map((place) {
      // Fetch translation
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

      // Fetch score
      double score = PlaceScoreManager.instance.getScore(place.placeId);

      // Calculate distance
      double distance = calculateDistance(_currentPosition!.latitude,
          _currentPosition!.longitude, place.latitude, place.longitude);

      // Fetch associated tagIds from placeTags
      List<int> associatedTagIds = placeTags
          .where((pt) => pt.placeId == place.placeId)
          .map((pt) => pt.tagId)
          .toList();

      return CardInfo(
        placeCardInfoId: place.placeId,
        placeName: translation.placeName,
        wardId: place.wardId,
        photoDisplay: place.photoDisplay,
        iconUrl: 'assets/icons/logo.png', // Or use place.iconUrl if available
        score: score,
        distance: distance, // Assign the fetched distance
        tagIds: associatedTagIds, // Assign the fetched tagIds
      );
    }).toList();

    // Apply initial filter if any
    if (_selectedFilter == FilterOption.nearest) {
      cardInfoList.sort((a, b) => a.distance.compareTo(b.distance));
    } else if (_selectedFilter == FilterOption.featured) {
      cardInfoList.sort((a, b) => b.score.compareTo(a.score));
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  // New method to build filter buttons
  Widget _buildFilterButton(
      String text, Color color, FilterOption filterOption) {
    bool isSelected = _selectedFilter == filterOption;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          if (isSelected) {
            _selectedFilter = FilterOption.none;
          } else {
            _selectedFilter = filterOption;
          }
          _generateCardInfoList(); // Regenerate list based on new filter
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? Constants.selectedState
            : Constants.defaultState, // Highlight if selected
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 28),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected
              ? Colors.white
              : Colors.black, // Text color based on selection
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter cardInfoList based on searchText and selectedTags
    List<CardInfo> filteredList = cardInfoList.where((card) {
      final matchesSearch =
          card.placeName.toLowerCase().contains(searchText.toLowerCase());
      final matchesTags = selectedTags.isEmpty ||
          card.tagIds.any((tagId) => selectedTags.contains(tagId));
      return matchesSearch && matchesTags;
    }).toList();

    // No need to sort here since sorting is handled in _generateCardInfoList

    // Optionally, show a loading indicator while fetching the location
    if (_currentPosition == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF2EAD3),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          title: Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.black),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2EAD3),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            Expanded(
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                    // Optionally, you can debounce the search input
                  });
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Colors.black),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row of buttons (Nearest, Featured, Tags)
          Container(
            margin: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
            child: Row(
              children: [
                _buildFilterButton(
                    "Nearest", const Color(0xFF99C896), FilterOption.nearest),
                const SizedBox(width: 5),
                _buildFilterButton(
                    "Featured", const Color(0xFFAAFF00), FilterOption.featured),
                const SizedBox(width: 5),
                Flexible(
                  child: OutlinedButton(
                    onPressed: () {
                      showTagsModal(
                        context: context,
                        selectedTags: selectedTags,
                        onSelectedTagsChanged: (updatedTags) {
                          setState(() {
                            selectedTags = updatedTags;
                            _generateCardInfoList(); // Update list based on new tags
                          });
                        },
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD6B588)),
                      backgroundColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Tags",
                          style: TextStyle(color: Colors.black),
                        ),
                        Icon(Icons.arrow_forward, color: Colors.black),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Display selected tags as horizontally scrollable list
          if (selectedTags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: selectedTags.map((tagId) {
                    final tag = listTag.firstWhere(
                      (t) => t.tagId == tagId,
                      orElse: () => Tag(
                        tagId: tagId,
                        tagPhotoUrl: 'assets/icons/default.png',
                        tagName: 'Unknown',
                      ),
                    );
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Chip(
                        label: Text(tag.tagName),
                        deleteIcon: const Icon(Icons.close),
                        onDeleted: () {
                          setState(() {
                            selectedTags.remove(tagId);
                            _generateCardInfoList(); // Update list after removing tag
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          // List of place cards with dividers
          Expanded(
            child: filteredList.isNotEmpty
                ? ListView.separated(
                    itemCount: filteredList.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 5,
                    ),
                    itemBuilder: (context, index) {
                      final cardInfo = filteredList[index];
                      return GestureDetector(
                        onTap: () {
                          _navigateToDetail(cardInfo.placeCardInfoId);
                        },
                      child: SecondPlaceCard(
                        placeCardId: cardInfo.placeCardInfoId,
                        placeName: cardInfo.placeName,
                        ward: cardInfo.wardId,
                        photoDisplay: cardInfo.photoDisplay,
                        iconUrl: cardInfo.iconUrl,
                        score: cardInfo.score,
                        distance: cardInfo.distance,
                      ),
                      );
                    },
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off,
                            size: 80, color: Colors.grey),
                        Text(
                          "No places match your selected categories.",
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey[700]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
  void _navigateToDetail(int placeId) {
    // Fetch necessary data based on placeId if needed
    Place? selectedPlace =
    placeList.firstWhereOrNull((place) => place.placeId == placeId);

    if (selectedPlace == null) {
      // Handle the case where the place is not found
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Place not found')),
      );
      return;
    }

    // Fetch translation
    PlaceTranslation? selectedTranslation = translations.firstWhereOrNull(
          (trans) => trans.placeId == selectedPlace.placeId,
    );

    // Fetch media list
    List<PlaceMedia> filteredMediaList = mediaList
        .where((media) => media.placeId == selectedPlace.placeId)
        .toList();

    print('Navigating to DetailPage with placeId: $placeId and mediaList length: ${filteredMediaList.length}');

    Navigator.pushNamed(
      context,
      '/detail',
      arguments: {
        'place': selectedPlace,
        'placeName': selectedTranslation?.placeName ?? 'Unknown Place',
        'mediaList': filteredMediaList,
        'placeId': selectedPlace.placeId,
      },
    );
  }
}

// Extension method for firstWhereOrNull
extension FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}