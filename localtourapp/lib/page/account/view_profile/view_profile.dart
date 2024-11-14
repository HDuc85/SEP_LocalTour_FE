// lib/pages/view_profile.dart

import 'package:flutter/material.dart';
import 'package:localtourapp/base/schedule_provider.dart';
import 'package:localtourapp/models/places/place.dart';
import 'package:localtourapp/models/places/placefeedbackmedia.dart';
import 'package:localtourapp/models/places/placetranslation.dart';
import 'package:localtourapp/models/posts/postlike.dart';
import 'package:localtourapp/models/schedule/destination.dart';
import 'package:localtourapp/models/schedule/schedule.dart';
import 'package:localtourapp/models/schedule/schedulelike.dart';
import 'package:localtourapp/models/users/followuser.dart';
import 'package:localtourapp/models/users/users.dart';
import 'package:localtourapp/page/account/review_provider.dart';
import 'package:localtourapp/page/account/user_provider.dart';
import 'package:localtourapp/page/account/users_provider.dart';
import 'package:localtourapp/page/account/view_profile/create_post.dart';
import 'package:localtourapp/page/account/view_profile/post_provider.dart';
import 'package:localtourapp/page/account/view_profile/post_tab_bar.dart';
import 'package:localtourapp/page/account/view_profile/reviewed_tab_bar.dart';
import 'package:localtourapp/page/detail_page/detail_page_tab_bars/count_provider.dart';
import 'package:localtourapp/page/planned_page/planned_page_tab_bars/schedule_tab_bar.dart';
import 'package:provider/provider.dart';
import 'package:localtourapp/models/posts/post.dart';

class ViewProfilePage extends StatefulWidget {
  final List<FollowUser> followUsers;
  final String userId;
  final List<Schedule> schedules;
  final List<Post> posts;
  final User user;

  const ViewProfilePage({
    Key? key,
    required this.followUsers,
    required this.schedules,
    required this.posts,
    required this.user,
    required this.userId,
  }) : super(key: key);

  @override
  State<ViewProfilePage> createState() => _ViewProfilePageState();
}

class _ViewProfilePageState extends State<ViewProfilePage> {
  @override
  Widget build(BuildContext context) {
    final scheduleNames = {
      for (var schedule in widget.schedules) schedule.id: schedule.scheduleName
    };
    final reviewProvider = Provider.of<ReviewProvider>(context);
    final userReviews = reviewProvider.getReviewsByUserId(widget.userId);

    final currentUserId = Provider.of<UserProvider>(context).userId;
    final bool isCurrentUser = currentUserId == widget.userId;

    final scheduleProvider = Provider.of<ScheduleProvider>(context);
    final List<Schedule> userSchedules = scheduleProvider.getSchedulesByUserId(widget.userId);
    final List<ScheduleLike> userScheduleLikes = scheduleProvider.getScheduleLikesByUserId(widget.userId);
    final List<Destination> userDestinations = scheduleProvider.getDestinationsByUserId(widget.userId);
    final List<User> allUsers = Provider.of<UsersProvider>(context).users;
    final List<Place> allPlaces = scheduleProvider.places;
    final List<PlaceTranslation> allTranslations = scheduleProvider.translations;

    // Collect all media associated with the user's reviews
    final List<PlaceFeedbackMedia> userFeedbackMedia = userReviews
        .map((feedback) => reviewProvider.getMediaByReviewId(feedback.placeFeedbackId))
        .expand((mediaList) => mediaList)
        .toList();

    // Initialize favoritedFeedbackIds (you might want to fetch this from a provider or user settings)
    List<int> favoritedFeedbackIds = [];

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.user.fullName} Profile', maxLines: 2),
      ),
      body: DefaultTabController(
        length: isCurrentUser ? 2 : 3,
        child: Column(
          children: [
            TabBar(
              tabs: [
                const Tab(text: "Posts"),
                const Tab(text: "Reviews"),
                if (!isCurrentUser) const Tab(text: "Schedules"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  PostTabBar(
                    userId: widget.userId,
                    scheduleNames: scheduleNames,
                    user: widget.user,
                    isCurrentUser: isCurrentUser,
                    onFavoriteToggle: (postId, isFavorited) {
                      final postProvider = Provider.of<PostProvider>(context, listen: false);
                      if (isFavorited) {
                        postProvider.addPostLike(PostLike(
                          id: DateTime.now().millisecondsSinceEpoch,
                          userId: widget.userId,
                          postId: postId,
                          createdDate: DateTime.now(),
                        ));
                      } else {
                        postProvider.removePostLike(postId, widget.userId);
                      }
                    },
                    onCommentPressed: () {
                      // Define the function to handle comment press action
                      // For example, navigate to a comments page or open a comments section
                    },
                    onUpdatePressed: (Post post) {
                      // Handle update press action, i.e., open CreatePostOverlay with the post
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => CreatePostOverlay(
                          userId: widget.userId,
                          placeId: post.placeId,
                          existingPost: post,
                        ),
                      );
                    },
                    onDeletePressed: (Post post) {
                      // Handle delete press action, i.e., delete the post via provider
                      Provider.of<PostProvider>(context, listen: false).deletePost(post.id);
                      Provider.of<CountProvider>(context, listen: false).decrementPostCount();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Post deleted successfully!')),
                      );
                    }, followUsers: widget.followUsers,
                  ),
                  ReviewedTabbar(
                    userId: widget.userId,
                    users: allUsers,
                    feedbackMediaList: userFeedbackMedia,
                    favoritedFeedbackIds: favoritedFeedbackIds
                  ),
                  if (!isCurrentUser)
                    ScheduleTabbar(
                      userId: widget.userId,
                      schedules: userSchedules,
                      scheduleLikes: userScheduleLikes,
                      destinations: userDestinations,
                      onFavoriteToggle: (scheduleId, isFavorited) {
                        // Handle favorite toggle
                      },
                      users: allUsers,
                      places: allPlaces,
                      translations: allTranslations,
                      isCurrentUser: false, // Indicate it's not the current user
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
