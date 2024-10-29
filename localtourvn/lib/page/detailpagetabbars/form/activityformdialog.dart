import 'package:flutter/material.dart';
import 'package:localtourvn/models/places/placeactivitymedia.dart';

import '../../fullscreenactivitymediaviewer.dart';

class ActivityFormDialog extends StatelessWidget {
  final String activityName;
  final String photoDisplayUrl; // This should be the URL of the image, not the ID
  final double price;
  final String priceType;
  final double? discount;
  final String? description;
  final List<PlaceActivityMedia> mediaActivityList;

  const ActivityFormDialog({
    super.key,
    required this.activityName,
    required this.photoDisplayUrl, // Use the URL here
    required this.price,
    required this.priceType,
    this.discount,
    this.description,
    required this.mediaActivityList,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(0.0),
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
                    // Navigate to FullScreenPlaceMediaViewer when image is tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullScreenActivityMediaViewer(
                          mediaActivityList: mediaActivityList, // Pass media list
                          initialIndex: 0, // You can start with the first image or modify as needed
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    child: photoDisplayUrl.isNotEmpty
                        ? Image.network(
                      photoDisplayUrl, // Use the correct URL here
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
      ),
    );
  }
}
