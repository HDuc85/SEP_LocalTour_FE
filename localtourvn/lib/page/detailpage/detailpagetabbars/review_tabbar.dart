import 'dart:io';
import 'package:flutter/material.dart';
import '../../../models/users/users.dart';
import '../detailcard/ReviewCardList.dart';
import '../detailcard/review_card.dart';
import '../../../models/places/placefeedback.dart';
import '../../../models/places/placefeedbackhelpful.dart';
import '../../../models/places/placefeeedbackmedia.dart';
import '../all_reviews_page.dart';
import '../../../base/score_tooltip.dart';
import 'form/reportform.dart';
import 'form/review_dialog.dart';
import '../../../base/place_score_manager.dart';
import 'package:collection/collection.dart';

class ReviewTabbar extends StatefulWidget {
  final List<PlaceFeedback> feedbacks;
  final List<User> users;
  final List<PlaceFeedbackMedia> feedbackMediaList;
  final int placeId;
  final String userId;

  const ReviewTabbar({
    super.key,
    required this.feedbacks,
    required this.users,
    required this.feedbackMediaList,
    required this.placeId,
    required this.userId,
  });

  @override
  State<ReviewTabbar> createState() => _ReviewTabbarState();
}

class _ReviewTabbarState extends State<ReviewTabbar> {
  List<int> favoritedFeedbackIds = [];
  List<PlaceFeedback> placeFeedbacks = [];
  List<PlaceFeedbackMedia> feedbackMediaList = [];
  List<PlaceFeedbackHelpful> feedbackHelpfuls = [];
  bool showAllReviews = false;

  @override
  void initState() {
    super.initState();
    placeFeedbacks = getPlaceFeedbacks();
    feedbackMediaList = widget.feedbackMediaList.where((media) {
      return placeFeedbacks
          .any((feedback) => feedback.placeFeedbackId == media.feedbackId);
    }).toList();
    feedbackHelpfuls = feebBackHelpfuls;

    // Calculate the initial score
    int score = calculateScore(placeFeedbacks);

    // Set the score in PlaceScoreManager
    PlaceScoreManager.instance.setScore(widget.placeId, score);
  }

  void addOrUpdateReview(
      int rating, String content, List<File> images, List<File> videos) {
    final existingFeedbackIndex = placeFeedbacks.indexWhere(
      (feedback) => feedback.userId == widget.userId,
    );

    final feedback = PlaceFeedback(
      placeFeedbackId: existingFeedbackIndex >= 0
          ? placeFeedbacks[existingFeedbackIndex].placeFeedbackId
          : widget.feedbacks.length + 1,
      placeId: widget.placeId,
      userId: widget.userId,
      rating: rating.toDouble(),
      content: content,
      createdDate: DateTime.now(),
    );

    setState(() {
      if (existingFeedbackIndex >= 0) {
        widget.feedbacks[existingFeedbackIndex] = feedback;
        placeFeedbacks[existingFeedbackIndex] = feedback;
      } else {
        widget.feedbacks.insert(0, feedback);
        placeFeedbacks.insert(0, feedback);
      }

      // Remove any existing media entries for this feedback before adding user-added media
      feedbackMediaList
          .removeWhere((media) => media.feedbackId == feedback.placeFeedbackId);

      // Update the main feedbackMediaList (the one used by ReviewCard)
      for (var image in images) {
        feedbackMediaList.add(PlaceFeedbackMedia(
          id: feedbackMediaList.length + 1,
          feedbackId: feedback.placeFeedbackId,
          type: 'photo',
          url: image.path,
          createDate: DateTime.now(),
        ));
      }

      for (var video in videos) {
        feedbackMediaList.add(PlaceFeedbackMedia(
          id: feedbackMediaList.length + 1,
          feedbackId: feedback.placeFeedbackId,
          type: 'video',
          url: video.path,
          createDate: DateTime.now(),
        ));
      }

      // Recalculate the score and update PlaceScoreManager
      int score = calculateScore(placeFeedbacks);
      PlaceScoreManager.instance.setScore(widget.placeId, score);
    });
  }

  void deleteReview() {
    setState(() {
      widget.feedbacks
          .removeWhere((feedback) => feedback.userId == widget.userId);
      placeFeedbacks
          .removeWhere((feedback) => feedback.userId == widget.userId);
      feedbackMediaList
          .removeWhere((media) => media.feedbackId == widget.userId);

      // Recalculate the score and update PlaceScoreManager
      int score = calculateScore(placeFeedbacks);
      PlaceScoreManager.instance.setScore(widget.placeId, score);
    });
  }

  List<PlaceFeedback> getPlaceFeedbacks() {
    return widget.feedbacks
        .where((feedback) => feedback.placeId == widget.placeId)
        .toList();
  }

  bool hasUserReviewed() {
    return placeFeedbacks.any((feedback) => feedback.userId == widget.userId);
  }

  User getUserDetails(String userId) {
    return widget.users.firstWhere(
      (user) => user.userId == userId,
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
  }

  int calculateScore(List<PlaceFeedback> placeFeedbacks) {
    int score = 0;
    for (var feedback in placeFeedbacks) {
      switch (feedback.rating.toInt()) {
        case 5:
          score += 2;
          break;
        case 4:
          score += 1;
          break;
        case 3:
          score += 0;
          break;
        case 2:
          score -= 1;
          break;
        case 1:
          score -= 2;
          break;
        default:
          score += 1;
      }
    }
    return score;
  }

  bool _areListsEqual(List<File> list1, List<File> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].path != list2[i].path) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final int totalReviews = placeFeedbacks.length;
    final bool userHasReviewed = hasUserReviewed();
    final int totalReviewers = placeFeedbacks.length;
    final int score = calculateScore(placeFeedbacks);

    // Get current user's review
    PlaceFeedback? currentUserReview = placeFeedbacks.firstWhereOrNull(
      (feedback) => feedback.userId == widget.userId,
    );

    // Get other users' reviews
    final otherUserReviews = placeFeedbacks
        .where((feedback) => feedback.userId != widget.userId)
        .toList();

    String formatNumber(int number) {
      if (number >= 1000000) {
        return '${(number / 1000000).toStringAsFixed(1)}M';
      } else if (number >= 1000) {
        return '${(number / 1000).toStringAsFixed(1)}K';
      } else {
        return number.toString();
      }
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  "reviewers: ${formatNumber(totalReviewers)}",
                  style: const TextStyle(fontSize: 10),
                ),
                Text(
                  "Score: ${formatNumber(score)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.red,
                  ),
                ),
                ScoreDetailsTooltip(),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllReviewsPage(
                          feedbacks: widget.feedbacks,
                          users: widget.users,
                          feedbackMediaList: widget.feedbackMediaList,
                          placeId: widget.placeId,
                          userId: widget.userId,
                          favoritedFeedbackIds: favoritedFeedbackIds,
                          totalReviews: totalReviews,
                          feedbackHelpfuls: feedbackHelpfuls,
                        ),
                      ),
                    );
                  },
                  child: const Text("See all"),
                ),
              ],
            ),
          ),
          if (!userHasReviewed)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                        getUserDetails(widget.userId).profilePictureUrl ?? ''),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${getUserDetails(widget.userId).userName}, you have no reviews yet, let's explore and review it!",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ReviewDialog(
                            onSubmit: (int rating, String content,
                                List<File> images, List<File> videos) {
                              addOrUpdateReview(
                                  rating, content, images, videos);
                              setState(() {});
                            },
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 30),
                      elevation: 2,
                      side: const BorderSide(color: Colors.black, width: 1),
                    ),
                    child: const Text(
                      'Review !!!',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          if (currentUserReview != null)
            ReviewCard(
              userId: widget.userId,
              user: getUserDetails(currentUserReview.userId),
              feedback: currentUserReview,
              feedbackMediaList: feedbackMediaList
                  .where((media) =>
                      media.feedbackId == currentUserReview.placeFeedbackId)
                  .toList(),
              favoritedFeedbackIds: favoritedFeedbackIds,
              onFavoriteToggle: _handleFavoriteToggle,
              feedbackHelpfuls: feedbackHelpfuls.where((helpful) => helpful.placeFeedbackId == currentUserReview.placeFeedbackId)
                  .toList(),
              onUpdate: () {
                final parentContext = context;
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ReviewDialog(
                      initialRating: currentUserReview.rating.toInt(),
                      initialContent: currentUserReview.content ?? '',
                      initialImages: feedbackMediaList
                          .where((media) => media.type == 'photo')
                          .map((media) => File(media.url))
                          .toList(),
                      initialVideos: feedbackMediaList
                          .where((media) => media.type == 'video')
                          .map((media) => File(media.url))
                          .toList(),
                      onSubmit: (int rating, String content, List<File> images,
                          List<File> videos) {
                        if (rating != currentUserReview.rating.toInt() ||
                            content != currentUserReview.content ||
                            !_areListsEqual(
                                images,
                                feedbackMediaList
                                    .where((media) => media.type == 'photo')
                                    .map((media) => File(media.url))
                                    .toList()) ||
                            !_areListsEqual(
                                videos,
                                feedbackMediaList
                                    .where((media) => media.type == 'video')
                                    .map((media) => File(media.url))
                                    .toList())) {
                          addOrUpdateReview(rating, content, images, videos);
                          ScaffoldMessenger.of(parentContext).showSnackBar(
                            const SnackBar(
                                content: Text('Your review updated')),
                          );
                        } else {
                          ScaffoldMessenger.of(parentContext).showSnackBar(
                            const SnackBar(
                                content: Text('You have not changed anything')),
                          );
                        }
                      },
                    );
                  },
                );
              },
              onDelete: deleteReview,
              onReport: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReportForm(
                        message:
                            'Have a problem with this person, please report them to us.'),
                  ),
                );
              },
            ),
          ReviewCardList(
            feedbacks: otherUserReviews,
            users: widget.users,
            feedbackMediaList: feedbackMediaList,
            userId: widget.userId,
            favoritedFeedbackIds: favoritedFeedbackIds,
            onFavoriteToggle: _handleFavoriteToggle,
            feedbackHelpfuls: feedbackHelpfuls,
            limit: 2,
            onSeeAll: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllReviewsPage(
                    feedbacks: widget.feedbacks,
                    users: widget.users,
                    feedbackMediaList: widget.feedbackMediaList,
                    placeId: widget.placeId,
                    userId: widget.userId,
                    feedbackHelpfuls: feedbackHelpfuls,
                    favoritedFeedbackIds: favoritedFeedbackIds,
                    totalReviews: totalReviews,
                  ),
                ),
              );
            },
            onReport: (feedback) {
              ReportForm.show(
                context,
                'Have a problem with this person? Report them to us!',
              );
            },
          ),
        ],
      ),
    );
  }

  // Handle favorite toggle
  void _handleFavoriteToggle(int feedbackId, bool isFavorited) {
    setState(() {
      if (isFavorited) {
        favoritedFeedbackIds.add(feedbackId);
      } else {
        favoritedFeedbackIds.remove(feedbackId);
      }
    });
  }
}
