import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:localtourapp/provider/schedule_provider.dart';
import 'package:localtourapp/models/schedule/destination.dart';
import 'package:localtourapp/models/schedule/schedule.dart';
import 'package:localtourapp/models/schedule/schedulelike.dart';
import 'package:localtourapp/models/users/users.dart';
import 'package:localtourapp/provider/user_provider.dart';
import 'package:localtourapp/provider/count_provider.dart';
import 'package:localtourapp/page/planned_page/planned_page_tab_bars/fearuted_schedule_page.dart';
import 'package:provider/provider.dart';
import '../../base/back_to_top_button.dart';
import '../../base/const.dart';
import '../../base/custom_button.dart';
import '../../base/filter_option.dart';
import '../../base/weather_icon_button.dart';
import '../../models/places/tag.dart';
import '../search_page/search_page.dart';
import 'place_card.dart';
import '../../base/place_card_info.dart';
import '../../models/places/place.dart';
import '../../models/places/placemedia.dart';
import '../../models/places/placetranslation.dart';
import '../../base/now_location.dart';
import '../../base/search_bar_icon.dart';
import '../detail_page/detail_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String userId;
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;
  final Map<int, GlobalKey> tagSectionKeys = {};
  List<Place> placeList = dummyPlaces;
  List<CardInfo> nearestLocation = [];
  List<CardInfo> featuredPlaces = [];
  Map<int, bool> tagToggleStates = {};
  Map<int, List<CardInfo>> nearestPlacesByTag = {};
  Map<int, List<CardInfo>> featuredPlacesByTag = {};

  Position? _currentPosition;
  List<int> selectedTags = [];

  @override
  void initState() {
    _scrollController.addListener(_scrollListener);
    super.initState();

    // Generate mediaList
    mediaList = generatePlaceMediaForAllPlaces(dummyPlaces);

    // Initialize tagSectionKeys for all tags in listTag
    for (var tag in listTag) {
      tagSectionKeys[tag.tagId] = GlobalKey();
    }

    // Get the current position
    _getCurrentPosition();
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

  Future<void> _getCurrentPosition() async {
    try {
      // Check for permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          // Permissions are denied, show a message
          setState(() {
          });
          return;
        }
      }

      // When we reach here, permissions are granted, and we can get the position
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;

        // Update nearestLocation and featuredPlaces
        nearestLocation = getNearestPlaces(dummyPlaces, position.latitude, position.longitude);
        featuredPlaces = getFeaturedPlaces(dummyPlaces, position.latitude, position.longitude);

        // For each tag, calculate nearest and featured places
        for (var tag in listTag) {
          nearestPlacesByTag[tag.tagId] = getNearestPlacesForTag(
              tag.tagId, dummyPlaces, position.latitude, position.longitude);
          featuredPlacesByTag[tag.tagId] = getFeaturedPlacesForTag(
              tag.tagId, dummyPlaces, position.latitude, position.longitude);
        }
      });
    } catch (e) {
      setState(() {
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    userId = Provider.of<UserProvider>(context).userId;

    if (userId.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        // Main Scrollable Content
        SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              const NowLocation(),
              const SizedBox(height: 10),
              SearchBarIcon(placeTranslations: dummyTranslations),
              const SizedBox(height: 10),
              _buildTagGrid(listTag),
              const SizedBox(height: 40),
              _buildNearFeaturedSection('assets/icons/Nearest Places.png',
                  'Nearest Location', nearestLocation, FilterOption.nearest),
              const SizedBox(height: 40),
              _buildNearFeaturedSection('assets/icons/Featured Places.png',
                  'Featured Places', featuredPlaces, FilterOption.featured),
              const SizedBox(height: 40),
              ...listTag.map((tag) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30.0),
                  child: _buildTagSection(tag),
                );
              }).toList(),
              const SizedBox(height: 40),
            ],
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

  // 3/ _buildTagGrid function to list all tags
  Widget _buildTagGrid(List<Tag> tags) {
    double screenWidth = MediaQuery.of(context).size.width;
    double containerHorizontalMargin = 30 * 2; // Left and right margins
    double itemHorizontalMargin = 10 * 2; // Left and right margins for each item
    double availableWidth = screenWidth - containerHorizontalMargin - (itemHorizontalMargin * 3);
    double itemWidth = availableWidth / 3;

    // Prepend the "Schedule Page" item to the list of tags
    List<Widget> gridItems = [
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FeaturedSchedulePage(
                userId: userId, // Pass in the actual userId
                allSchedules: dummySchedules,
                scheduleLikes: dummyScheduleLikes,
                destinations: dummyDestinations,
                users: fakeUsers,
                onClone: (Schedule clonedSchedule, List<Destination> clonedDestinations) {
                  Provider.of<ScheduleProvider>(context, listen: false)
                      .addSchedule(clonedSchedule);
                  Provider.of<ScheduleProvider>(context, listen: false)
                      .destinations
                      .addAll(clonedDestinations);

                  // Increment schedule count in CountProvider if necessary
                  Provider.of<CountProvider>(context, listen: false)
                      .incrementScheduleCount();
                },
              ),
            ),
          );
        },
        child: _buildTagItem('assets/images/Schedule.png', 'Schedule Page'), // Example image for "Schedule Page"
      ),
    ];

    // Add the rest of the tags to the list
    gridItems.addAll(tags.map((tag) {
      return GestureDetector(
        onTap: () {
          _scrollToTagSection(tag.tagId);
        },
        child: _buildTagItem(tag.tagPhotoUrl, tag.tagName),
      );
    }).toList());

    return Center(
      child: Container(
        height: 262, // Adjust the height to fit two tag items vertically
        margin: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          color: Constants.tagGridBackground,
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
        child: GridView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: gridItems.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Display two rows
            childAspectRatio: itemWidth / 60, // Adjust for item height and width
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            return Container(
              width: itemWidth,
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: gridItems[index],
            );
          },
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
      String iconPath, String title, List<CardInfo> places, FilterOption filterOption) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            children: [
              Image.asset(iconPath, width: 30, height: 30),
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
                      Place selectedPlace = placeList.firstWhere(
                              (placeItem) =>
                          placeItem.placeId == place.placeCardInfoId);
                      PlaceTranslation? selectedTranslation = dummyTranslations
                          .firstWhere((trans) =>
                      trans.placeId == selectedPlace.placeId);
                      List<PlaceMedia> filteredMediaList = mediaList
                          .where((media) =>
                      media.placeId == selectedPlace.placeId)
                          .toList();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailPage(
                            languageCode: 'en',
                            userId: userId,
                            placeName: selectedTranslation.placeName,
                            placeId: selectedPlace.placeId,
                            mediaList: filteredMediaList,
                          ),
                        ),
                      );
                    },
                    child: PlaceCard(
                      placeCardId: place.placeCardInfoId,
                      placeName: place.placeName,
                      ward: 'Ward ${place.wardId}',
                      photoDisplay: place.photoDisplay,
                      iconUrl: place.iconUrl,
                      score: place.score,
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
        CustomSeeAllButton(
          text: "SEE ALL",
          onPressed: () {
            // Navigate to SearchPage with the corresponding filter
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SearchPage(
                  initialFilter: filterOption,
                  initialTags: [],
                ),
              ),
            );
          },
        )
      ],
    );
  }

  // Build Tag Sections with Nearest and Featured toggle
  Widget _buildTagSection(Tag tag) {
    bool isFeatured = tagToggleStates[tag.tagId] ?? false;
    final GlobalKey? sectionKey = tagSectionKeys[tag.tagId];

    if (sectionKey == null) {
      return Container();
    }

    List<CardInfo> nearestPlacesForTag =
        nearestPlacesByTag[tag.tagId] ?? [];
    List<CardInfo> featuredPlacesForTag =
        featuredPlacesByTag[tag.tagId] ?? [];

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
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
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
                      tagToggleStates[tag.tagId] = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !isFeatured
                        ? Constants.selectedState
                        : Constants.defaultState,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 49),
                  ),
                  child: const Text(
                    'Nearest',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      tagToggleStates[tag.tagId] = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFeatured
                        ? Constants.selectedState
                        : Constants.defaultState,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 49),
                  ),
                  child: const Text(
                    'Featured',
                    style: TextStyle(fontSize: 15, color: Colors.white),
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
                        Place selectedPlace = placeList.firstWhere(
                                (placeItem) =>
                            placeItem.placeId == place.placeCardInfoId);
                        PlaceTranslation? selectedTranslation = dummyTranslations
                            .firstWhere((trans) =>
                        trans.placeId == selectedPlace.placeId);
                        List<PlaceMedia> filteredMediaList = mediaList
                            .where((media) =>
                        media.placeId == selectedPlace.placeId)
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
                        score: place.score,
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
          CustomSeeAllButton(
            text: 'SEE ALL',
            onPressed: () {
              // Determine the filter based on toggle state
              FilterOption filterOption =
              isFeatured ? FilterOption.featured : FilterOption.nearest;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SearchPage(
                    initialFilter: filterOption,
                    initialTags: [tag.tagId], // Pass all selected tags
                  ),
                ),
              );
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
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: ClipOval(
            child: Image.asset(
              imagePath,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 75,
          height: 35, // Set a fixed height for the text container
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              height: 1.2, // Adjust line height if needed
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
          ),
        ),
      ],
    );
  }

}
