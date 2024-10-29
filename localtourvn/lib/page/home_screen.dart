import 'package:flutter/material.dart';
import '../card/place_card.dart';
import '../card/place_card_info.dart';
import '../models/places/place.dart';
import '../models/places/placemedia.dart';
import '../models/places/placetranslation.dart';
import '../models/tag.dart';
import '../now_location.dart';
import '../search_bar_icon.dart';
import '../custombutton.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  final Map<int, GlobalKey> tagSectionKeys = {}; // Store GlobalKeys for tag sections
  List<Place> placeList = dummyPlaces;
  List<CardInfo> nearestLocation = [];
  List<CardInfo> featuredPlaces = [];
  List<PlaceMedia> mediaList = [];
  Map<int, bool> tagToggleStates = {};

  @override
  void initState() {
    super.initState();

    // Generate mediaList
    mediaList = generatePlaceMediaForAllPlaces(dummyPlaces);

    double userLongitude = 106.701981;
    double userLatitude = 10.77689;

    nearestLocation =
        getNearestPlaces(dummyPlaces, userLatitude, userLongitude);
    featuredPlaces =
        getFeaturedPlaces(dummyPlaces, userLatitude, userLongitude);

    // Manually choose the tag IDs for the 6 Tag Sections (e.g., tagId7 to tagId12)
    List<int> selectedTagIds = [7, 8, 9, 10, 11, 12];
    for (var tagId in selectedTagIds) {
      tagSectionKeys[tagId] = GlobalKey(); // Assign a GlobalKey for each tagId
    }

    // Initialize the toggle states for the specific tags
    for (var tag
        in listTag.where((tag) => selectedTagIds.contains(tag.tagId))) {
      tagToggleStates[tag.tagId] = false; // Set default to "Nearest"
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          const NowLocation(), // 1. NowLocation widget
          const SizedBox(height: 20),
          SearchBarIcon(
              placeTranslations: translations), // 2. Search bar widget
          const SizedBox(height: 20),

          // 3. Display the first 6 tags (tagId 1 to 6) in a pink rectangle
          _buildTagGrid(listTag
              .where((tag) => [1, 2, 3, 4, 5, 6].contains(tag.tagId))
              .toList()),
          const SizedBox(height: 40),

          // Tag Scroll section for tagId 7 to 12 (displayed in a grid of 3x2)
          _buildTagScrollGrid(listTag
              .where((tag) => [7, 8, 9, 10, 11, 12].contains(tag.tagId))
              .toList()),
          const SizedBox(height: 20),

          // 4. Nearest Location section
          _buildNearFeaturedSection('assets/icons/Nearest Places.png',
              'Nearest Location', nearestLocation),
          const SizedBox(height: 20),

          // 5. Featured Places section
          _buildNearFeaturedSection('assets/icons/Featured Places.png',
              'Featured Places', featuredPlaces),
          const SizedBox(height: 20),

          // 6. Other 6 tag sections with Nearest and Featured toggle (for tag 7 to 12)
          ...listTag
              .where((tag) => [7, 8, 9, 10, 11, 12].contains(tag.tagId))
              .map((tag) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 30.0),
              child: _buildTagSection(tag),
            );
          }).toList(),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  // 3. Build Grid for first 6 tags (listTag from 1 to 6)
  Widget _buildTagGrid(List<Tag> tags) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = (constraints.maxWidth / 120).floor();

        return Center(
          child: Container(
            width: constraints.maxWidth,
            margin: const EdgeInsets.symmetric(horizontal: 30),
            decoration: BoxDecoration(
              color: const Color(0xFFDCA1A1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.black, width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5,
                  offset: Offset(15, 20),
                ),
              ],
            ),
            child: GridView.count(
              crossAxisCount: crossAxisCount, // Dynamic number of columns
              shrinkWrap: true,
              childAspectRatio: 0.913,
              physics: const NeverScrollableScrollPhysics(),
              children: tags.map((tag) {
                return _buildTagItem(tag.tagPhotoUrl, tag.tagName);
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  // Build Grid for last 6 tags scroll (listTag from 7 to 12)
  Widget _buildTagScrollGrid(List<Tag> tags) {
    return Center(
      child: Container(
        width: 220,
        height: 130,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDD0),
          borderRadius: BorderRadius.circular(58),
          border: Border.all(color: Colors.black, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(-15, 20),
            ),
          ],
        ),
        child: GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          childAspectRatio: 1.9,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 0,
          mainAxisSpacing: 0,
          children: tags.map((tag) {
            return GestureDetector(
              onTap: () {
                _scrollToTagSection(tag.tagId);
              },
              child: _buildTagScrollItem(tag.tagPhotoUrl),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Scroll to the corresponding tag section when the tag icon is tapped
  void _scrollToTagSection(int tagId) {
    final keyContext = tagSectionKeys[tagId]?.currentContext;
    if (keyContext != null) {
      Scrollable.ensureVisible(
        keyContext,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.8,
      );
    } else {
      print('No context found for tagId: $tagId');
    }
  }

  // 4 and 5. Build Nearest Places and Featured Places section
  Widget _buildNearFeaturedSection(
      String iconPath, String title, List<CardInfo> places) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, left: 16),
          child: Row(
            children: [
              Image.asset(iconPath, width: 24, height: 24),
              const SizedBox(width: 16),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: places.length,
            itemBuilder: (context, index) {
              CardInfo place = places[index];
              return Row(
                children: [
                  if (index == 0) const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      // Navigate to DetailPage and pass the filtered data
                      Place selectedPlace = placeList.firstWhere((placeItem) =>
                          placeItem.placeId == place.placeCardInfoId);
                      PlaceTranslation? selectedTranslation =
                          translations.firstWhere((trans) =>
                              trans.placeId == selectedPlace.placeId);
                      List<PlaceMedia> filteredMediaList = mediaList
                          .where(
                              (media) => media.placeId == selectedPlace.placeId)
                          .toList();

                      Navigator.pushNamed(
                        context,
                        '/detail',
                        arguments: {
                          'place': selectedPlace,
                          'placeName': selectedTranslation.placeName,
                          'mediaList': filteredMediaList,
                          'placeId': selectedPlace.placeId,
                        },
                      );
                    },
                    child: PlaceCard(
                      placeCardId: place.placeCardInfoId,
                      placeName: place.placeName,
                      ward: 'Ward ${place.wardId}',
                      photoDisplay: place.photoDisplay,
                      iconUrl: place.iconUrl,
                      rating: place.rating,
                      reviews: place.reviews,
                      distance: place.distance,
                    ),
                  ),
                  if (index == places.length - 1) const SizedBox(width: 20),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        CustomButton(text: "SEE ALL",
            onPressed: (){

            })
      ],
    );
  }

  // Build Tag Sections with Nearest and Featured toggle (tags 7 to 12)
  Widget _buildTagSection(Tag tag) {
    bool isFeatured = tagToggleStates[tag.tagId] ?? false;
    final GlobalKey sectionKey = tagSectionKeys[tag.tagId]!;

    List<CardInfo> nearestPlacesForTag =
        getNearestPlacesForTag(tag.tagId, dummyPlaces);
    List<CardInfo> featuredPlacesForTag =
        getFeaturedPlacesForTag(tag.tagId, dummyPlaces);

    List<CardInfo> placesToDisplay =
        isFeatured ? featuredPlacesForTag : nearestPlacesForTag;

    return Container(
      key: sectionKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Image.asset(tag.tagPhotoUrl, width: 30, height: 30),
                const SizedBox(width: 16),
                Text(
                  tag.tagName.toUpperCase(),
                  style:
                      const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Toggle buttons for Nearest and Featured
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      tagToggleStates[tag.tagId] = false; // Nearest selected
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !isFeatured
                        ? const Color(0xFF98FB98) // Nearest button active color
                        : const Color(
                            0xFF9DC183), // Nearest button inactive color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Rounded corners
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 49), // Increase padding for larger buttons
                  ),
                  child: const Text(
                    'Nearest',
                    style: TextStyle(
                        fontSize: 15, color: Colors.white), // Increase text size
                  ),
                ),
                const SizedBox(width: 16), // Add space between the buttons
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      tagToggleStates[tag.tagId] = true; // Featured selected
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFeatured
                        ? const Color(0xFF98FB98) // Featured button active color
                        : const Color(
                            0xFF9DC183), // Featured button inactive color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Rounded corners
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 49), // Increase padding for larger buttons
                  ),
                  child: const Text(
                    'Featured',
                    style: TextStyle(
                        fontSize: 15, color: Colors.white), // Increase text size
                  ),
                ),
              ],
            ),
          ),

          // Show Nearest or Featured cards based on the toggle state
          SizedBox(
            height: 300,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: placesToDisplay.length,
              itemBuilder: (context, index) {
                CardInfo place = placesToDisplay[index];
                return Row(
                  children: [
                    if (index == 0) const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        Place selectedPlace = placeList.firstWhere((placeItem) =>
                            placeItem.placeId == place.placeCardInfoId);
                        PlaceTranslation? selectedTranslation =
                            translations.firstWhere((trans) =>
                                trans.placeId == selectedPlace.placeId);
                        List<PlaceMedia> filteredMediaList = mediaList
                            .where(
                                (media) => media.placeId == selectedPlace.placeId)
                            .toList();

                        Navigator.pushNamed(
                          context,
                          '/detail',
                          arguments: {
                            'place': selectedPlace,
                            'placeName': selectedTranslation.placeName,
                            'mediaList': filteredMediaList,
                            'placeId': selectedPlace.placeId,
                          },
                        );
                      },
                      child: PlaceCard(
                        placeCardId: place.placeCardInfoId,
                        placeName: place.placeName,
                        ward: 'Ward ${place.wardId}',
                        photoDisplay: place.photoDisplay,
                        iconUrl: place.iconUrl,
                        rating: place.rating,
                        reviews: place.reviews,
                        distance: place.distance,
                      ),
                    ),
                    if (index == placesToDisplay.length - 1)
                      const SizedBox(width: 20),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: 'SEE ALL',
            onPressed: () {
              // Your logic here
            },
          ),
        ],
      ),
    );
  }

  // Build a single tag item in the grid
  Widget _buildTagItem(String imagePath, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: Colors.black, width: 1), // Border for CircleAvatar
          ),
          child: Image.asset(
            imagePath,
            width: 60,
            height: 60,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // Build a single tag scroll item
  Widget _buildTagScrollItem(String imagePath) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Image.asset(
            imagePath,
            width: 30,
            height: 30,
          ),
        ),
      ],
    );
  }
}
