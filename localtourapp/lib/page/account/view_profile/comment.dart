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

import '../../../provider/follow_users_provider.dart';
import '../../../provider/user_provider.dart';

class CommentsBottomSheet extends StatefulWidget {
  final Post post;
  final String userId;

  const CommentsBottomSheet({
    Key? key,
    required this.userId,
    required this.post,
  }) : super(key: key);

  @override
  _CommentsBottomSheetState createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _commentsScrollController = ScrollController();

  // For tracking which comment is being replied to
  int? _replyingToCommentId;

  @override
  void initState() {
    super.initState();
    _commentsScrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _commentsScrollController.removeListener(_scrollListener);
    _commentsScrollController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // Handle scroll events if needed
  }

  void _addComment({int? parentId}) {
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) return;

    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Obtain the current user's ID (from the UserProvider)
    final currentUserId = userProvider.currentUser.userId;

    // Validate if the user exists
    final user = Provider.of<UsersProvider>(context, listen: false)
        .getUserById(currentUserId);
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
    postProvider.addComment(newComment);

    // Clear the text field and reset replying state
    _commentController.clear();
    setState(() {
      _replyingToCommentId = null;
    });

    // Scroll to the bottom to show the new comment, after the list updates
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
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Obtain the current user's ID from the UserProvider
    final currentUserId = userProvider.currentUser?.userId;

    // Check if the user has already liked the comment
    bool hasLiked = postProvider.getLikesForComment(commentId).any(
          (like) => like.userId == currentUserId,
        );

    if (hasLiked) {
      // Unlike the comment
      postProvider.removeCommentLike(commentId, currentUserId!);
    } else {
      // Like the comment
      final newLike = PostCommentLike(
        id: DateTime.now().millisecondsSinceEpoch,
        postCommentId: commentId,
        userId: currentUserId!,
        createdDate: DateTime.now(),
      );
      postProvider.addCommentLike(newLike);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final postProvider = Provider.of<PostProvider>(context);
    final usersProvider = Provider.of<UsersProvider>(context);
    final followUsersProvider =
        Provider.of<FollowUsersProvider>(context, listen: false);

    final comments = postProvider.getCommentsForPost(widget.post.id);

    // Flatten comments and sort by createdDate
    comments.sort((a, b) => a.createdDate.compareTo(b.createdDate));

    return Container(
      height: MediaQuery.of(context).size.height * 1,
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
          // Banner if replying to a comment
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
                        ),
                      );
                      final parentUser =
                          usersProvider.getUserById(parentComment.userId);
                      return parentUser != null
                          ? GestureDetector(
                              onTap: () {
                                final isCurrentUser = userProvider
                                    .isCurrentUser(parentUser.userId);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AccountPage(
                                      user: parentUser,
                                      isCurrentUser: isCurrentUser,
                                      followUsers:
                                          followUsersProvider.followUsers,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                  'Replying to ${parentUser.userName ?? "Unknown User"}'),
                            )
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
            child: comments.isEmpty
                ? const Center(
                    child: Text(
                      'No comments yet. Be the first to comment!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    controller: _commentsScrollController,
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      final commenter =
                          usersProvider.getUserById(comment.userId);

                      if (commenter == null) {
                        return const SizedBox
                            .shrink(); // Skip if user not found
                      }

                      final commentLikes =
                          postProvider.getLikesForComment(comment.id);
                      final currentUserId = userProvider.currentUser!.userId;
                      final bool hasLiked;
                      hasLiked = commentLikes
                          .any((like) => like.userId == currentUserId);
                                          final likeCount = commentLikes.length;

                      // Determine if this comment is a reply by checking parentId
                      String? parentUserName;
                      if (comment.parentId != null) {
                        final parentComment = postProvider.comments.firstWhere(
                          (c) => c.id == comment.parentId,
                          orElse: () => PostComment(
                            id: 0,
                            postId: comment.postId,
                            parentId: null,
                            userId: '',
                            content: '',
                            createdDate: DateTime.now(),
                          ),
                        );
                        final parentUser =
                            usersProvider.getUserById(parentComment.userId);
                        parentUserName = parentUser?.userName;
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Profile Picture
                            GestureDetector(
                              onTap: () {
                                final isCurrentUser = userProvider
                                    .isCurrentUser(commenter.userId);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AccountPage(
                                      user: commenter,
                                      isCurrentUser: isCurrentUser,
                                      followUsers:
                                          followUsersProvider.followUsers,
                                    ),
                                  ),
                                );
                              },
                              child: CircleAvatar(
                                backgroundImage: commenter.profilePictureUrl !=
                                        null
                                    ? NetworkImage(commenter.profilePictureUrl!)
                                    : null,
                                child: commenter.profilePictureUrl == null
                                    ? const Icon(Icons.account_circle,
                                        size: 40, color: Colors.grey)
                                    : null,
                              ),
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
                                      GestureDetector(
                                        onTap: () {
                                          final isCurrentUser = userProvider
                                              .isCurrentUser(commenter.userId);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AccountPage(
                                                user: commenter,
                                                isCurrentUser: isCurrentUser,
                                                followUsers: followUsersProvider
                                                    .followUsers,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          commenter.userName ?? "Unknown User",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
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
                                  if (comment.parentId != null &&
                                      parentUserName != null)
                                    Text(
                                      'Reply to $parentUserName',
                                      style: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  if (comment.parentId != null &&
                                      parentUserName != null)
                                    const SizedBox(height: 5),
                                  // Comment Content
                                  Text(comment.content),
                                  const SizedBox(height: 5),
                                  // Action Buttons: Reply and Like
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () =>
                                            _replyToComment(comment.id),
                                        icon: const Icon(Icons.comment),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          hasLiked
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: Colors.red,
                                        ),
                                        onPressed: () =>
                                            _likeComment(comment.id),
                                      ),
                                      Text('$likeCount'),
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
                      parentId:
                          _replyingToCommentId), // Pass parentId if replying
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.blue),
                onPressed: () => _addComment(
                    parentId:
                        _replyingToCommentId), // Pass parentId if replying
              ),
            ],
          ),
        ],
      ),
    );
  }
}
