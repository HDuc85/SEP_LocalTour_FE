import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localtourapp/models/event/event_model.dart';

import '../detail_page/detail_page.dart';

class SecondPlaceCard extends StatefulWidget {
  final int placeCardId;
  final String placeName;
  final String wardName;
  final String photoDisplay;
  final double score;
  final double distance;
  final bool? isEvent;
  final EventModel? event;
  final double dynamicHeight;
  const SecondPlaceCard({
    Key? key,
    required this.placeCardId,
    required this.placeName,
    required this.wardName,
    required this.photoDisplay,
    required this.score,
    required this.distance,
    this.isEvent,
    this.event,
    required this.dynamicHeight,
  }) : super(key: key);

  @override
  State<SecondPlaceCard> createState() => _SecondPlaceCardState();
}

class _SecondPlaceCardState extends State<SecondPlaceCard> {

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

  int differentDay(DateTime date) {
    DateTime currentDate = DateTime.now();
    Duration difference = date.difference(currentDate);
    return difference.inDays;
  }

  @override
  Widget build(BuildContext context) {
    // Format distance for display
    String formattedDistance = widget.distance.toStringAsFixed(1);
    if (formattedDistance.endsWith('.0')) {
      formattedDistance = formattedDistance.substring(0, formattedDistance.length - 2);
    }
    formattedDistance += ' km';

    // Determine event status
    Widget eventStatusWidget = Container();
    if (widget.event != null) {
      int daysToEnd = differentDay(widget.event!.endDate);
      int daysToStart = differentDay(widget.event!.startDate);

      if (daysToEnd > 1) {
        eventStatusWidget = const Text(
          "Ongoing",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.green),
        );
      } else if (daysToStart > 0) {
        eventStatusWidget = Text(
          "COMING $daysToStart ${daysToStart > 1 ? 'DAYS' : 'DAY'}",
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.red),
        );
      }
    }

    return Container(
      height: widget.dynamicHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailPage(
                placeId: widget.placeCardId,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section on the left
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.photoDisplay,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.blue,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Details section on the right
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Place name and event status
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.placeName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.event != null) eventStatusWidget,
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Ward name
                    Text(
                      widget.wardName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Score and distance with icons
                    widget.isEvent == null
                        ? Row(
                      children: [
                        Image.asset(
                          'assets/icons/logo.png',
                          width: 16,
                          height: 16,
                        ),
                        const SizedBox(width: 4),
                        buildStarRating(widget.score),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.red, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              formattedDistance,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    )
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/icons/logo.png',
                              width: 16,
                              height: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Start ${DateFormat("h:mma dd-MM-yyyy").format(widget.event!.startDate)}',
                              style: TextStyle(
                                color: differentDay(widget.event!.startDate) < 0
                                    ? Colors.grey
                                    : Colors.green,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const SizedBox(width: 20),
                            Text(
                              'End ${DateFormat("h:mma dd-MM-yyyy").format(widget.event!.endDate)}',
                              style: TextStyle(
                                color: differentDay(widget.event!.endDate) < 0
                                    ? Colors.grey
                                    : Colors.red,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.red, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              formattedDistance,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}