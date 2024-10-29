import 'package:flutter/material.dart';

import '../models/places/placemedia.dart';
import '../models/places/placetag.dart';
import '../models/tag.dart';
import 'detailpagetabbars/detail_tab.dart';
import 'detailpagetabbars/review_tab.dart';
import 'fullscreenplacemediaviewer.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String placeName = arguments['placeName'];
    final int placeId = arguments['placeId'];
    final List<PlaceMedia> mediaList = arguments['mediaList'];

    // Get the corresponding tags for the placeId
    List<Tag> placeTagsForPlace = placeTags
        .where((placeTag) => placeTag.placeId == placeId)
        .map((placeTag) => listTag.firstWhere((tag) => tag.tagId == placeTag.tagId))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(placeName),
      ),
      body: SingleChildScrollView(
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
            // Tab Section
            DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    labelColor: Colors.black,
                    indicatorColor: Color(0xFF54463A),
                    labelStyle: TextStyle(
                      fontSize: 18, // Increase font size here
                      fontWeight: FontWeight.bold, // Make the text bold if you want
                    ),
                    tabs: [
                      Tab(icon: Icon(Icons.details) ,text: '          Detail          '),
                      Tab(icon: Icon(Icons.reviews) ,text: '          Review          '),
                    ],
                  ),
                  SizedBox(
                    height: 589, // Adjust this height as needed for the content
                    child: TabBarView(
                      children: [
                        DetailTab(
                          placeId: placeId,
                          tags: placeTagsForPlace,
                          onAddPressed: () {},
                          onBookmarkPressed: () {},
                          onReportPressed: () {},
                        ),
                        ReviewTab(),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
