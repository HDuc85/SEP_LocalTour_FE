import 'dart:io';
import 'package:flutter/material.dart';
import 'package:localtourapp/models/media_model.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../../../models/places/placefeedback.dart';
import '../../../base/const.dart';
import '../../../full_media/full_feedback_media_viewer.dart';
import '../../../models/feedback/feedback_model.dart';
import '../../../models/places/placefeedbackhelpful.dart';
import '../../../models/places/placefeedbackmedia.dart';
import '../../../models/users/followuser.dart';
import '../../../models/users/users.dart';
import '../../../provider/review_provider.dart';
import '../../../services/review_service.dart';
import '../../../video_player/video_thumbnail.dart';
import '../../account/account_page.dart';
import '../detail_page_tab_bars/form/review_dialog.dart';

class ReviewCard extends StatefulWidget {
  final FeedBackModel feedBackCard;
  final int placeId;
  final VoidCallback? onUpdate;
  final VoidCallback? onDelete;
  final VoidCallback? onReport;
  final String userId;

  const ReviewCard({
    Key? key,
    required this.placeId,
    required this.feedBackCard,
    this.onUpdate,
    this.onDelete,
    this.onReport,
    required this.userId,
  }) : super(key: key);

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  final ReviewService _reviewService = ReviewService();
  late FeedBackModel feedBackCard;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchdata();
  }
  void fetchdata(){
    setState(() {
      feedBackCard = widget.feedBackCard;
      isLoading =false;
    });
  }

  Future<void> onFavoriteToggle(int feedbackId) async{
    var success = await _reviewService.LikeFeedback(widget.placeId, feedbackId);
    if(success){
      var (listDate,totalReview) = await _reviewService.getFeedback(widget.placeId);
      var feedback = listDate.firstWhere((element) => element.id == widget.feedBackCard.id,);
      setState(() {
        feedBackCard  = feedback;
      });
    }

  }

  Future<void> onUpdateTogget(int feedbackId) async{

      var (listDate,totalReview) = await _reviewService.getFeedback(widget.placeId);
      var feedback = listDate.firstWhere((element) => element.id == widget.feedBackCard.id,);
      setState(() {
        feedBackCard  = feedback;
      });


  }


  Future<void> _confirmDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Review'),
          content: const Text('Are you sure you want to delete this review?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      widget.onDelete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {


    return isLoading ? Center(child: CircularProgressIndicator()) :

      Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info and actions
          _buildUserInfoRow(feedBackCard.isLiked, feedBackCard.totalLike),
          const SizedBox(height: 5),
          Text(
            feedBackCard.updateDate?.toLocal()
                .toIso8601String()
                .split('T')
                .first ?? feedBackCard.createDate.toLocal()
                .toIso8601String()
                .split('T')
                .first,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 5),
          Text(feedBackCard.content ?? "No content"),
          const SizedBox(height: 10),
          if (feedBackCard.placeFeedbackMedia.isNotEmpty) _buildMediaRow(feedBackCard.placeFeedbackMedia),
        ],
      ),
    );
  }
  void addOrUpdateUserReview(int rating, String content, List<File> images, List<File> videos,[int? feedbackId]) async {
    List<File> combinedList = [];
    combinedList.addAll(images);
    combinedList.addAll(videos);

    String result = '';

      result = await _reviewService.UpdateFeedback(
          widget.placeId, rating, feedbackId!, content, combinedList);


    if (result != 'Success') {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ));
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your review has been added/updated.')));
    }
    onUpdateTogget(feedbackId);
  }


    Widget _buildUserInfoRow(bool favoriteStatus, int helpfulCount) {
    final isCurrentUser = feedBackCard.userId == widget.userId;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // User info and rating
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: _getUserProfileImage(),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserName(),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      Icons.star,
                      color: index < feedBackCard.rating
                          ? Constants.starColor
                          : Colors.grey,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        // Action buttons
        Row(
          children: [
            if (isCurrentUser) ...[
              // Show favorite icon and helpful count if in AllProductPage and feedback belongs to current user
              Column(
                children: [
                  IconButton(
                    icon: Icon(
                      favoriteStatus ? Icons.favorite : Icons.favorite_border,
                      color: favoriteStatus ? Colors.red : Colors.grey,
                    ),
                    onPressed: () {
                      onFavoriteToggle(feedBackCard.id);
                    },
                  ),
                  Text(
                    helpfulCount.toString(),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
              if (isCurrentUser) ...[
              // Show update and delete icons for the current user in other contexts
              if (widget.onUpdate != null)
                IconButton(
                  icon: const Icon(Icons.update, color: Colors.blue),
                  onPressed:  () {
                    final parentContext = context;
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ReviewDialog(
                          initialRating: feedBackCard.rating,
                          initialContent: feedBackCard.content?? '',
                          initialMedia: feedBackCard.placeFeedbackMedia,
                          onSubmit: (int rating, String content,
                              List<File> images, List<File> videos) {
                            if (true) {
                              addOrUpdateUserReview(rating, content, images, videos,feedBackCard.id);
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

                ),
              if (widget.onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: _confirmDelete,
                ),
            ] else ...[
              // Show report and favorite icons for other users' feedbacks
              Column(
                children: [
                  IconButton(
                    icon: Icon(
                      favoriteStatus ? Icons.favorite : Icons.favorite_border,
                      color: favoriteStatus ? Colors.red : Colors.grey,
                    ),
                    onPressed: () {
                      onFavoriteToggle(feedBackCard.id);
                    },
                  ),
                  Text(
                    helpfulCount.toString(),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              if (widget.onReport != null)
                IconButton(
                  icon: const Icon(Icons.flag, color: Colors.grey),
                  onPressed: widget.onReport,
                ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildUserName() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AccountPage(
              userId: feedBackCard.userId,
            ),
          ),
        );
      },
      child: Text(
        feedBackCard.userName ?? "Anonymous",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  ImageProvider _getUserProfileImage() {
    // Provide a default image if profilePictureUrl is empty or null
    if (feedBackCard.profileUrl == null ||
        feedBackCard.profileUrl.isEmpty) {
      return const AssetImage('assets/images/default_profile_picture.png');
    } else {
      return NetworkImage(feedBackCard.profileUrl);
    }
  }

  Widget _buildMediaRow(List<MediaModel> mediaList) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: mediaList.map((media) {
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: GestureDetector(
              onTap: () {
                if (media.url.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullFeedbackMediaViewer(
                        feedbackMediaList: mediaList,
                        initialIndex: mediaList.indexOf(media),
                      ),
                    ),
                  );
                }
              },
              child: _buildMediaThumbnail(media),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMediaThumbnail(MediaModel media) {
    // If the media URL is empty or not valid, return a placeholder
    if (media.url.isEmpty) {
      return Image.asset(
        'assets/images/placeholder.png',
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      );
    }

    // If media is a photo
    if (media.type == 'Image') {
      if (media.url.startsWith('http')) {
        return Image.network(
          media.url,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/images/placeholder.png',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            );
          },
        );
      } else {
        // Attempt to load from file if the URL is a local path
        final file = File(media.url);
        if (file.existsSync()) {
          return Image.file(
            file,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          );
        } else {
          // File does not exist, show placeholder
          return Image.asset(
            'assets/images/placeholder.png',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          );
        }
      }
    } else {
      // If media is a video, display video thumbnail
      return VideoThumbnail(videoPath: media.url);
    }
  }
}
