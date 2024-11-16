// lib/widgets/reviewed_tabbar.dart


import 'package:flutter/material.dart';
import 'package:localtourapp/base/back_to_top_button.dart';
import 'package:localtourapp/base/weather_icon_button.dart';
import 'package:localtourapp/models/places/placefeedback.dart';
import 'package:localtourapp/models/places/placefeedbackhelpful.dart';
import 'package:localtourapp/models/places/placefeedbackmedia.dart';
import 'package:localtourapp/models/users/users.dart';
import 'package:localtourapp/page/detail_page/detail_page.dart';
import 'package:localtourapp/provider/review_provider.dart';
import 'package:localtourapp/provider/user_provider.dart';
import 'package:localtourapp/page/detail_page/detail_card/review_card.dart';
import 'package:localtourapp/provider/count_provider.dart';
import 'package:provider/provider.dart';

import '../../../provider/place_provider.dart';

class ReviewedTabbar extends StatefulWidget {
  final List<int> favoritedFeedbackIds;
  final String userId;
  final List<User> users;
  final List<PlaceFeedbackMedia> feedbackMediaList;

  const ReviewedTabbar({
    Key? key,
    required this.favoritedFeedbackIds,
    required this.userId,
    required this.users,
    required this.feedbackMediaList,
  }) : super(key: key);

  @override
  State<ReviewedTabbar> createState() => _ReviewedTabbarState();
}

class _ReviewedTabbarState extends State<ReviewedTabbar> {
  bool _showBackToTopButton = false;
  final ScrollController _scrollController = ScrollController();
  List<PlaceFeedback> userFeedbacks = [];
  List<PlaceFeedbackHelpful> feedbackHelpfuls = [];
  late int totalReviews;
  late bool isCurrentUserViewing;

  @override
  void initState() {
    super.initState();
    // Check if the current user is viewing their own reviews
    isCurrentUserViewing = widget.userId == Provider.of<UserProvider>(context, listen: false).currentUser!.userId;

    // Fetch reviews specific to the userId
    userFeedbacks = Provider.of<ReviewProvider>(context, listen: false).getReviewsByUserId(widget.userId);
    totalReviews = userFeedbacks.length;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CountProvider>(context, listen: false).setReviewCount(totalReviews);
    });

    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.offset >= 200 && !_showBackToTopButton) {
      setState(() {
        _showBackToTopButton = true;
      });
    } else if (_scrollController.offset < 200 && _showBackToTopButton) {
      setState(() {
        _showBackToTopButton = false;
      });
    }
  }

  // Function to navigate to the Weather page
  void _navigateToWeatherPage() {
    Navigator.pushNamed(context, '/weather');
  }

  // Function to scroll back to the top
  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reviewProvider = Provider.of<ReviewProvider>(context);
    final placeProvider = Provider.of<PlaceProvider>(context);
    userFeedbacks = reviewProvider.getReviewsByUserId(widget.userId);

    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
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
                    Text("Total Reviews: $totalReviews", style: const TextStyle(fontSize: 15)),
                  ],
                ),
              ),
              // Display user reviews
              ...userFeedbacks.map((feedback) {
                final user = widget.users.firstWhere(
                      (user) => user.userId == feedback.userId,
                  orElse: () => User(
                    userId: 'default',
                    userName: 'Unknown User',
                    fullName: 'Unknown User',
                    emailConfirmed: false,
                    phoneNumberConfirmed: false,
                    dateCreated: DateTime.now(),
                    dateUpdated: DateTime.now(),
                    reportTimes: 0,
                    profilePictureUrl: '',
                  ),
                );

                final feedbackMediaList = widget.feedbackMediaList
                    .where((media) => media.feedbackId == feedback.placeFeedbackId)
                    .toList();

                final relevantHelpfuls = feedbackHelpfuls
                    .where((helpful) => helpful.placeFeedbackId == feedback.placeFeedbackId)
                    .toList();

                final placeName = placeProvider.getPlaceName(
                  feedback.placeId,
                  Localizations.localeOf(context).languageCode,
                );
                print('Feedback ID: ${feedback.placeFeedbackId}, Place ID: ${feedback.placeId}, Place Name: $placeName');

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Navigate to ReviewTabbar with the selected placeId
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailPage(
                              placeId: feedback.placeId,
                              userId: widget.userId,
                              placeName: placeName,
                              mediaList: [],
                              languageCode: 'en',
                            ),
                          ),
                        );
                      },
                      child: ReviewCard(
                        user: user,
                        feedback: feedback,
                        feedbackMediaList: feedbackMediaList,
                        feedbackHelpfuls: relevantHelpfuls,
                        userId: widget.userId,
                        followUsers: [],
                      ),
                    ),
                    // Display the place name below the ReviewCard
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                      child: Text(
                        placeName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const Divider(
                      thickness: 1,
                      color: Colors.black,
                      indent: 16,
                      endIndent: 16,
                    ),
                  ],
                );
              }).toList(),
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
        Positioned(
          bottom: 12,
          left: 110,
          child: AnimatedOpacity(
            opacity: _showBackToTopButton ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: _showBackToTopButton
                ? BackToTopButton(
              onPressed: _scrollToTop,
            )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

}


