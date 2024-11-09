import 'package:flutter/material.dart';
import 'package:localtourvn/models/places/placefeedbackhelpful.dart';
import 'package:localtourvn/page/detailpage/detailcard/review_card.dart';
import '../../../models/places/placefeedback.dart';
import '../../../models/places/placefeeedbackmedia.dart';
import '../../../models/users/users.dart';
// ReviewCardList.dart

class ReviewCardList extends StatelessWidget {
  final List<int> favoritedFeedbackIds;
  final Function(int feedbackId, bool isFavorited) onFavoriteToggle;
  final List<PlaceFeedback> feedbacks;
  final List<User> users;
  final List<PlaceFeedbackMedia> feedbackMediaList;
  final List<PlaceFeedbackHelpful> feedbackHelpfuls; // Add this line
  final String userId;
  final int? limit; // Optional limit on the number of reviews to display
  final VoidCallback? onSeeAll; // Callback for "See All" button
  final Function(PlaceFeedback feedback)? onUpdate;
  final Function(PlaceFeedback feedback)? onDelete;
  final Function(PlaceFeedback feedback)? onReport;
  final bool showUpdateDeleteForCurrentUser; // New parameter

  const ReviewCardList({
    Key? key,
    required this.favoritedFeedbackIds,
    required this.onFavoriteToggle,
    required this.feedbacks,
    required this.users,
    required this.feedbackMediaList,
    required this.userId,
    required this.feedbackHelpfuls, // Add this line to constructor
    this.limit,
    this.onSeeAll,
    this.onUpdate,
    this.onDelete,
    this.onReport,
    this.showUpdateDeleteForCurrentUser = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Limit the number of feedbacks if a limit is provided
    final displayedFeedbacks = limit != null ? feedbacks.take(limit!).toList() : feedbacks;

    return Column(
      children: [
        ...displayedFeedbacks.map((feedback) {
          final user = users.firstWhere(
                (user) => user.userId == feedback.userId,
            orElse: () => User(
              userId: 'default',
              userName: 'Unknown User',
              emailConfirmed: false,
              phoneNumberConfirmed: false,
              dateCreated: DateTime.now(),
              dateUpdated: DateTime.now(),
              reportTimes: 0,
            ),
          );
          final mediaList = feedbackMediaList
              .where((media) => media.feedbackId == feedback.placeFeedbackId)
              .toList();

          // Filter relevant feedbackHelpfuls for this feedback
          final relevantHelpfuls = feedbackHelpfuls
              .where((helpful) => helpful.placeFeedbackId == feedback.placeFeedbackId)
              .toList();

          final isCurrentUser = feedback.userId == userId;

          return ReviewCard(
            user: user,
            feedback: feedback,
            feedbackMediaList: mediaList,
            feedbackHelpfuls: relevantHelpfuls, // Pass relevant helpfuls
            userId: userId,
            onUpdate: (isCurrentUser && showUpdateDeleteForCurrentUser)
                ? () => onUpdate?.call(feedback)
                : null,
            onDelete: (isCurrentUser && showUpdateDeleteForCurrentUser)
                ? () => onDelete?.call(feedback)
                : null,
            onReport: !isCurrentUser
                ? () => onReport?.call(feedback)
                : null,
            favoritedFeedbackIds: favoritedFeedbackIds,
            onFavoriteToggle: onFavoriteToggle,
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
