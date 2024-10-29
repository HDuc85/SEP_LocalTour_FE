import 'package:flutter/material.dart';
import '../../card/activity_card_info.dart';
import '../card/activity_card.dart';
import 'detailpagetabbars/form/activityformdialog.dart';

class AllProductPage extends StatelessWidget {
  final int placeId;
  final List<ActivityCardInfo> activityCards; // The list of products related to the place

  const AllProductPage({
    super.key,
    required this.placeId,
    required this.activityCards,
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
                      activityName: product.activityName,
                      photoDisplayUrl: product.photoDisplayUrl,
                      price: product.price,
                      priceType: product.priceType,
                      discount: product.discount,
                      description: product.description,
                      mediaActivityList: [], // Pass media list if available
                    );
                  },
                );
              },
              child: ActivityCard(
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
                        activityName: product.activityName,
                        photoDisplayUrl: product.photoDisplayUrl,
                        price: product.price,
                        priceType: product.priceType,
                        discount: product.discount,
                        description: product.description,
                        mediaActivityList: const [], // Pass media list if available
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
