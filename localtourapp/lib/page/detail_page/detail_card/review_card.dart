import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../../../models/places/placefeedback.dart';
import '../../../base/const.dart';
import '../../../full_media/full_feedback_media_viewer.dart';
import '../../../models/places/placefeedbackhelpful.dart';
import '../../../models/places/placefeedbackmedia.dart';
import '../../../models/users/followuser.dart';
import '../../../models/users/users.dart';
import '../../../provider/review_provider.dart';
import '../../../video_player/video_thumbnail.dart';
import '../../account/account_page.dart';

class ReviewCard extends StatefulWidget {
  final Function(int feedbackId, bool isFavorited) onFavoriteToggle;
  final User? user;
  final PlaceFeedback feedback;
  final List<PlaceFeedbackMedia> feedbackMediaList;
  final VoidCallback? onUpdate;
  final VoidCallback? onDelete;
  final VoidCallback? onReport;
  final String userId;
  final List<PlaceFeedbackHelpful> feedbackHelpfuls;
  final List<FollowUser> followUsers;
  final bool isInAllProductPage;

  const ReviewCard({
    Key? key,
    required this.user,
    required this.feedback,
    required this.feedbackMediaList,
    this.onUpdate,
    this.onDelete,
    this.onReport,
    required this.userId,
    required this.onFavoriteToggle,
    required this.feedbackHelpfuls,
    this.isInAllProductPage = false,
    required this.followUsers,
  }) : super(key: key);

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  // Check if the current feedback is marked as "favorite" or "helpful"
  bool isFavorite() {
    return widget.feedbackHelpfuls.any((helpful) =>
        helpful.placeFeedbackId == widget.feedback.placeFeedbackId &&
        helpful.userId == widget.userId);
  }

  void toggleFavorite() {
    final isCurrentlyFavorited = isFavorite();

    setState(() {
      // Call the callback to toggle favorite in the parent
      widget.onFavoriteToggle(
          widget.feedback.placeFeedbackId, !isCurrentlyFavorited);
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
    bool favoriteStatus = isFavorite();
    final mediaList = widget.feedbackMediaList;
    int helpfulCount = Provider.of<ReviewProvider>(context, listen: false)
        .getHelpfulCount(widget.feedback.placeFeedbackId);

    return Container(
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
          _buildUserInfoRow(favoriteStatus, helpfulCount),
          const SizedBox(height: 5),
          Text(
            widget.feedback.createdAt
                .toLocal()
                .toIso8601String()
                .split('T')
                .first,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 5),
          Text(widget.feedback.content ?? "No content"),
          const SizedBox(height: 10),
          if (mediaList.isNotEmpty) _buildMediaRow(mediaList),
        ],
      ),
    );
  }

  Widget _buildUserInfoRow(bool favoriteStatus, int helpfulCount) {
    final isCurrentUser = widget.feedback.userId == widget.userId;
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
                      color: index < widget.feedback.rating
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
            if (widget.isInAllProductPage &&
                widget.feedback.userId == widget.userId) ...[
              // Show favorite icon and helpful count if in AllProductPage and feedback belongs to current user
              Column(
                children: [
                  IconButton(
                    icon: Icon(
                      favoriteStatus ? Icons.favorite : Icons.favorite_border,
                      color: favoriteStatus ? Colors.red : Colors.grey,
                    ),
                    onPressed: toggleFavorite,
                  ),
                  Text(
                    helpfulCount.toString(),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ] else if (isCurrentUser) ...[
              // Show update and delete icons for the current user in other contexts
              if (widget.onUpdate != null)
                IconButton(
                  icon: const Icon(Icons.update, color: Colors.blue),
                  onPressed: widget.onUpdate,
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
                    onPressed: toggleFavorite,
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
              userId: '',
            ),
          ),
        );
      },
      child: Text(
        widget.user?.userName ?? "Anonymous",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  ImageProvider _getUserProfileImage() {
    // Provide a default image if profilePictureUrl is empty or null
    if (widget.user?.profilePictureUrl == null ||
        widget.user!.profilePictureUrl!.isEmpty) {
      return const AssetImage('assets/images/default_profile_picture.png');
    } else {
      return NetworkImage(widget.user!.profilePictureUrl!);
    }
  }

  Widget _buildMediaRow(List<PlaceFeedbackMedia> mediaList) {
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

  Widget _buildMediaThumbnail(PlaceFeedbackMedia media) {
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
    if (media.type == 'photo') {
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
