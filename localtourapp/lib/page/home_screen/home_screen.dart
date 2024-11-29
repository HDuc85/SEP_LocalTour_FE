
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:localtourapp/constants/getListApi.dart';
import 'package:localtourapp/models/HomePage/placeCard.dart';
import 'package:localtourapp/models/Tag/tag_model.dart';
import 'package:localtourapp/models/event/event_model.dart';
import 'package:localtourapp/page/detail_page/event_detail_page.dart';
import 'package:localtourapp/page/home_screen/place_card.dart';
import 'package:localtourapp/page/planned_page/planned_page_tab_bars/fearuted_schedule_page.dart';
import 'package:localtourapp/page/wheel/wheel_page.dart';
import 'package:localtourapp/services/event_service.dart';
import 'package:localtourapp/services/location_Service.dart';
import 'package:localtourapp/services/place_service.dart';
import 'package:localtourapp/services/tag_service.dart';
import '../../base/back_to_top_button.dart';
import '../../base/const.dart';
import '../../base/custom_button.dart';
import '../../base/weather_icon_button.dart';
import '../detail_page/detail_page.dart';
import '../search_page/search_page.dart';
import '../../base/place_card_info.dart';
import '../../base/now_location.dart';
import '../../base/search_bar_icon.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationService _locationService = LocationService();
  final EventService _eventService = EventService();
  late String userId = '';
  late PlaceService _placeService = PlaceService();
  late TagService _tagService = TagService();
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;
  final Map<int, GlobalKey> tagSectionKeys = {};
  List<TagModel> listTagTop = [];
  bool isLoading = true;
  List<PlaceCardModel> listPlaceNearest = [];
  List<EventModel> listEvent = [];

  List<CardInfo> nearestLocation = [];
  List<CardInfo> featuredPlaces = [];
  Map<int, bool> tagToggleStates = {};
  Map<int, List<CardInfo>> nearestPlacesByTag = {};
  Map<int, List<CardInfo>> featuredPlacesByTag = {};

  Map<int, List<PlaceCardModel>> listPlaceTags = {};
  Position? _currentPosition;
  List<int> selectedTags = [];

  @override
  void initState() {
    _scrollController.addListener(_scrollListener);
    super.initState();
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

  void _navigateToWheelPage() {
    Navigator.pushNamed(context, '/wheel');
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
      Position? position = await _locationService.getCurrentPosition();
      double long = position != null ? position.longitude : 106.8096761;
      double lat =  position != null ? position.latitude : 10.8411123;
      if(position != null){
        _currentPosition = position;
      }else{
        _currentPosition = new Position(longitude: long, latitude: lat, timestamp: DateTime.timestamp(), accuracy: 1, altitude: 1, altitudeAccuracy: 1, heading: 1, headingAccuracy: 1, speed: 1, speedAccuracy: 1);
      }

      final fetchedListPlaceNearest = await _placeService.getListPlace(lat, long, SortBy.distance,SortOrder.asc);
      var fetchedListEvent = await _eventService.GetEventInPlace(null, lat, long,SortOrder.asc, SortBy.distance);
      final topTags = await _tagService.getTopTagPlace();

      for(var tag in topTags){
        listPlaceTags[tag.id] = await _placeService.getListPlace(lat, long, SortBy.distance,SortOrder.asc,[tag.id]);
      }

      for (var tag in topTags) {
        tagSectionKeys[tag.id] = GlobalKey();
      }
      DateTime now = DateTime.now();
      fetchedListEvent = fetchedListEvent.where((element) {
        Duration difference = now.difference(element.startDate);
        Duration differenceEnd = now.difference(element.endDate);
        if(difference.inHours > 0 && differenceEnd.inHours < 0 ){
          return true;
        }
        if(difference.inHours < 0){
          return true;
        }

        return false;
      },).toList();


      listTagTop = topTags;
      listPlaceNearest = fetchedListPlaceNearest;
      listEvent = fetchedListEvent;
      setState(() {
        isLoading = false;
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return
      isLoading?
      const Center(child: CircularProgressIndicator()):
      Stack(
      children: [
        // Main Scrollable Content
        SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              const NowLocation(),
              const SizedBox(height: 10),
              SearchBarIcon(position: _currentPosition,),
              const SizedBox(height: 10),
              _buildTagGrid(listTagTop),
              const SizedBox(height: 40),
              _buildNearFeaturedSection('assets/icons/Nearest Places.png',
                  'Nearest Location', listPlaceNearest, SortBy.distance),
              const SizedBox(height: 40),
              _buildNearEventNearest('assets/icons/event.png',
                  'Nearest Events', listEvent, SortBy.distance),
              const SizedBox(height: 40),
              ...listTagTop.map((tag) {
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
          bottom: 10,
          left: 10,
          child:
          PopupMenuButton<int>(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            offset: Offset(0, -100),
            itemBuilder:
                (context) => [
              PopupMenuItem(
                value: 1,
                child: Row(
                  children: [WeatherIconButton(
                    onPressed: _navigateToWeatherPage,
                    assetPath: 'assets/icons/weather.png',
                  ),
                  Text('Thời tiết')
                  ]
                ),
              ),
              PopupMenuItem(
                value: 2,
                child: Row(
                    children: [WeatherIconButton(
                      onPressed: _navigateToWeatherPage,
                      assetPath: 'assets/icons/wheel.png',
                    ),
                      Text('Hôm nay ăn gì')
                    ]
                )),
            ],
            onSelected: (value) {
              if (value == 1) {
                _navigateToWeatherPage();
              } else if (value == 2) {
                _navigateToWheelPage();
              }
            },
            child: Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.green[300], // Màu nền khi chưa click
                shape: BoxShape.circle, // Hình dạng tròn
              ),
              child: Icon(
                Icons.more_vert,
                color: Colors.black,
              ),
            ), // Icon hiển thị trên nút
          )
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
  Widget _buildTagGrid(List<TagModel> tags) {
    double screenWidth = MediaQuery.of(context).size.width;
    double containerHorizontalMargin = 40 * 2;
    double itemHorizontalMargin = 5 * 2;
    double availableWidth =
        screenWidth - containerHorizontalMargin - (itemHorizontalMargin * 1);
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
              ),
            ),
          );
        },
        child: _buildTagItem('https://api.localtour.space/Media/image_4fc69903-324c-4765-96f4-f338815e4aad.png',
            'Schedule Page'), // Example image for "Schedule Page"
      ),GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WheelPage(
              ),
            ),
          );
        },
        child: _buildTagItem('https://api.localtour.space/Media/wheel.png',
            'Today choose'), // Example image for "Schedule Page"
      )
    ];

    // Add the rest of the tags to the list
    gridItems.addAll(tags.map((tag) {
      return GestureDetector(
        onTap: () {
          _scrollToTagSection(tag.id);
        },
        child: _buildTagItem(tag.tagPhotoUrl, tag.tagName),
      );
    }).toList());

    return Center(
      child: Container(
        height: 200, // Adjust the height to fit two tag items vertically
        margin: const EdgeInsets.symmetric(horizontal: 40),
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
            childAspectRatio:
                itemWidth / 85, // Adjust for item height and width
          ),
          itemBuilder: (context, index) {
            return Container(
              width: itemWidth,
              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: gridItems[index],
            );
          },
        ),
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
            child: Image.network(
              imagePath,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          height: 24, // Set a fixed height for the text container
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              height: 1, // Adjust line height if needed
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
          ),
        ),
      ],
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
  Widget _buildNearFeaturedSection(String iconPath, String title,
      List<PlaceCardModel> places, SortBy sortBy) {
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
              PlaceCardModel place = places[index];
              return Row(
                children: [
                  if (index == 0) const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      // Navigate to DetailPage and pass the filtered data


                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailPage(
                            placeId: place.placeId,
                          ),
                        ),
                      );
                    },
                    child: PlaceCard(
                      placeCardId: place.placeId,
                      placeName: place.placeName,
                      ward: place.wardName,
                      photoDisplay: place.photoDisplayUrl,
                      score: place.rateStar,
                      distance: place.distance,
                      countFeedback: place.countFeedback,
                      timeClose: place.timeClose,
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
                  sortBy: sortBy,
                  initialTags: [],
                ),
              ),
            );
          },
        )
      ],
    );
  }

  Widget _buildNearEventNearest(String iconPath, String title,
      List<EventModel> events, SortBy sortBy) {
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
            itemCount: events.length,
            itemBuilder: (context, index) {
              EventModel event = events[index];
              return Row(
                children: [
                  if (index == 0) const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventDetailPage(
                            eventModel: event,
                          ),
                        ),
                      );
                    },
                    child: PlaceCard(
                      placeCardId: event.placeId,
                      placeName: event.eventName,
                      ward: event.placeName,
                      photoDisplay: event.eventPhoto!,
                      score: 5,
                      distance: event.distance,
                      countFeedback: 5,
                      timeClose: TimeOfDay.fromDateTime(event.endDate),
                      isEvent: true,
                      eventModel: event,
                    ),
                  ),
                  if (index == events.length - 1) const SizedBox(width: 20),
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
                  sortBy: sortBy,
                  initialTags: [],
                  isEvent: true,
                ),
              ),
            );
          },
        )
      ],
    );
  }

  // Build Tag Sections with Nearest and Featured toggle
  Widget _buildTagSection(TagModel tag) {
    bool isFeatured = tagToggleStates[tag.id] ?? false;
    final GlobalKey? sectionKey = tagSectionKeys[tag.id];

    if (sectionKey == null) {
      return Container();
    }
    List<PlaceCardModel> listPlaceCards = listPlaceTags[tag.id]??[];

    if(isFeatured){
      listPlaceCards.sort((a, b) => a.distance.compareTo(b.distance));
    }else{
      listPlaceCards.sort((a, b) => b.rateStar.compareTo(a.rateStar));
    }

    return Container(
      key: sectionKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Image.network(tag.tagPhotoUrl, width: 30, height: 30),
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
                      tagToggleStates[tag.id] = false;
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
                      tagToggleStates[tag.id] = true;
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
              itemCount: listPlaceCards.length,
              itemBuilder: (context, index) {
                PlaceCardModel place = listPlaceCards[index];
                return Row(
                  children: [
                    if (index == 0) const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {

                        Navigator.pushNamed(
                          context,
                          '/detail'
                        );
                      },
                      child: PlaceCard(
                        placeCardId: place.placeId,
                        placeName: place.placeName,
                        ward: place.wardName,
                        photoDisplay: place.photoDisplayUrl,
                        score: place.rateStar,
                        distance: place.distance,
                        countFeedback: place.countFeedback,
                        timeClose: place.timeClose,
                      ),
                    ),
                    if (index == listPlaceCards.length - 1)
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
              SortBy sortBy =
                  isFeatured ? SortBy.distance : SortBy.rating;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SearchPage(
                    sortBy: sortBy,
                    initialTags: [tag.id], // Pass all selected tags
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
