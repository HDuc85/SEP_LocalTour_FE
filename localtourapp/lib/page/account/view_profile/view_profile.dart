import 'package:flutter/material.dart';
import 'package:localtourapp/config/appConfig.dart';
import 'package:localtourapp/config/secure_storage_helper.dart';
import 'package:localtourapp/models/posts/post_model.dart';
import 'package:localtourapp/models/users/userProfile.dart';
import 'package:localtourapp/provider/schedule_provider.dart';
import 'package:localtourapp/models/places/place.dart';
import 'package:localtourapp/models/places/placefeedbackmedia.dart';
import 'package:localtourapp/models/places/placetranslation.dart';
import 'package:localtourapp/models/posts/postlike.dart';
import 'package:localtourapp/models/schedule/destination.dart';
import 'package:localtourapp/models/schedule/schedule.dart';
import 'package:localtourapp/models/schedule/schedulelike.dart';
import 'package:localtourapp/models/users/followuser.dart';
import 'package:localtourapp/models/users/users.dart';
import 'package:localtourapp/provider/review_provider.dart';
import 'package:localtourapp/provider/user_provider.dart';
import 'package:localtourapp/provider/users_provider.dart';
import 'package:localtourapp/page/account/view_profile/create_post.dart';
import 'package:localtourapp/page/account/view_profile/post_provider.dart';
import 'package:localtourapp/page/account/view_profile/post_tab_bar.dart';
import 'package:localtourapp/page/account/view_profile/reviewed_tab_bar.dart';
import 'package:localtourapp/provider/count_provider.dart';
import 'package:localtourapp/page/planned_page/planned_page_tab_bars/schedule_tab_bar.dart';
import 'package:provider/provider.dart';
import 'package:localtourapp/models/posts/post.dart';

class ViewProfilePage extends StatefulWidget {
  final List<FollowUser> followUsers;
  final String userId;
  final List<Schedule> schedules;
  final List<Post> posts;
  final Userprofile user;

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

  bool isCurrentUserId = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetch();
  }

  Future<void> fetch() async{
    String? myUserId = await SecureStorageHelper().readValue(AppConfig.userId);
    if(myUserId != null){
      if(myUserId == widget.userId){
        setState(() {
          isCurrentUserId = true;
        });
      }

    }

  }

  @override
  Widget build(BuildContext context) {
    final scheduleNames = {
      for (var schedule in widget.schedules) schedule.id: schedule.scheduleName
    };
    final reviewProvider = Provider.of<ReviewProvider>(context);
    final userReviews = reviewProvider.getReviewsByUserId(widget.userId);


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
        length: isCurrentUserId ? 2 : 3,
        child: Column(
          children: [
            TabBar(
              tabs: [
                const Tab(text: "Posts"),
                const Tab(text: "Reviews"),
                if (!isCurrentUserId) const Tab(text: "Schedules"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  PostTabBar(
                    userId: widget.userId,
                    scheduleNames: scheduleNames,
                    user: widget.user,
                    isCurrentUser: isCurrentUserId,
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
                    onUpdatePressed: (PostModel post) {
                      // Handle update press action, i.e., open CreatePostOverlay with the post
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => CreatePostOverlay(
                          existingPost: post,
                        ),
                      );
                    },
                    onDeletePressed: (PostModel post) {

                    }, followUsers: widget.followUsers,
                  ),
                  ReviewedTabbar(
                      userId: widget.userId,
                      users: allUsers,
                      feedbackMediaList: userFeedbackMedia,
                      favoritedFeedbackIds: favoritedFeedbackIds
                  ),
                  if (!isCurrentUserId)
                    ScheduleTabbar(
                      userId: widget.userId,
                      schedules: userSchedules,
                      scheduleLikes: userScheduleLikes,
                      destinations: userDestinations,
                      onFavoriteToggle: (scheduleId, isFavorited) {
                        // Handle favorite toggle
                        final scheduleProvider = Provider.of<ScheduleProvider>(context, listen: false);
                        if (isFavorited) {
                          scheduleProvider.addScheduleLike(ScheduleLike(
                            id: DateTime.now().millisecondsSinceEpoch,
                            userId: widget.userId,
                            scheduleId: scheduleId,
                            createdDate: DateTime.now(),
                          ));
                        } else {
                          scheduleProvider.removeScheduleLike(scheduleId, widget.userId);
                        }
                      },
                      users: allUsers,
                      places: allPlaces,
                      translations: allTranslations,
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