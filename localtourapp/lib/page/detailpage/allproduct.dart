// lib/page/allproduct.dart

import 'package:flutter/material.dart';
import 'detailcard/activity_card.dart';
import 'detailcard/activity_card_info.dart';
import 'detailpagetabbars/form/activityformdialog.dart';
import '../../models/places/placeactivitymedia.dart';

class AllProductPage extends StatelessWidget {
  final int placeId; // Added placeId field
  final List<ActivityCardInfo> activityCards; // The list of products related to the place
  final List<PlaceActivityMedia> mediaActivityList; // Added mediaActivityList

  const AllProductPage({
    super.key,
    required this.activityCards,
    required this.placeId, // Initialize placeId
    required this.mediaActivityList, // Initialize mediaActivityList
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Products')),
      body: GridView.builder(
        padding: const EdgeInsets.all(4.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 cards per row to ensure they fit properly
          crossAxisSpacing: 4, // Horizontal spacing between items
          mainAxisSpacing: 20, // Vertical spacing between items
          childAspectRatio: 0.8, // Adjust this to better fit the card's aspect ratio
        ),
        itemCount: activityCards.length,
        itemBuilder: (context, index) {
          final product = activityCards[index];
          return GestureDetector(
            onTap: () {
              // Trigger the ActivityFormDialog when a product is tapped
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ActivityFormDialog(
                    placeActivityId: product.placeActivityId,
                    activityName: product.activityName,
                    price: product.price,
                    priceType: product.priceType,
                    discount: product.discount,
                    description: product.description,
                    mediaActivityList: mediaActivityList, // Pass the full mediaActivityList
                  );
                },
              );
            },
            child: ActivityCard(
              placeActivityId: product.placeActivityId,
              activityName: product.activityName,
              photoDisplay: product.photoDisplay,
              price: product.price,
              priceType: product.priceType,
              discount: product.discount,
              onTap: () {
                // Same action when the product is tapped
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ActivityFormDialog(
                      placeActivityId: product.placeActivityId,
                      activityName: product.activityName,
                      price: product.price,
                      priceType: product.priceType,
                      discount: product.discount,
                      description: product.description,
                      mediaActivityList: mediaActivityList, // Pass the full mediaActivityList
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
