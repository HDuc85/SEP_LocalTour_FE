import 'package:flutter/material.dart';
import 'package:localtourapp/config/appConfig.dart';
import 'package:localtourapp/config/secure_storage_helper.dart';
import 'package:localtourapp/models/Tag/tag_model.dart';
import 'package:localtourapp/models/event/event_model.dart';
import 'package:localtourapp/models/media_model.dart';
import 'package:localtourapp/models/places/place_detail_model.dart';
import 'package:localtourapp/services/place_service.dart';
import 'package:localtourapp/services/tag_service.dart';
import 'package:provider/provider.dart';

import '../../base/back_to_top_button.dart';
import '../../full_media/full_place_media_viewer.dart';
import '../../models/places/markplace.dart';
import '../../provider/place_provider.dart';
import '../../services/event_service.dart';
import 'detail_page_tab_bars/detail_tabbar.dart';
import 'detail_page_tab_bars/review_tabbar.dart';

class DetailPage extends StatefulWidget {
  final int placeId;
  const DetailPage({
    Key? key,
    required this.placeId,
  }) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> with SingleTickerProviderStateMixin {
  final GlobalKey<NestedScrollViewState> _nestedScrollViewKey = GlobalKey<NestedScrollViewState>();

  final PlaceService _placeService = PlaceService();
  final TagService _tagService = TagService();
  final EventService _eventService = EventService();

  String _userId = '';
  String _languageCode = '';

  late PlaceDetailModel _placeDetailModel =
  PlaceDetailModel
    (id: 1, photoDisplay: '', timeOpen: TimeOfDay(hour: 1,minute: 1), timeClose: TimeOfDay(hour: 1, minute: 1), longitude: 1, latitude: 1, contactLink: '', placeActivities: [], placeMedias: [], name: '', description: '', address: '', contact: '');
  late TabController _tabController;
  List<TagModel> _listTagInPlace = [];
  List<EventModel> _listEvents =[];
  bool _showBackToTopButton = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _getPlaceDetail();

    // Add a post frame callback to ensure the NestedScrollView is built before accessing its controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nestedScrollViewKey.currentState?.innerController.addListener(_nestedScrollListener);
    });
  }

  @override
  void dispose() {
    // Remove the listener to prevent memory leaks
    _nestedScrollViewKey.currentState?.innerController.removeListener(_nestedScrollListener);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _getPlaceDetail() async{
    var fetchPlaceDetail = await _placeService.GetPlaceDetail(widget.placeId);
    var fetchTagInPlace = await _tagService.getTagInPlace(widget.placeId);
    var userId = await SecureStorageHelper().readValue(AppConfig.userId);
    var fetchedListEvents = await _eventService.GetEventInPlace(widget.placeId);
    var languageCode = await SecureStorageHelper().readValue(AppConfig.language);

    setState(() {
      _placeDetailModel = fetchPlaceDetail;
      _listTagInPlace = fetchTagInPlace;
      _userId = userId!;
      _listEvents = fetchedListEvents;
      _languageCode = _languageCode;
    });

  }



  void _nestedScrollListener() {
    // Get the current scroll offset
    double offset = _nestedScrollViewKey.currentState?.innerController.offset ?? 0;

    if (offset >= 200 && !_showBackToTopButton) {
      setState(() {
        _showBackToTopButton = true;
      });
    } else if (offset < 200 && _showBackToTopButton) {
      setState(() {
        _showBackToTopButton = false;
      });
    }
  }

  void _scrollToTop() {
    _nestedScrollViewKey.currentState?.innerController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _toggleBookmark(PlaceProvider bookmarkManager) async {
    if (bookmarkManager.isBookmarked(widget.placeId)) {
      await bookmarkManager.removeBookmark(widget.placeId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bookmark removed')),
      );
    } else {
      await bookmarkManager.addBookmark(
        MarkPlace(
          markPlaceId: widget.placeId,
          userId: _userId, // Use widget.userId instead of hardcoded ID
          placeId: widget.placeId,
          createdDate: DateTime.now(),
          isVisited: false,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bookmark added')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookmarkManager = Provider.of<PlaceProvider>(context);
    bool isBookmarked = bookmarkManager.isBookmarked(widget.placeId);

    // Access widget properties directly
    final int placeId = widget.placeId;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          _placeDetailModel.name, maxLines: 2,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.red,
            ),
            onPressed: () {
              _toggleBookmark(bookmarkManager);
            },
          ),
        ],
      ),
      body: FutureBuilder(future: _getPlaceDetail(), builder: (context, snapshot) =>

          Stack(
            children: [
              NestedScrollView(
                key: _nestedScrollViewKey, // Assign the GlobalKey here
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          // Media List Section
                          Stack(
                            children: [
                              _placeDetailModel.placeMedias.isNotEmpty
                                  ? GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => FullScreenPlaceMediaViewer(
                                        mediaList: _placeDetailModel.placeMedias,
                                        initialIndex: 0,
                                      ),
                                    ),
                                  );
                                },
                                child: Image.network(
                                  _placeDetailModel.placeMedias[0].url,
                                  width: double.infinity,
                                  height: 250, // Adjust height as needed
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                  const Center(child: Text('No media available')),
                                ),
                              )
                                  : const Center(child: Text('No media available')),
                              // Positioned WeatherIconButton
                            ],
                          ),
                          const SizedBox(height: 1),
                          // Thumbnails Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: _placeDetailModel.placeMedias.length > 1
                                ? _placeDetailModel.placeMedias.skip(1).take(4).toList().asMap().entries.map((entry) {
                              int index = entry.key;
                              MediaModel media = entry.value;

                              return Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FullScreenPlaceMediaViewer(
                                          mediaList: _placeDetailModel.placeMedias,
                                          initialIndex: index + 1,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Stack(
                                    children: [
                                      Image.network(
                                        media.url,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: 77.5,
                                        errorBuilder: (context, error, stackTrace) =>
                                            Container(
                                              width: double.infinity,
                                              height: 77.5,
                                              color: Colors.grey,
                                              child: const Icon(Icons.image, color: Colors.white),
                                            ),
                                      ),
                                      if (index == 3 && _placeDetailModel.placeMedias.length > 5)
                                        Container(
                                          color: Colors.black.withOpacity(0.5),
                                          height: 77.5,
                                          child: const Center(
                                            child: Text(
                                              'See more',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList()
                                : [],
                          ),
                          Container(
                            width: double.infinity,
                            height: 3,
                            color: const Color(0xFFDCA1A1),
                          ),
                        ],
                      ),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverAppBarDelegate(
                        TabBar(
                          controller: _tabController,
                          labelColor: Colors.black,
                          indicatorColor: const Color(0xFF008080),
                          labelStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          tabs: [
                            Container(
                              color: Colors.blue[100], // Background color for 'Detail' tab
                              child: const Tab(
                                icon: Icon(Icons.details),
                                text: '          Detail          ',
                              ),
                            ),
                            Container(
                              color: Colors.green[100], // Background color for 'Review' tab
                              child: const Tab(
                                icon: Icon(Icons.reviews),
                                text: '          Review          ',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    DetailTabbar(
                      userId: _userId, // Pass the userId here
                      tags: _listTagInPlace,
                      onAddPressed: () {},
                      onReportPressed: () {},
                      placeDetail: _placeDetailModel,
                      languageCode: _languageCode,
                      listEvents: _listEvents,
                    ),
                    ReviewTabbar(
                      userId: _userId, // Use widget.userId
                      placeId: placeId,
                    ),
                  ],
                ),
              ),
              // Positioned BackToTopButton
              Positioned(
                bottom: 30,
                left: 110,
                child: AnimatedOpacity(
                  opacity: _showBackToTopButton ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: _showBackToTopButton
                      ? BackToTopButton(
                    onPressed: _scrollToTop, // Link to the scrollToTop method
                  )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
      )
    );
  }

// ... (rest of your methods like _buildTimeStatus, _buildAddressRow, etc.)
}

// _SliverAppBarDelegate remains the same
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}