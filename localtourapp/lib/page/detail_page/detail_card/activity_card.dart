// lib/card/activity_card.dart

import 'package:flutter/material.dart';
import 'package:localtourapp/models/media_model.dart';
import '../../../full_media/full_activity_media_viewer.dart';

class ActivityCard extends StatelessWidget {
  final int placeActivityId;
  final String activityName;
  final String? photoDisplay;
  final double price;
  final String priceType;
  final double? discount;
  final VoidCallback onTap;
  final List<MediaModel> mediaActivityList;

  const ActivityCard({
    Key? key,
    required this.placeActivityId,
    required this.activityName,
    this.photoDisplay,
    required this.price,
    required this.priceType,
    this.discount,
    required this.onTap,
    required this.mediaActivityList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<MediaModel> filteredMedia = mediaActivityList;

    return GestureDetector(
      onTap: onTap, // Use the passed onTap callback
      child: Container(
        width: 160,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(-10, 15),
            ),
          ],
        ),
        child: Column(
          children: [
            // Image Section with GestureDetector to open FullActivityMediaViewer
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: () {
                  if (filteredMedia.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullActivityMediaViewer(
                          mediaActivityList: filteredMedia,
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
                  child: photoDisplay != null && photoDisplay!.isNotEmpty
                      ? Image.network(
                    photoDisplay!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded /
                              progress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey,
                        child:
                        const Icon(Icons.broken_image, size: 50),
                      );
                    },
                  )
                      : Container(
                    color: Colors.grey,
                    child: const Icon(Icons.photo, size: 50),
                  ),
                ),
              ),
            ),
            // Details Section
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activityName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (discount != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              discount! !=0?
                              '${price.toStringAsFixed(0)} $priceType':'',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              discount! != 0?
                              '-${(discount!*100).toStringAsFixed(0)}%':'',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Center(
                        child: Text(
                          '${(price * (1 - discount!)).toStringAsFixed(0)} $priceType',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ] else ...[
                      Center(
                        child: Text(
                          '${price.toStringAsFixed(0)} $priceType',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


