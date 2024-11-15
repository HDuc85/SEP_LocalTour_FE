import 'dart:io';
import 'package:flutter/material.dart';
import 'package:localtourapp/models/users/userreport.dart';
import 'package:localtourapp/provider/follow_users_provider.dart';
import 'package:localtourapp/base/weather_icon_button.dart';
import 'package:localtourapp/provider/review_provider.dart';
import 'package:localtourapp/provider/user_provider.dart';
import 'package:localtourapp/provider/users_provider.dart';
import 'package:provider/provider.dart';
import '../../../models/users/users.dart';
import '../detail_card/review_card_list.dart';
import '../detail_card/review_card.dart';
import '../../../models/places/placefeedback.dart';
import '../../../models/places/placefeedbackhelpful.dart';
import '../../../models/places/placefeedbackmedia.dart';
import '../all_reviews_page.dart';
import '../../../provider/count_provider.dart';
import 'form/reportform.dart';
import 'form/review_dialog.dart';
import '../../../base/place_score_manager.dart';
import 'package:collection/collection.dart';

class ReviewTabbar extends StatefulWidget {
  final int placeId;
  final String userId;

  const ReviewTabbar({
    super.key,
    required this.placeId,
    required this.userId,
  });

  @override
  State<ReviewTabbar> createState() => _ReviewTabbarState();
}

class _ReviewTabbarState extends State<ReviewTabbar> {
  bool showAllReviews = false;
  late int totalReviewers;

  void _navigateToWeatherPage() {
    Navigator.pushNamed(context, '/weather');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Calculate the initial score after the widget builds
      _updatePlaceScore();
    });
  }

  /// Update the place score and total reviewers count in PlaceScoreManager.
  void _updatePlaceScore() {
    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
    final placeFeedbacks = reviewProvider.getReviewsByPlaceId(widget.placeId);

    final double score = calculateScore(placeFeedbacks);
    totalReviewers = placeFeedbacks.length;

    PlaceScoreManager.instance.setScore(widget.placeId, score);
    PlaceScoreManager.instance.setReviewCount(widget.placeId, totalReviewers);
  }

  /// Method to add or update a user's review using the ReviewProvider.
  void addOrUpdateUserReview(
      int rating, String content, List<File> images, List<File> videos) {
    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);

    // If there's an existing review by this user for this place, update it; otherwise, add a new one.
    final existingReview = reviewProvider.getReviewsByUserIdAndPlaceId(
        widget.userId, widget.placeId);
    final reviewId = existingReview.isNotEmpty
        ? existingReview.first.placeFeedbackId
        : reviewProvider.placeFeedbacks.length + 1;

    final newReview = PlaceFeedback(
      placeFeedbackId: reviewId,
      placeId: widget.placeId,
      userId: widget.userId,
      rating: rating.toDouble(),
      content: content,
      createdAt: DateTime.now(),
    );

    reviewProvider.addOrUpdateReview(
      newReview,
      Provider.of<CountProvider>(context, listen: false),
    );

    // Remove any existing media entries for this review before adding new user-added media
    reviewProvider.getMediaByReviewId(reviewId).forEach((existingMedia) {
      reviewProvider.removeReviewMedia(existingMedia.id);
    });

    // Add images
    for (var image in images) {
      reviewProvider.addReviewMedia(
        PlaceFeedbackMedia(
          id: reviewProvider.placeFeedbackMedia.length + 1,
          feedbackId: reviewId,
          type: 'photo',
          url: image.path,
          createDate: DateTime.now(),
        ),
      );
    }

    // Add videos
    for (var video in videos) {
      reviewProvider.addReviewMedia(
        PlaceFeedbackMedia(
          id: reviewProvider.placeFeedbackMedia.length + 1,
          feedbackId: reviewId,
          type: 'video',
          url: video.path,
          createDate: DateTime.now(),
        ),
      );
    }

    // After adding/updating the review:
    _updatePlaceScore();

    // Show a SnackBar or any relevant UI feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Your review has been added/updated.')),
    );
  }

  /// Method to delete a user's review from ReviewProvider.
  void deleteUserReview() {
    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
    final userReview = reviewProvider
        .getReviewsByUserIdAndPlaceId(widget.userId, widget.placeId)
        .firstOrNull;
    if (userReview != null) {
      reviewProvider.removeReviewByFeedbackId(userReview.placeFeedbackId, Provider.of<CountProvider>(context, listen: false),);
    }

    Provider.of<CountProvider>(context, listen: false).decrementReviewCount();
    _updatePlaceScore();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Your review has been deleted.')),
    );
  }


  /// Check if the user has already reviewed this place.
  bool hasUserReviewed() {
    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
    final userReviews = reviewProvider.getReviewsByUserIdAndPlaceId(
        widget.userId, widget.placeId);
    return userReviews.isNotEmpty;
  }

  User getUserDetails(String userId) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.currentUser.userId == userId) {
      return userProvider.currentUser;
    }
    // If not current user, either retrieve from user list or return a default
    // For demonstration, returning a default user
    return User(
      userId: 'default',
      userName: 'Unknown User',
      emailConfirmed: false,
      phoneNumberConfirmed: false,
      dateCreated: DateTime.now(),
      dateUpdated: DateTime.now(),
      reportTimes: 0,
    );
  }

  /// Calculate the average score for the place based on its feedbacks.
  double calculateScore(List<PlaceFeedback> placeFeedbacks) {
    if (placeFeedbacks.isEmpty) return 0.0; // Avoid division by zero

    int totalStars = placeFeedbacks.fold(
      0,
          (sum, feedback) => sum + feedback.rating.toInt(),
    );
    return totalStars / placeFeedbacks.length; // Calculate average as a double
  }

  /// Utility method to compare two lists of Files (by path).
  bool _areListsEqual(List<File> list1, List<File> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].path != list2[i].path) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final reviewProvider = Provider.of<ReviewProvider>(context);
    final followUsersProvider = Provider.of<FollowUsersProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final usersProvider = Provider.of<UsersProvider>(context, listen: false);
    final placeFeedbacks = reviewProvider.getReviewsByPlaceId(widget.placeId);
    final feedbackMediaList = reviewProvider.getMediaByPlaceId(widget.placeId);
    final double score = calculateScore(placeFeedbacks);
    totalReviewers = placeFeedbacks.length;
    final bool userHasReviewed = hasUserReviewed();

    // Get current user's review
    final userReview = reviewProvider
        .getReviewsByUserIdAndPlaceId(widget.userId, widget.placeId)
        .firstOrNull;

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

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
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
                    buildStarRating(score),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AllReviewsPage(
                              feedbacks: reviewProvider.placeFeedbacks,
                              users: usersProvider.users, // You can pass the list of users if needed
                              feedbackMediaList:
                              reviewProvider.placeFeedbackMedia,
                              placeId: widget.placeId,
                              userId: widget.userId,
                              totalReviews: placeFeedbacks.length,
                              feedbackHelpfuls: reviewProvider.placeFeedbackHelpful,
                              followUsers: followUsersProvider.followUsers,
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
                  margin:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
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
                          getUserDetails(widget.userId).profilePictureUrl ?? '',
                        ),
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
                                  addOrUpdateUserReview(
                                      rating, content, images, videos);
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
              if (userHasReviewed && userReview != null)
                ReviewCard(
                  userId: widget.userId,
                  user: getUserDetails(userReview.userId),
                  feedback: userReview,
                  feedbackMediaList: reviewProvider
                      .getMediaByReviewId(userReview.placeFeedbackId),
                  onFavoriteToggle: (feedbackId, isFavorited) {
                    Provider.of<ReviewProvider>(context, listen: false)
                        .toggleFavorite(feedbackId, widget.userId);
                    setState(() {});
                  },
                  feedbackHelpfuls: reviewProvider
                      .getHelpfulsByFeedbackId(userReview.placeFeedbackId),
                  onUpdate: () {
                    final parentContext = context;
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        final existingImages = reviewProvider
                            .getMediaByReviewId(userReview.placeFeedbackId)
                            .where((media) => media.type == 'photo')
                            .map((media) => File(media.url))
                            .toList();
                        final existingVideos = reviewProvider
                            .getMediaByReviewId(userReview.placeFeedbackId)
                            .where((media) => media.type == 'video')
                            .map((media) => File(media.url))
                            .toList();
                        return ReviewDialog(
                          initialRating: userReview.rating.toInt(),
                          initialContent: userReview.content ?? '',
                          initialImages: existingImages,
                          initialVideos: existingVideos,
                          onSubmit: (int rating, String content,
                              List<File> images, List<File> videos) {
                            if (rating != userReview.rating.toInt() ||
                                content != userReview.content ||
                                !_areListsEqual(images, existingImages) ||
                                !_areListsEqual(videos, existingVideos)) {
                              addOrUpdateUserReview(
                                  rating, content, images, videos);
                              ScaffoldMessenger.of(parentContext).showSnackBar(
                                const SnackBar(
                                    content:
                                    Text('Your review has been updated.')),
                              );
                            } else {
                              ScaffoldMessenger.of(parentContext).showSnackBar(
                                const SnackBar(
                                    content:
                                    Text('You have not changed anything.')),
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                  onDelete: deleteUserReview,
                  // Updated onReport callback to open the report form and use UserProvider to record a new user report.
                  onReport: () {
                    ReportForm.show(
                      context,
                      'Have a problem with this person? Please report them to us.',
                      onSubmit: (reportMessage) {
                        userProvider.addUserReport(
                          UserReport(
                            id: userProvider.userReport.length +
                                1, // Example ID generation
                            userId: userReview
                                .userId, // Storing the reported user's ID
                            reportDate: DateTime.now(), // Current date
                            status:
                            reportMessage, // Storing the report message in 'status'
                          ),
                        );
                        Navigator.of(context).pop(); // Close the dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Your report has been submitted.')),
                        );
                      },
                    );
                  },
                  followUsers:
                  followUsersProvider.getFollowers(userReview.userId),
                  isInAllProductPage: false,
                ),
              ReviewCardList(
                feedbacks: otherUserReviews,
                users: usersProvider.users, // Provide a list of users if needed
                feedbackMediaList: feedbackMediaList,
                userId: widget.userId,
                onFavoriteToggle: (feedbackId, isFavorited) {
                  Provider.of<ReviewProvider>(context, listen: false)
                      .toggleFavorite(feedbackId, widget.userId);
                  setState(() {});
                },
                feedbackHelpfuls: reviewProvider
                    .placeFeedbackHelpful, // You can filter as needed
                limit: 2,
                onSeeAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllReviewsPage(
                        feedbacks: reviewProvider.placeFeedbacks,
                        users: usersProvider.users, // Provide a list of users if needed
                        feedbackMediaList: reviewProvider.placeFeedbackMedia,
                        placeId: widget.placeId,
                        userId: widget.userId,
                        feedbackHelpfuls: reviewProvider.placeFeedbackHelpful,
                        totalReviews: otherUserReviews.length,
                        followUsers: followUsersProvider.followUsers,
                      ),
                    ),
                  );
                },
                // Updated onReport callback for other user reviews
                onReport: (feedback) {
                  ReportForm.show(
                    context,
                    'Have a problem with this person’s feedback? Please report it to us.',
                    onSubmit: (reportMessage) {
                      userProvider.addUserReport(
                        UserReport(
                          id: userProvider.userReport.length +
                              1, // Example ID generation
                          userId:
                          feedback.userId, // Storing the reported user's ID
                          reportDate: DateTime.now(),
                          status:
                          reportMessage, // Storing the report message in 'status'
                        ),
                      );
                      Navigator.of(context).pop(); // Close the dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Your report has been submitted.')),
                      );
                    },
                  );
                },
                followUsers: followUsersProvider.followUsers, // Provide actual data if needed
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 10,
          left: 40,
          child: WeatherIconButton(
            onPressed: _navigateToWeatherPage,
            assetPath: 'assets/icons/weather.png',
          ),
        ),
      ],
    );
  }

  Widget buildStarRating(double score) {
    int fullStars = score.floor(); // Full stars
    bool hasHalfStar =
        (score - fullStars) >= 0.5; // Determine if there's a half-star

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return const Icon(Icons.star, color: Colors.red, size: 20);
        } else if (index == fullStars && hasHalfStar) {
          return const Icon(Icons.star_half, color: Colors.red, size: 20);
        } else {
          return const Icon(Icons.star_border, color: Colors.red, size: 20);
        }
      }),
    );
  }
}

