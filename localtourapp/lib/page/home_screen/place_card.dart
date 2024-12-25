import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/event/event_model.dart';

class PlaceCard extends StatefulWidget {
  final int placeCardId;
  final String placeName;
  final String ward;
  final String photoDisplay;
  final double score;
  final double distance;
  final int countFeedback;
  final TimeOfDay? timeClose;
  final bool? isEvent;
  final EventModel? eventModel;

  const PlaceCard({
    Key? key,
    required this.placeCardId,
    required this.placeName,
    required this.ward,
    required this.photoDisplay,
    required this.score,
    required this.distance,
    required this.countFeedback,
    required this.timeClose,
    this.eventModel,
    this.isEvent,
  }) : super(key: key);

  @override
  State<PlaceCard> createState() => _PlaceCardState();
}

class _PlaceCardState extends State<PlaceCard> {
  // Build star rating widget
  Widget buildStarRating(double score) {
    int fullStars = score.floor(); // Full stars
    bool hasHalfStar = (score - fullStars) >= 0.5; // Determine if there’s a half-star

    return Row(
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return const Icon(Icons.star, color: Colors.amber, size: 16);
        } else if (index == fullStars && hasHalfStar) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 16);
        } else {
          return const Icon(Icons.star_border, color: Colors.amber, size: 16);
        }
      }),
    );
  }

  // Display availability based on event times
  Widget inHour() {
    if (widget.eventModel == null) return const SizedBox();

    DateTime now = DateTime.now();
    DateTime startDate = widget.eventModel!.startDate;
    DateTime endDate = widget.eventModel!.endDate;

    if (now.isAfter(startDate) && now.isBefore(endDate)) {
      // Event is currently ongoing
      return const Text(
        'Ongoing',
        style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
      );
    } else if (now.isBefore(startDate)) {
      // Event is upcoming
      Duration difference = startDate.difference(now);
      int days = difference.inDays;
      int hours = difference.inHours % 24;
      String timeString = days > 0
          ? '$days ${days == 1 ? 'Day' : 'Days'}'
          : '$hours ${hours == 1 ? 'Hour' : 'Hours'}';
      return Text(
        'Coming in $timeString',
        style: const TextStyle(color: Colors.red, fontSize: 12),
      );
    } else {
      // Event has ended
      return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDistance = widget.distance.toStringAsFixed(1);
    if (formattedDistance.endsWith('.0')) {
      formattedDistance = formattedDistance.substring(0, formattedDistance.length - 2);
    }
    formattedDistance += ' km';

    return SizedBox(
      width: 160,
      height: 260,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), // Shadow color
              blurRadius: 5, // Blur radius for smoothness
              offset: const Offset(10, 15), // Shadow tilt to bottom-right
            ),
          ],
        ),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: [
                // Image Section
                Expanded(
                  flex: 5,
                  child: Stack(
                    children: [
                      // Cached Network Image with placeholder and error handling
                      CachedNetworkImage(
                        imageUrl: widget.photoDisplay,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(Icons.error, color: Colors.red),
                          ),
                        ),
                      ),
                      // Gradient Overlay for better text contrast
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 60,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                      // Ward Label
                      if (widget.isEvent == null)
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              widget.ward,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Details Section
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Place Name
                        Text(
                          widget.placeName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Rating or Event Name
                        Row(
                          children: [
                            Image.asset(
                              "assets/icons/logo.png",
                              width: 16,
                              height: 16,
                            ),
                            const SizedBox(width: 4),
                            widget.isEvent == null
                                ? buildStarRating(widget.score / 2)
                                : Expanded(
                              child: Text(
                                widget.eventModel?.placeName ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        // Feedback Count or In-Hour
                        widget.isEvent == null
                            ? Text(
                          '(${widget.countFeedback.toString()})',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        )
                            : inHour(),
                        // Distance
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.red, size: 16),
                            Text(
                              formattedDistance,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
