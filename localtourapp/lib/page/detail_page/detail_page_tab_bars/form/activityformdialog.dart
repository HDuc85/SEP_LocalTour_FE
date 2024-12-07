// lib/page/detailpagetabbars/form/activityformdialog.dart

import 'package:flutter/material.dart';
import 'package:localtourapp/models/media_model.dart';
import '../../../../base/scrollable_text_container.dart';
import '../../../../full_media/full_activity_media_viewer.dart';

class ActivityFormDialog extends StatelessWidget {
  final int placeActivityId;
  final String activityName;
  final double price;
  final String priceType;
  final double? discount;
  final String? description;
  final List<MediaModel> mediaActivityList;

  const ActivityFormDialog({
    required this.placeActivityId,
    super.key,
    required this.activityName,
    required this.price,
    required this.priceType,
    this.discount,
    this.description,
    required this.mediaActivityList,
  });

  @override
  Widget build(BuildContext context) {
    // Filter mediaActivityList for the specific placeActivityId
    List<MediaModel> filteredMedia = mediaActivityList;


    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Wraps content vertically
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Media Display
          GestureDetector(
            onTap: () {
              if (filteredMedia.isNotEmpty) {
                // Navigate to FullActivityMediaViewer when image is tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullActivityMediaViewer(
                      mediaActivityList: filteredMedia,
                      initialIndex: 0, // Start with the first media item
                    ),
                  ),
                );
              }
            },
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Container(
                width: double.infinity,
                child: _buildMediaGrid(context, filteredMedia),
              ),
            ),
          ),
          // Scrollable Description
          Container(
            height: 200, // Fixed height for the description
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ScrollableTextContainer(content: description ?? 'No activity description available.', textSize: 16,),
          ),
          // Activity Name
          Text(
            activityName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
          // Price and Discount Information
          if (discount == null) ...[
            Center(
              child: Text(
                '${price.toStringAsFixed(0)} $priceType',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.orange,
                ),
              ),
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${(price / (1 - discount! / 100)).toStringAsFixed(0)} $priceType',
                  style: const TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '-${discount!.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Center(
              child: Text(
                '${(price * (1 - discount!)).toStringAsFixed(0)} $priceType',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.orange,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ],
      ),
    );
  }

  // Helper method to build the media grid layout
  Widget _buildMediaGrid(BuildContext context, List<MediaModel> mediaList) {
    if (mediaList.isEmpty) {
      return Container(
        width: double.infinity,
        height: 280,
        color: Colors.grey,
        child: const Icon(Icons.photo, size: 50),
      );
    }

    int displayCount = mediaList.length > 5 ? 5 : mediaList.length;
    List<MediaModel> displayMedia = mediaList.take(displayCount).toList();

    return Column(
      children: [
        // First Media (Single Image)
        GestureDetector(
          onTap: () {
            if (mediaList.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullActivityMediaViewer(
                    mediaActivityList: mediaList,
                    initialIndex: 0,
                  ),
                ),
              );
            }
          },
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
            child: Image.network(
              displayMedia[0].url,
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  width: double.infinity,
                  height: 150,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 150,
                  color: Colors.grey,
                  child: const Icon(Icons.broken_image, size: 50),
                );
              },
            ),
          ),
        ),
        // Row of 4 Media Items
        Row(
          children: List.generate(
            4,
                (index) {
              if (index + 1 < displayMedia.length) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FullActivityMediaViewer(
                            mediaActivityList: mediaList,
                            initialIndex: index + 1,
                          ),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        Image.network(
                          displayMedia[index + 1].url,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 50,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              width: double.infinity,
                              height: 50,
                              color: Colors.grey[200],
                              child: const Center(child: CircularProgressIndicator()),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              height: 50,
                              color: Colors.grey,
                              child: const Icon(Icons.broken_image, size: 30),
                            );
                          },
                        ),
                        // Show "See more" overlay on the last image if there are more than 5 media items
                        if (index == 3 && mediaList.length > 5)
                          Container(
                            width: double.infinity,
                            height: 50,
                            color: Colors.black.withOpacity(0.5),
                            child: const Center(
                              child: Text(
                                'See more',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              } else {
                return Expanded(child: Container());
              }
            },
          ),
        ),
      ],
    );
  }
}