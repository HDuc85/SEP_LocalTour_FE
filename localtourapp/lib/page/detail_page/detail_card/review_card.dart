import 'dart:io';
import 'package:flutter/material.dart';
import 'package:localtourapp/models/media_model.dart';
import '../../../base/const.dart';
import '../../../config/appConfig.dart';
import '../../../config/secure_storage_helper.dart';
import '../../../full_media/full_feedback_media_viewer.dart';
import '../../../models/feedback/feedback_model.dart';
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
  String _languageCode = '';
  final ReviewService _reviewService = ReviewService();
  late FeedBackModel feedBackCard;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchdata();
  }
  Future<void> fetchdata() async {
    var languageCode = await SecureStorageHelper().readValue(AppConfig.language);
    setState(() {
      feedBackCard = widget.feedBackCard;
      isLoading =false;
      _languageCode = languageCode!;
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
          title: Text(_languageCode == 'vi' ? 'Xóa đánh giá':'Delete Review'),
          content: Text(_languageCode == 'vi' ? 'Bạn có muốn xóa đánh giá này không?':'Are you sure you want to delete this review?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(_languageCode == 'vi' ? 'Không':'No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(_languageCode == 'vi' ? 'Có':'Yes'),
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


    return isLoading ? const Center(child: CircularProgressIndicator()) :

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
          Text(feedBackCard.content ),
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
          SnackBar(content: Text(_languageCode == 'vi' ? 'Đánh giá của bạn đã được cập nhật':'Your review has been updated.')));
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
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ReviewDialog(
                          initialRating: feedBackCard.rating,
                          initialContent: feedBackCard.content,
                          initialMedia: feedBackCard.placeFeedbackMedia,
                          onSubmit: (int rating, String content, List<File> images, List<File> videos) {
                            addOrUpdateUserReview(rating, content, images, videos, feedBackCard.id);
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
        feedBackCard.userName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  ImageProvider _getUserProfileImage() {
    if (feedBackCard.profileUrl.isEmpty) {
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
        'assets/images/image_placeholder.png',
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      );
    }

    // Determine if the media is an image or video by checking the file extension
    final fileExtension = media.url.split('.').last.toLowerCase();
    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp'];

    // If it's an image
    if (imageExtensions.contains(fileExtension)) {
      if (media.url.startsWith('http')) {
        // Load network image
        return Image.network(
          media.url,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/images/image_placeholder.png',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            );
          },
        );
      } else {
        // Load local image file
        final file = File(media.url);
        if (file.existsSync()) {
          return Image.file(
            file,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          );
        } else {
          return Image.asset(
            'assets/images/image_placeholder.png',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          );
        }
      }
    } else {
      // Assume it's a video
      return VideoThumbnail(videoPath: media.url);
    }
  }
}
