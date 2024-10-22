import 'package:flutter/material.dart';

class LocationCard extends StatelessWidget {
  final String locationName;
  final String district;
  final String imageUrl;
  final double rating;
  final int reviews;
  final double distance;

  const LocationCard({
    Key? key,
    required this.locationName,
    required this.district,
    required this.imageUrl,
    required this.rating,
    required this.reviews,
    required this.distance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140, // Set a fixed width for the card
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26, // Darker shadow color
            blurRadius: 30, // Increase blur for a more pronounced shadow
            offset: Offset(5, 0), // Shadow towards the bottom-right
          ),
        ],

      ),
      child: Column(
        children: [
          // Image taking up half the height
          Expanded(
            flex: 1, // This makes the image take 1/2 of the card
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.asset(
                imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content taking up the other half
          Expanded(
            flex: 1, // This makes the content take 1/2 of the card
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    locationName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    district,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.yellow[700], size: 16),
                      Text('$rating ($reviews reviews)', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Distance: ${distance}m',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
