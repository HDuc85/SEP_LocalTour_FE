import 'package:flutter/material.dart';
import '../../models/places/placemedia.dart';

class FullScreenPlaceMediaViewer extends StatelessWidget {
  final List<PlaceMedia> mediaList;
  final int initialIndex;

  const FullScreenPlaceMediaViewer({Key? key, required this.mediaList, required this.initialIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Ensures a clean, non-distracting background
      body: Stack(
        children: [
          // PageView for swiping through all media
          PageView.builder(
            itemCount: mediaList.length,
            controller: PageController(initialPage: initialIndex),
            itemBuilder: (context, index) {
              return Center(
                child: Image.network(
                  mediaList[index].placeMediaUrl,
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
