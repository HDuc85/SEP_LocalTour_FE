// lib/card/activity_card.dart

import 'package:flutter/material.dart';
import '../../../fullmedia/fullactivitymediaviewer.dart';
import '../../../models/places/placeactivitymedia.dart';
import '../detailpagetabbars/form/activityformdialog.dart';

class ActivityCard extends StatelessWidget {
  final int placeActivityId;
  final String activityName;
  final String? photoDisplay;
  final double price;
  final String priceType;
  final double? discount;
  final VoidCallback onTap;
  final List<PlaceActivityMedia> mediaActivityList;

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
    List<PlaceActivityMedia> filteredMedia = mediaActivityList
        .where((media) => media.placeActivityId == placeActivityId)
        .toList();

    return GestureDetector(
      onTap: () {
        // Show ActivityFormDialog directly when the card is tapped
        showDialog(
          context: context,
          builder: (_) => ActivityFormDialog(
            placeActivityId: placeActivityId,
            activityName: activityName,
            photoDisplayUrl: photoDisplay ?? 'https://picsum.photos/250?image=9',
            price: price,
            priceType: priceType,
            discount: discount,
            description: null, // Pass description if available
            mediaActivityList: filteredMedia,
          ),
        );
      },
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
                  child: photoDisplay != null
                      ? Image.network(
                    photoDisplay!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
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
                              '${price.toStringAsFixed(0)} $priceType',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              '-${discount!.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Center(
                        child: Text(
                          '${(price * (1 - discount! / 100)).toStringAsFixed(0)} $priceType',
                          style: const TextStyle(
                            fontSize: 14,
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
