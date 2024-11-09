// lib/page/detailpage.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../fullmedia/fullplacemediaviewer.dart';
import '../../models/places/markplace.dart';
import '../../models/places/placefeedback.dart';
import '../../models/places/placefeeedbackmedia.dart';
import '../../models/places/placemedia.dart';
import '../../models/places/placetag.dart';
import '../../models/places/tag.dart';
import '../../models/users/users.dart';
import '../bookmark/bookmarkmanager.dart';
import 'detailpagetabbars/detail_tabbar.dart';
import 'detailpagetabbars/review_tabbar.dart';

class DetailPage extends StatefulWidget {
  final String placeName;
  final int placeId;
  final List<PlaceMedia> mediaList;

  const DetailPage({
    Key? key,
    required this.placeName,
    required this.placeId,
    required this.mediaList,
  }) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
          userId: 'anh-tuan-unique-id-1234',
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    // Ensure placeTags and listTag are accessible
    List<Tag> placeTagsForPlace = placeTags
        .where((placeTag) => placeTag.placeId == placeId)
        .map((placeTag) => listTag.firstWhere((tag) => tag.tagId == placeTag.tagId))
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          placeName,
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
      body: NestedScrollView(
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
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                          const Text('No media available'),
                        ),
                      )
                          : const Text('No media available'),
                    ],
                  ),
                  const SizedBox(height: 1),
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
              tags: placeTagsForPlace,
              onAddPressed: () {},
              onReportPressed: () {},
              placeId: widget.placeId,
            ),
            ReviewTabbar(
              feedbacks: feedbacks,
              users: fakeUsers,
              userId: 'anh-tuan-unique-id-1234',
              placeId: placeId,
              feedbackMediaList: feedbackMediaList,
            ),
          ],
        ),
      ),
    );
  }
}

// Custom SliverPersistentHeaderDelegate to make the TabBar pinned
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

// Extension to format DateTime
extension DateHelpers on DateTime {
  String toShortDateString() {
    return "${this.day}/${this.month}/${this.year}";
  }
}
