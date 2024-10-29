import 'package:flutter/material.dart';
import 'package:localtourvn/models/places/placeactivitymedia.dart';

class FullScreenActivityMediaViewer extends StatelessWidget {
  final List<PlaceActivityMedia> mediaActivityList;
  final int initialIndex;

  const FullScreenActivityMediaViewer({super.key, required this.mediaActivityList, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Ensures a clean, non-distracting background
      body: Stack(
        children: [
          // PageView for swiping through all media
          PageView.builder(
            itemCount: mediaActivityList.length,
            controller: PageController(initialPage: initialIndex),
            itemBuilder: (context, index) {
              return Center(
                child: Image.network(
                  mediaActivityList[index].url,
                  fit: BoxFit.contain, // Preserve the aspect ratio of the image
                  width: double.infinity, // Set width to maximum available
                  height: double.infinity, // Set height to maximum available
                ),
              );
            },
          ),
          // Positioned back button at the upper left corner
          Positioned(
            top: 20,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                Navigator.pop(context); // Go back to DetailPage
              },
            ),
          ),
        ],
      ),
    );
  }
}
