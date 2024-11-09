// lib/page/detailpagetabbars/form/activityformdialog.dart

import 'package:flutter/material.dart';

import '../../../../fullmedia/fullactivitymediaviewer.dart';
import '../../../../models/places/placeactivitymedia.dart';

class ActivityFormDialog extends StatelessWidget {
  final int placeActivityId;
  final String activityName;
  final String photoDisplayUrl; // URL of the media
  final double price;
  final String priceType;
  final double? discount;
  final String? description;
  final List<PlaceActivityMedia> mediaActivityList;

  const ActivityFormDialog({
    required this.placeActivityId, // Included in constructor
    super.key,
    required this.activityName,
    required this.photoDisplayUrl,
    required this.price,
    required this.priceType,
    this.discount,
    this.description,
    required this.mediaActivityList,
  });

  @override
  Widget build(BuildContext context) {
    // Filter mediaActivityList for the specific placeActivityId
    List<PlaceActivityMedia> filteredMedia = mediaActivityList
        .where((media) => media.placeActivityId == placeActivityId)
        .toList();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Row with Image and Description
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Display with GestureDetector
              GestureDetector(
                onTap: () {
                  if (filteredMedia.isNotEmpty) {
                    // Navigate to FullScreenActivityMediaViewer when image is tapped
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
                  child: photoDisplayUrl.isNotEmpty
                      ? Image.network(
                    photoDisplayUrl, // Correct URL
                    width: 140,
                    height: 100,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    width: 140,
                    height: 100,
                    color: Colors.grey,
                    child: const Icon(Icons.photo, size: 50),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Scrollable Description
              Expanded(
                child: Container(
                  height: 100, // Restricting the height for scrolling
                  padding: const EdgeInsets.only(right: 8),
                  child: SingleChildScrollView(
                    child: Text(
                      description ?? 'No description available',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Activity Name
          Text(
            activityName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
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
                const SizedBox(width: 8),
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
                '${(price * (1 - discount! / 100)).toStringAsFixed(0)} $priceType',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.orange,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
