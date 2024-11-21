import 'dart:async';
import 'package:flutter/material.dart';
import '../../base/place_score_manager.dart';

class PlaceCard extends StatefulWidget {
  final int placeCardId;
  final String placeName;
  final String ward;
  final String photoDisplay;
  final double score;
  final double distance;
  final int countFeedback;
  final TimeOfDay? timeClose;

  const PlaceCard({
    super.key,
    required this.placeCardId,
    required this.placeName,
    required this.ward,
    required this.photoDisplay,
    required this.score,
    required this.distance,
    required this.countFeedback,
    required this.timeClose,
  });

  @override
  State<PlaceCard> createState() => _PlaceCardState();
}

class _PlaceCardState extends State<PlaceCard> {
  late String iconUrl = "assets/icons/logo.png";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget buildStarRating(double score) {
    int fullStars = score.floor(); // Full stars
    bool hasHalfStar =
        (score - fullStars) >= 0.5; // Determine if there’s a half-star

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
    String formattedDistance = '${widget.distance.toStringAsFixed(1)}';
    if (formattedDistance.endsWith('.0')) {
      formattedDistance = formattedDistance.substring(0, formattedDistance.length - 2);
    }
    formattedDistance += ' km';
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
                        Container(
                          height: 40,

                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                            buildStarRating(
                                widget.score / 2), // Display the score as stars
                          ],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${widget.countFeedback.toString()})', // Display totalReviewers as text
                          style:
                              const TextStyle(fontSize: 12), // Optional styling
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.red, size: 16),
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
