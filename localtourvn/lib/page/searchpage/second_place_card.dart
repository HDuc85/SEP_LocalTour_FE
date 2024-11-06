// lib/card/second_place_card.dart

import 'dart:async';
import 'package:flutter/material.dart';

import '../../base/place_score_manager.dart';

class SecondPlaceCard extends StatefulWidget {
  final int placeCardId;
  final String placeName;
  final int ward;
  final String photoDisplay;
  final String iconUrl;
  final int score;
  final double distance;

  const SecondPlaceCard({
    Key? key,
    required this.placeCardId,
    required this.placeName,
    required this.ward,
    required this.photoDisplay,
    required this.iconUrl,
    required this.score,
    required this.distance,
  }) : super(key: key);

  @override
  State<SecondPlaceCard> createState() => _SecondPlaceCardState();
}

class _SecondPlaceCardState extends State<SecondPlaceCard> {
  late int score;
  late StreamSubscription<int> _scoreSubscription;

  @override
  void initState() {
    super.initState();
    // Get the initial score
    score = PlaceScoreManager.instance.getScore(widget.placeCardId);

    // Listen for score updates
    _scoreSubscription = PlaceScoreManager.instance.scoreUpdates.listen((updatedPlaceId) {
      if (updatedPlaceId == widget.placeCardId) {
        setState(() {
          score = PlaceScoreManager.instance.getScore(widget.placeCardId);
        });
      }
    });
  }

  @override
  void dispose() {
    _scoreSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Format distance for display
    String formattedDistance = widget.distance > 1000
        ? '${(widget.distance / 1000).toStringAsFixed(2)} km'
        : '${widget.distance.toStringAsFixed(0)} m';

    return Container(
      color: Colors.white, // Set background color to white
      padding: const EdgeInsets.only(right: 10), // Optional padding
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section on the left
          ClipRRect(
            child: Image.network(
              widget.photoDisplay,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          // Details section on the right
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Place name and ward
                Text(
                  widget.placeName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'ward: ${widget.ward}',
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // Score and distance with icon
                const SizedBox(height: 3.5),
                Row(
                  children: [
                    Image.asset(
                      widget.iconUrl,
                      width: 16,
                      height: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$score',
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red, size: 16),
                        const SizedBox(width: 4),
                        Text(formattedDistance),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
