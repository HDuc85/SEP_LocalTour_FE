import 'package:flutter/material.dart';
import '../const.dart';

class PlaceCard extends StatelessWidget {
  final int placeCardId;
  final String placeName;
  final String ward;
  final String photoDisplay;
  final String iconUrl;
  final double rating;
  final int reviews;
  final double distance;

  const PlaceCard({
    super.key,
    required this.placeCardId,
    required this.placeName,
    required this.ward,
    required this.photoDisplay,
    required this.iconUrl,
    required this.rating,
    required this.reviews,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    // Format distance: If it's greater than 1000m, convert to km and limit to 2 decimal places
    String formattedDistance = distance > 1000
        ? '${(distance / 1000).toStringAsFixed(2)} km'
        : '${distance.toStringAsFixed(2)} m';

    return SizedBox(
      width: 140,
      height: 240,
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(-10, 15),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  flex: 1,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        Image.network(
                          photoDisplay,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF6E562),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                            child: Text(
                              ward,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                placeName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Image.asset(
                              iconUrl,
                              width: 16,
                              height: 16,
                            ),
                            const SizedBox(width: 4),
                            Row(
                              children: _buildRatingStars(rating),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '($reviews+)',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Distance: $formattedDistance',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build star ratings
  List<Widget> _buildRatingStars(double rating) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;

    // Add full stars
    for (int i = 0; i < fullStars; i++) {
      stars.add(const Icon(Icons.star, color: Constants.starColor, size: 16));
    }

    // Add half star if applicable
    if (hasHalfStar) {
      stars.add(
          const Icon(Icons.star_half, color: Constants.starColor, size: 16));
    }

    // Add empty stars to fill up to 5 stars
    while (stars.length < 5) {
      stars.add(const Icon(Icons.star_border, color: Constants.starColor, size: 16));
    }

    return stars;
  }
}
