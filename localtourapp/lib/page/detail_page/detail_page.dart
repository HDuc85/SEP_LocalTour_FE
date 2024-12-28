import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:geolocator/geolocator.dart';
import '../../config/appConfig.dart';
import '../../config/secure_storage_helper.dart';
import 'package:localtourapp/models/Tag/tag_model.dart';
import 'package:localtourapp/models/event/event_model.dart';
import 'package:localtourapp/models/media_model.dart';
import 'package:localtourapp/models/places/place_detail_model.dart';
import 'package:localtourapp/services/mark_place_service.dart';
import 'package:localtourapp/services/place_service.dart';
import 'package:localtourapp/services/tag_service.dart';
import 'package:localtourapp/services/event_service.dart';
import '../../base/back_to_top_button.dart';
import '../../full_media/full_place_media_viewer.dart';
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
  final MarkplaceService _markplaceService = MarkplaceService();
  String _userId = '';
  String _languageCode = '';

  late PlaceDetailModel _placeDetailModel ;
  late TabController _tabController;
  List<TagModel> _listTagInPlace = [];
  List<EventModel> _listEvents =[];
  bool isMarked = false;
  bool _showBackToTopButton = false;
  bool isLoading = true;

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

  Future<void> _getPlaceDetail() async {
    try {
      var fetchPlaceDetail = await _placeService.GetPlaceDetail(widget.placeId);
      var fetchTagInPlace = await _tagService.getTagInPlace(widget.placeId);
      var userId = await SecureStorageHelper().readValue(AppConfig.userId);
      var fetchedListEvents = await _eventService.getEventInPlace(widget.placeId, 1, 1);
      var languageCode = await SecureStorageHelper().readValue(AppConfig.language);
      bool isMark = false;
      if (userId == null) {
        _userId = '';
      }
      if (userId != null && userId.isNotEmpty) {
        var listMark = await _markplaceService.getAllMarkPlace();
        isMark = listMark.any((element) => element.placeId == widget.placeId);
        _userId = userId;
      }
      if (!mounted) return;
      setState(() {
        _placeDetailModel = fetchPlaceDetail;
        _listTagInPlace = fetchTagInPlace;
        _listEvents = fetchedListEvents;
        _languageCode = languageCode ?? 'vi';
        isMarked = isMark;
        isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching place details: $e');
      }
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _languageCode == 'vi' ? "Lỗi khi tải dữ liệu chi tiết địa điểm." : 'Error loading place details.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
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

  Future<void> _toggleBookmark(int placeId) async {
    if (_userId.isNotEmpty) {
      if (isMarked) {
        // Delete Bookmark
        bool success = await _markplaceService.deleteMarkPlace(placeId);
        if (success) {
          setState(() {
            isMarked = false;
          });
          // Show Snackbar for Deletion
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _languageCode != 'vi' ? 'Bookmark removed' : 'Đã xóa dấu trang',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          _showErrorSnackbar();
        }
      } else {
        // Add Bookmark
        bool success = await _markplaceService.markPlace(placeId);
        if (success) {
          setState(() {
            isMarked = true;
          });
          // Show Snackbar for Addition
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _languageCode != 'vi' ? 'Bookmark added' : 'Đã thêm dấu trang',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          _showErrorSnackbar();
        }
      }
    } else {
      // Prompt user to log in or handle unauthenticated state
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _languageCode == 'vi' ? "Vui lòng đăng nhập để đánh dấu địa điểm." : 'Please log in to bookmark places.',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showErrorSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _languageCode != 'vi' ? 'Failed to update bookmark.' : 'Cập nhật dấu trang thất bại.',
        ),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Access widget properties directly
    final int placeId = widget.placeId;

    return isLoading
        ? const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    )
        : Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _placeDetailModel.name,
          maxLines: 2,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isMarked ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.red,
            ),
            onPressed: () {
              _toggleBookmark(widget.placeId);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          NestedScrollView(
            key: _nestedScrollViewKey, // Assign the GlobalKey here
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Media List Section with Carousel
                      _buildMediaSection(),
                      const SizedBox(height: 5),
                      // Thumbnails Section
                      _buildThumbnailsSection(),
                      const SizedBox(height: 5),
                      // Divider
                      const Divider(thickness: 1, height: 1),
                    ],
                  ),
                ),
                // SliverPersistentHeader for Tabs
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: Colors.black,
                      indicatorColor: const Color(0xFF008080),
                      labelStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      unselectedLabelColor: Colors.grey,
                      tabs: [
                        Tab(
                          icon: const Icon(Icons.details),
                          text: _languageCode == 'vi' ? 'Chi tiết' : 'Detail',
                        ),
                        Tab(
                          icon: const Icon(Icons.reviews),
                          text: _languageCode == 'vi' ? 'Đánh giá' : 'Review',
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
                  userId: _userId,
                  placeId: placeId,
                ),
              ],
            ),
          ),
          // Positioned BackToTopButton
          Positioned(
            bottom: 30,
            right: 20,
            child: AnimatedOpacity(
              opacity: _showBackToTopButton ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: _showBackToTopButton
                  ? BackToTopButton(
                onPressed: _scrollToTop,
                languageCode: _languageCode,
              )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaSection() {
    return _placeDetailModel.placeMedias.isNotEmpty
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
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: CachedNetworkImage(
              imageUrl: _placeDetailModel.placeMedias[0].url,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: double.infinity,
                  height: 250,
                  color: Colors.white,
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: double.infinity,
                height: 250,
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.black.withOpacity(0.7),
              onPressed: () {
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
              child: const Icon(Icons.fullscreen, color: Colors.white),
            ),
          ),
        ],
      ),
    )
        : Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Center(
        child: Text(
          'No media available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildThumbnailsSection() {
    final mediaList = _placeDetailModel.placeMedias;
    if (mediaList.length <= 1) {
      return const SizedBox.shrink();
    }

    // Determine how many thumbnails to show (max 4)
    int thumbnailsToShow = mediaList.length > 5 ? 4 : mediaList.length - 1;
    List<MediaModel> thumbnails = mediaList.skip(1).take(thumbnailsToShow).toList();

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: thumbnails.length,
        itemBuilder: (context, index) {
          // Check if it's the last thumbnail and there are more than 5 media items
          bool isLastThumbnail = index == thumbnails.length - 1 && mediaList.length > 5;

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullScreenPlaceMediaViewer(
                    mediaList: _placeDetailModel.placeMedias,
                    initialIndex: index + 1,
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[300],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: thumbnails[index].url,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[400],
                        child: const Icon(Icons.broken_image, color: Colors.white),
                      ),
                    ),
                    if (isLastThumbnail)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '+${mediaList.length - 5}',
                            style: const TextStyle(
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
            ),
          );
        },
      ),
    );
  }
}

// SliverPersistentHeaderDelegate remains the same but improved for better visuals
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => 50; // Set a smaller minimum height
  @override
  double get maxExtent => 50; // Set a smaller maximum height

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
