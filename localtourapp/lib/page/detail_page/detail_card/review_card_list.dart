import 'package:flutter/material.dart';
import 'package:localtourapp/models/feedback/feedback_model.dart';
import 'review_card.dart';

class ReviewCardList extends StatelessWidget {
  final int placeId;
  final List<FeedBackModel> feedbacks;
  final String userId;
  final int? limit;
  final VoidCallback? onSeeAll;
  final Function(String userId)? onReport;

  const ReviewCardList({
    Key? key,
    required this.placeId,
    required this.feedbacks,
    required this.userId,
    this.limit,
    this.onSeeAll,
    this.onReport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Limit the number of feedbacks if a limit is provided
    final displayedFeedbacks = limit != null ? feedbacks.take(limit!).toList() : feedbacks;

    return Column(
      children: [
        ...displayedFeedbacks.map((feedback) {
          final isCurrentUser = feedback.userId == userId;

          return ReviewCard(
            placeId: placeId,
            feedBackCard: feedback,
            userId: userId,
            onReport: !isCurrentUser
                ? () => onReport?.call(feedback.userId)
                : null,
          );
        }).toList(),
        if (onSeeAll != null && limit != null && feedbacks.length > limit!)
          TextButton(
            onPressed: onSeeAll,
            child: const Text(
              "See All Reviews",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }
}
