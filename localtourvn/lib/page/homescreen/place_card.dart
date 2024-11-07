import 'dart:async';
import 'package:flutter/material.dart';
import '../../base/place_score_manager.dart';

class PlaceCard extends StatefulWidget {
  final int placeCardId;
  final String placeName;
  final String ward;
  final String photoDisplay;
  final String iconUrl;
  final double score;
  final double distance;

  const PlaceCard({
    super.key,
    required this.placeCardId,
    required this.placeName,
    required this.ward,
    required this.photoDisplay,
    required this.iconUrl,
    required this.score,
    required this.distance,
  });

  @override
  State<PlaceCard> createState() => _PlaceCardState();
}

class _PlaceCardState extends State<PlaceCard> {
  late double score;
  late int totalReviewers;
  late StreamSubscription<int> _scoreSubscription;

  @override
  void initState() {
    super.initState();
    // Get the initial score
    score = PlaceScoreManager.instance.getScore(widget.placeCardId);
    totalReviewers = PlaceScoreManager.instance.getReviewCount(widget.placeCardId);

    // Listen for score updates
    _scoreSubscription = PlaceScoreManager.instance.scoreUpdates.listen((updatedPlaceId) {
      if (updatedPlaceId == widget.placeCardId) {
        setState(() {
          score = PlaceScoreManager.instance.getScore(widget.placeCardId);
          totalReviewers = PlaceScoreManager.instance.getReviewCount(widget.placeCardId);
        });
      }
    });
  }

  @override
  void dispose() {
    _scoreSubscription.cancel();
    super.dispose();
  }

  Widget buildStarRating(double score) {
    int fullStars = score.floor(); // Full stars
    bool hasHalfStar = (score - fullStars) >= 0.5; // Determine if there’s a half-star

    return Row(
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return const Icon(Icons.star, color: Colors.red, size: 16);
        } else if (index == fullStars && hasHalfStar) {
          return const Icon(Icons.star_half, color: Colors.red, size: 16);
        } else {
          return const Icon(Icons.star_border, color: Colors.red, size: 16);
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Format distance: If it's greater than 1000m, convert to km and limit to 2 decimal places
    String formattedDistance = widget.distance > 1000
        ? '${(widget.distance / 1000).toStringAsFixed(2)} km'
        : '${widget.distance.toStringAsFixed(2)} m';

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
                          widget.photoDisplay,
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
                              color: Color(0xFFB0E0E6),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                            child: Text(
                              widget.ward,
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
                                widget.placeName,
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
                              widget.iconUrl,
                              width: 16,
                              height: 16,
                            ),
                            const SizedBox(width: 4),
                            buildStarRating(score / 2), // Display the score as stars
                          ],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${totalReviewers.toString()})', // Display totalReviewers as text
                          style: const TextStyle(fontSize: 12), // Optional styling
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.red, size: 16),
                            const SizedBox(width: 4),
                            Text(formattedDistance),
                          ],
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
}
