// comments_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localtourapp/models/posts/postcommentlike.dart';
import 'package:localtourapp/models/users/followuser.dart';
import 'package:localtourapp/page/account/account_page.dart';
import 'package:localtourapp/provider/users_provider.dart';
import 'package:provider/provider.dart';
import 'package:localtourapp/models/posts/post.dart';
import 'package:localtourapp/models/posts/postcomment.dart';
import 'package:localtourapp/page/account/view_profile/post_provider.dart';
import 'package:localtourapp/models/users/users.dart';

class CommentsBottomSheet extends StatefulWidget {
  final User? user;
  final Post post;
  final String userId;
  final List<FollowUser>followUsers;

  const CommentsBottomSheet({
    Key? key,
    required this.userId,
    required this.post,
    required this.user,
    required this.followUsers,
  }) : super(key: key);

  @override
  _CommentsBottomSheetState createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _commentsScrollController = ScrollController();

  // For tracking which comment is being replied to
  int? _replyingToCommentId;

  void _addComment({int? parentId}) {
    final String commentText = _commentController.text.trim();
    if (commentText.isEmpty) return;

    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final userProvider = Provider.of<UsersProvider>(context, listen: false);

    // Obtain the current user's ID
    final String currentUserId = 'anh-tuan-unique-id-1234';

    // Validate if the user exists
    final User? user = userProvider.getUserById(currentUserId);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not found.')),
      );
      return;
    }

    // Create a new comment
    final newComment = PostComment(
      id: DateTime.now().millisecondsSinceEpoch,
      postId: widget.post.id,
      parentId: parentId,
      userId: currentUserId,
      content: commentText,
      createdDate: DateTime.now(),
    );

    // Add the comment to the provider
    postProvider.addComment(newComment); // Ensure this triggers `notifyListeners`

    // Clear the text field and reset replying state
    _commentController.clear();
    setState(() {
      _replyingToCommentId = null;
    });

    // Scroll to the bottom to show the new comment, only after the list updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _commentsScrollController.animateTo(
        _commentsScrollController.position.maxScrollExtent + 60,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }


  void _replyToComment(int commentId) {
    setState(() {
      _replyingToCommentId = commentId;
    });
  }

  void _cancelReply() {
    setState(() {
      _replyingToCommentId = null;
    });
  }

  void _likeComment(int commentId) {
    final postProvider = Provider.of<PostProvider>(context, listen: false);

    // Obtain the current user's ID. Replace this with your actual authentication logic.
    final String currentUserId = 'anh-tuan-unique-id-1234'; // Replace with actual user ID

    // Check if the user has already liked the comment
    bool hasLiked = postProvider.getLikesForComment(commentId).any(
          (like) => like.userId == currentUserId,
    );

    if (hasLiked) {
      // Unlike the comment
      postProvider.removeCommentLike(commentId, currentUserId);
    } else {
      // Like the comment
      final newLike = PostCommentLike(
        id: DateTime.now().millisecondsSinceEpoch,
        postCommentId: commentId,
        userId: currentUserId,
        createdDate: DateTime.now(),
      );
      postProvider.addCommentLike(newLike);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Adjust the height as needed
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Header with title and close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Comments',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // If replying to a comment, show a banner
          if (_replyingToCommentId != null)
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.grey[300],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Consumer<PostProvider>(
                    builder: (context, postProvider, _) {
                      final parentComment = postProvider.comments.firstWhere(
                              (comment) => comment.id == _replyingToCommentId!,
                          orElse: () => PostComment(
                            id: 0,
                            postId: widget.post.id,
                            parentId: null,
                            userId: '',
                            content: '',
                            createdDate: DateTime.now(),
                          ));
                      final user = Provider.of<UsersProvider>(context, listen: false)
                          .getUserById(parentComment.userId);
                      return user != null
                          ? GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AccountPage(
                                  user: widget.user!,
                                  isCurrentUser: widget.user!.userId == widget.userId,
                                  followUsers: widget.followUsers, // Replace with actual followUsers list if needed
                                ),
                              ),
                            );
                          },
                          child: Text('Replying to ${user.userName}'))
                          : const Text('Replying to Unknown User');
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _cancelReply,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          // Comments List
          Expanded(
            child: Consumer<PostProvider>(
              builder: (context, postProvider, _) {
                final List<PostComment> comments =
                postProvider.getCommentsForPost(widget.post.id);

                if (comments.isEmpty) {
                  return const Center(
                    child: Text(
                      'No comments yet. Be the first to comment!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                // Filter top-level comments (parentId == null)
                final topLevelComments = comments.where((comment) => comment.parentId == null).toList();

                return ListView.builder(
                  controller: _commentsScrollController,
                  itemCount: topLevelComments.length,
                  itemBuilder: (context, index) {
                    final PostComment comment = topLevelComments[index];
                    final User? commenter = Provider.of<UsersProvider>(context).getUserById(comment.userId);

                    if (commenter == null) {
                      return const SizedBox.shrink(); // Skip if user not found
                    }

                    // Fetch replies to this comment
                    final List<PostComment> replies =
                    comments.where((c) => c.parentId == comment.id).toList();

                    final List<PostCommentLike> commentLikes =
                    postProvider.getLikesForComment(comment.id);

                    // Obtain current user ID
                    final String currentUserId = 'anh-tuan-unique-id-1234'; // Replace with actual logic

                    bool hasLiked =
                    commentLikes.any((like) => like.userId == currentUserId);

                    int likeCount = commentLikes.length;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Profile Picture
                              CircleAvatar(
                                backgroundImage:
                                NetworkImage(commenter.profilePictureUrl!),
                              ),
                              const SizedBox(width: 10),
                              // Comment Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Username and Timestamp
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          commenter.userName!,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          DateFormat('MM/dd/yyyy, hh:mm a')
                                              .format(comment.createdDate),
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Text(comment.content),
                                    const SizedBox(height: 5),
                                    // Action Buttons: Reply and Like
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: () => _replyToComment(comment.id),
                                          icon: Icon(Icons.comment),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            hasLiked
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: Colors.red,
                                          ),
                                          onPressed: () => _likeComment(comment.id),
                                        ),
                                        Text('$likeCount'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          // Display Replies
                          if (replies.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 40.0, top: 5.0),
                              child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: replies.length,
                                itemBuilder: (context, replyIndex) {
                                  final PostComment reply = replies[replyIndex];
                                  final User? replier =
                                  Provider.of<UsersProvider>(context)
                                      .getUserById(reply.userId);

                                  if (replier == null) {
                                    return const SizedBox.shrink();
                                  }

                                  final List<PostCommentLike> replyLikes =
                                  postProvider.getLikesForComment(reply.id);

                                  bool hasLikedReply = replyLikes
                                      .any((like) => like.userId == currentUserId);

                                  int replyLikeCount = replyLikes.length;

                                  // Get parent comment's userName
                                  PostComment? parentComment;
                                  try {
                                    parentComment = postProvider.comments.firstWhere(
                                            (comment) => comment.id == reply.parentId);
                                  } catch (e) {
                                    parentComment = null;
                                  }

                                  final String? parentUserName = parentComment != null
                                      ? Provider.of<UsersProvider>(context, listen: false)
                                      .getUserById(parentComment.userId)
                                      ?.userName
                                      : null;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          backgroundImage:
                                          NetworkImage(replier.profilePictureUrl!),
                                          radius: 12,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    replier.userName!,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    DateFormat('MM/dd/yyyy, hh:mm a')
                                                        .format(reply.createdDate),
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 5),
                                              if (parentUserName != null)
                                                Text(
                                                  'Reply to $parentUserName',
                                                  style: const TextStyle(
                                                    fontStyle: FontStyle.italic,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              if (parentUserName != null)
                                                const SizedBox(height: 5),
                                              Text(reply.content),
                                              const SizedBox(height: 5),
                                              Row(
                                                children: [
                                                  IconButton(
                                                    onPressed: () => _replyToComment(reply.id),
                                                    icon: Icon(Icons.comment),
                                                  ),
                                                  IconButton(
                                                    icon: Icon(
                                                      hasLikedReply
                                                          ? Icons.favorite
                                                          : Icons.favorite_border,
                                                      color: Colors.red,
                                                      size: 18,
                                                    ),
                                                    onPressed: () => _likeComment(reply.id),
                                                  ),
                                                  Text('$replyLikeCount'),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(),
          // Input Field to Add Comment
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: _replyingToCommentId != null
                        ? 'Write a reply...'
                        : 'Write a comment...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  onSubmitted: (_) => _addComment(
                      parentId: _replyingToCommentId), // Pass parentId if replying
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.blue),
                onPressed: () => _addComment(
                    parentId: _replyingToCommentId), // Pass parentId if replying
              ),
            ],
          ),
        ],
      ),
    );
  }
}
