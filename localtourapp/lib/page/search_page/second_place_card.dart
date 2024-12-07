// lib/card/second_place_card.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localtourapp/models/event/event_model.dart';

import '../../base/place_score_manager.dart';

class SecondPlaceCard extends StatefulWidget {
  final int placeCardId;
  final String placeName;
  final String wardName;
  final String photoDisplay;
  final double score;
  final double distance;
  final bool? isEvent;
  final EventModel? event;
  const SecondPlaceCard({
    Key? key,
    required this.placeCardId,
    required this.placeName,
    required this.wardName,
    required this.photoDisplay,
    required this.score,
    required this.distance,
    this.isEvent,
    this.event
  }) : super(key: key);

  @override
  State<SecondPlaceCard> createState() => _SecondPlaceCardState();
}

class _SecondPlaceCardState extends State<SecondPlaceCard> {
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
    return Container(
      height: 90,
      color: Colors.white, // Set background color to white
      padding: const EdgeInsets.only(right: 10), // Optional padding
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 3,),
          // Image section on the left
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              widget.photoDisplay,
              width: 70,
              height: 70,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(

                      child: Text(
                        widget.placeName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if(widget.event != null)
                    if(differentDay(widget.event!.endDate)  > 1)
                      const Text("Ongoing" ,
                        style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold, color: Colors.green),)
                    else if(differentDay(widget.event!.startDate) > 0)
                      Text("COMING ${differentDay(widget.event!.startDate)} ${differentDay(widget.event!.startDate) > 1 ? 'DAYS' : 'DAY'}" ,
                        style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold, color: Colors.red,))
                  ],
                ),
                Text(
                  widget.wardName,
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // Score and distance with icon
                const SizedBox(height: 3.5),
                widget.isEvent == null?
                Row(
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
                        Text(formattedDistance),
                      ],
                    ),
                  ],
                ) : 
                Column(
                  children: [
                    Row(children: [
                      Image.asset(
                        'assets/icons/logo.png',
                        width: 16,
                        height: 16,
                      ),
                      const SizedBox(width: 4),
                      Text('Start ${DateFormat("h:mma dd-MM-yyyy").format(widget.event!.startDate)}', style: TextStyle(color:differentDay(widget.event!.startDate) < 0? Colors.grey: Colors.red),),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.red, size: 16),
                          const SizedBox(width: 4),
                          Text(formattedDistance),
                        ],
                      ),
                    ],),
                    Row(
                      children: [
                        const SizedBox(width: 20,),
                        Text('End   ${DateFormat("h:mma dd-MM-yyyy").format(widget.event!.endDate)}', style: TextStyle(color:differentDay(widget.event!.endDate) < 0? Colors.grey: Colors.green),),
                        const Spacer(),
                      ],
                    ),
                  ],
                )

                ,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
