import 'package:flutter/material.dart';
import 'package:localtourapp/base/back_to_top_button.dart';
import 'package:localtourapp/full_media/full_place_media_viewer.dart';
import 'package:localtourapp/models/places/markplace.dart';
import 'package:localtourapp/models/places/placefeedback.dart';
import 'package:localtourapp/models/places/placefeedbackmedia.dart';
import 'package:localtourapp/models/places/placemedia.dart';
import 'package:localtourapp/models/places/placetag.dart';
import 'package:localtourapp/models/places/tag.dart';
import 'package:localtourapp/models/users/users.dart';
import 'package:localtourapp/page/bookmark/bookmark_manager.dart';
import 'package:localtourapp/page/detail_page/detail_page_tab_bars/detail_tabbar.dart';
import 'package:localtourapp/page/detail_page/detail_page_tab_bars/review_tabbar.dart';
import 'package:provider/provider.dart';

class DetailPage extends StatefulWidget {
  final String placeName;
  final int placeId;
  final List<PlaceMedia> mediaList;
  final String userId; // Add userId as a required parameter

  const DetailPage({
    Key? key,
    required this.placeName,
    required this.placeId,
    required this.mediaList,
    required this.userId, // Initialize userId
  }) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> with SingleTickerProviderStateMixin {
  final GlobalKey<NestedScrollViewState> _nestedScrollViewKey = GlobalKey<NestedScrollViewState>();
  late TabController _tabController;
  bool _showBackToTopButton = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Add a post frame callback to ensure the NestedScrollView is built before accessing its controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Access the innerController and add a listener
      _nestedScrollViewKey.currentState?.innerController?.addListener(_nestedScrollListener);
    });
  }

  @override
  void dispose() {
    // Remove the listener to prevent memory leaks
    _nestedScrollViewKey.currentState?.innerController?.removeListener(_nestedScrollListener);
    _tabController.dispose();
    super.dispose();
  }

  void _nestedScrollListener() {
    // Get the current scroll offset
    double offset = _nestedScrollViewKey.currentState?.innerController?.offset ?? 0;

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
    _nestedScrollViewKey.currentState?.innerController?.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _toggleBookmark(BookmarkManager bookmarkManager) async {
    if (bookmarkManager.isBookmarked(widget.placeId)) {
      await bookmarkManager.removeBookmark(widget.placeId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bookmark removed')),
      );
    } else {
      await bookmarkManager.addBookmark(
        MarkPlace(
          markPlaceId: widget.placeId,
          userId: widget.userId, // Use widget.userId instead of hardcoded ID
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
    final bookmarkManager = Provider.of<BookmarkManager>(context);
    bool isBookmarked = bookmarkManager.isBookmarked(widget.placeId);

    // Access widget properties directly
    final String placeName = widget.placeName;
    final int placeId = widget.placeId;
    final List<PlaceMedia> mediaList = widget.mediaList;

    // Get the corresponding tags for the placeId
    // Ensure you have access to translations and listTag
    List<Tag> placeTagsForPlace = placeTags
        .where((placeTag) => placeTag.placeId == placeId)
        .map((placeTag) => listTag.firstWhere(
          (tag) => tag.tagId == placeTag.tagId,
      orElse: () => Tag(tagId: 0, tagPhotoUrl: '', tagName: 'Unknown'),
    ))
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          placeName, maxLines: 2,
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
      body: Stack(
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
                          mediaList.isNotEmpty
                              ? GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FullScreenPlaceMediaViewer(
                                    mediaList: mediaList,
                                    initialIndex: 0,
                                  ),
                                ),
                              );
                            },
                            child: Image.network(
                              mediaList[0].placeMediaUrl,
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
                        children: mediaList.length > 1
                            ? mediaList.skip(1).take(4).toList().asMap().entries.map((entry) {
                          int index = entry.key;
                          PlaceMedia media = entry.value;

                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FullScreenPlaceMediaViewer(
                                      mediaList: mediaList,
                                      initialIndex: index + 1,
                                    ),
                                  ),
                                );
                              },
                              child: Stack(
                                children: [
                                  Image.network(
                                    media.placeMediaUrl,
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
                                  if (index == 3 && mediaList.length > 5)
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
                  userId: widget.userId, // Pass the userId here
                  tags: placeTagsForPlace,
                  onAddPressed: () {},
                  onReportPressed: () {},
                  placeId: widget.placeId,
                ),
                ReviewTabbar(
                  feedbacks: feedbacks,
                  users: fakeUsers,
                  userId: widget.userId, // Use widget.userId
                  placeId: placeId,
                  feedbackMediaList: feedbackMediaList,
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