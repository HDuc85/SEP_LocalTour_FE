import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../../models/places/placefeedback.dart';
import '../../../fullmedia/fullfeedbackmediaviewer.dart';
import '../../../models/places/placefeedbackhelpful.dart';
import '../../../models/places/placefeeedbackmedia.dart';
import '../../../models/users/users.dart';
import '../../../video_player/video_thumbnail.dart';

class ReviewCard extends StatefulWidget {
  final List<int> favoritedFeedbackIds;
  final Function(int feedbackId, bool isFavorited) onFavoriteToggle;
  final User? user;
  final PlaceFeedback feedback;
  final List<PlaceFeedbackMedia> feedbackMediaList;
  final VoidCallback? onUpdate;
  final VoidCallback? onDelete;
  final VoidCallback? onReport;
  final String userId;
  final List<PlaceFeedbackHelpful> feedbackHelpfuls;
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
    required this.favoritedFeedbackIds,
    required this.onFavoriteToggle,
    required this.feedbackHelpfuls,
    this.isInAllProductPage = false,
  }) : super(key: key);

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  final List<PlaceFeedbackHelpful> feedbackHelpfuls = [];
  final uuid = const Uuid();

  bool isFavorite() {
    return widget.favoritedFeedbackIds.contains(widget.feedback.placeFeedbackId);
  }

  void toggleFavorite() {
    final isCurrentlyFavorited = isFavorite();

    setState(() {
      widget.onFavoriteToggle(widget.feedback.placeFeedbackId, !isCurrentlyFavorited);
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
    int helpfulCount = widget.feedbackHelpfuls.where((helpful) => helpful.placeFeedbackId == widget.feedback.placeFeedbackId).length;

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
          // Rest of your code remains the same
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // User info and rating
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(widget.user?.profilePictureUrl ?? ''),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.user?.userName ?? "Anonymous",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: List.generate(
                          5,
                              (index) => Icon(
                            Icons.star,
                            color: index < widget.feedback.rating
                                ? Colors.pinkAccent
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
                  if (widget.isInAllProductPage && widget.feedback.userId == widget.userId) ...[
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
                  ] else if (widget.feedback.userId == widget.userId) ...[
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
                    if (widget.onReport != null)
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
          ),
          const SizedBox(height: 5),
          Text(
            widget.feedback.createdDate.toLocal().toIso8601String().split('T').first,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 5),
          Text(widget.feedback.content ?? "No content"),
          const SizedBox(height: 10),
          if (mediaList.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: mediaList.map((media) {
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullFeedbackMediaViewer(
                                  feedbackMediaList: mediaList,
                                  initialIndex: mediaList.indexOf(media),
                                ),
                              ),
                            );
                          },
                          child: media.type == 'photo'
                              ? Image(
                            image: media.url.startsWith('http')
                                ? NetworkImage(media.url)
                                : FileImage(File(media.url)) as ImageProvider,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                              : VideoThumbnail(videoPath: media.url),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
