import 'package:flutter/material.dart';
import '../models/location_card_info.dart';

class LocationCard extends StatelessWidget {
  final LocationCardInfo cardInfo;

  const LocationCard({super.key, required this.cardInfo});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.asset(
                cardInfo.imageUrl,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cardInfo.locationName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(cardInfo.district),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.yellow, size: 16),
                      Text('${cardInfo.rating} (${cardInfo.reviews})'),
                    ],
                  ),
                  Text('${cardInfo.distance}m away'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
