import 'package:flutter/material.dart';
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
    super.key,
    required this.placeCardId,
    required this.placeName,
    required this.ward,
    required this.photoDisplay,
    required this.score,
    required this.distance,
    required this.countFeedback,
    required this.timeClose,
    this.eventModel,
    this.isEvent
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
  Widget inHour() {
    DateTime now = DateTime.now();

      Duration differenceStart = now.difference(widget.eventModel!.startDate);
      Duration differenceEnd = now.difference(widget.eventModel!.endDate);

      if(differenceStart.inHours > 0 && differenceEnd.inHours < 0 ){
        int days = 0;
        String type = '';
        if(differenceEnd.inHours.abs() > 24){
          days = (differenceEnd.inHours.abs() / 24).floor();
          type = days == 1 ? 'Day' : 'Days';
        }
        else{
          days = differenceEnd.inHours;
          type = days == 1 ? 'Hour' : 'Hours';
        }

        return Text('Available in $days $type', style: const TextStyle(color: Colors.green, fontSize: 11),);
      }
      if(differenceStart.inHours < 0){

        int days = 0;
        String type = '';
        if(differenceStart.inHours.abs() > 24){
          days = (differenceStart.inHours.abs() / 24).floor();
          type = days == 1 ? 'Day' : 'Days';
        }
        else{
          days = differenceStart.inHours;
          type = days == 1 ? 'Hour' : 'Hours';
        }

        return Text('Coming in $days $type ', style: const TextStyle(color: Colors.red ,fontSize: 11),);
      }
    return const SizedBox();
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
      height: 270,
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(5, 5),
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
                      top: Radius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        Image.network(
                          widget.photoDisplay,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        if (widget.isEvent == null)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFB0E0E6),
                                borderRadius: BorderRadius.circular(8),
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
                    padding: const EdgeInsets.only(top: 8.0, bottom: 11, left: 8, right: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.placeName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Image.asset(
                              iconUrl,
                              width: 16,
                              height: 16,
                            ),
                            const SizedBox(width: 4),
                            widget.isEvent == null
                                ? buildStarRating(widget.score / 2)
                                : Expanded(
                              child: Text(
                                widget.eventModel!.placeName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        widget.isEvent == null
                            ? Text(
                          '(${widget.countFeedback.toString()})',
                          style: const TextStyle(fontSize: 12),
                        )
                            : inHour(),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.red, size: 16),
                            const SizedBox(width: 4),
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
          ],
        ),
      ),
    );
  }

}
