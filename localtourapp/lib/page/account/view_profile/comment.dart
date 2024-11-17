// comments_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:localtourapp/models/posts/postcommentlike.dart';
import 'package:localtourapp/models/users/users.dart';
import 'package:localtourapp/page/account/account_page.dart';
import 'package:localtourapp/provider/users_provider.dart';
import 'package:provider/provider.dart';
import 'package:localtourapp/models/posts/post.dart';
import 'package:localtourapp/models/posts/postcomment.dart';
import 'package:localtourapp/page/account/view_profile/post_provider.dart';
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
  final FocusNode _commentFocusNode = FocusNode();

  // For tracking which comment is being replied to
  int? _replyingToCommentId;

  Map<int?, List<PostComment>> commentsMap = {};

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
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // Handle scroll events if needed
  }

  void _buildCommentsMap(List<PostComment> comments) {
    commentsMap.clear();
    for (var comment in comments) {
      commentsMap.putIfAbsent(comment.parentId, () => []).add(comment);
    }
  }

  void _addComment({int? parentId}) {
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) return;

    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Obtain the current user's ID
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
    FocusScope.of(context).requestFocus(_commentFocusNode);
  }

  void _cancelReply() {
    setState(() {
      _replyingToCommentId = null;
    });
  }

  void _likeComment(int commentId) {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Obtain the current user's ID
    final currentUserId = userProvider.currentUser.userId;

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

  List<Widget> _buildComments(int? parentId, int depth) {
    List<PostComment>? commentsList = commentsMap[parentId];

    if (commentsList == null) return [];

    List<Widget> commentWidgets = [];

    for (var comment in commentsList) {
      commentWidgets.add(_buildCommentItem(comment, depth));

      // Recursively add replies to this comment
      commentWidgets.addAll(_buildComments(comment.id, depth + 1));
    }

    return commentWidgets;
  }

  void _showDeleteConfirmationDialog(int commentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              final postProvider =
                  Provider.of<PostProvider>(context, listen: false);
              final commentsToDelete =
                  postProvider.getCommentsToDelete(commentId);

              // Update the comment count for the post
              postProvider.updateCommentCount(
                  widget.post.id, -commentsToDelete.length);

              // Delete the comments
              postProvider.deleteComment(commentId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(PostComment comment, int depth) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final usersProvider = Provider.of<UsersProvider>(context, listen: false);
    final followUsersProvider =
        Provider.of<FollowUsersProvider>(context, listen: false);

    // Adjust left padding based on depth
    double leftPadding = depth * 10.0;

    final commenter = usersProvider.getUserById(comment.userId);
    if (commenter == null) {
      return const SizedBox.shrink();
    }

    final commentLikes = postProvider.getLikesForComment(comment.id);
    final currentUserId = userProvider.currentUser.userId;
    final bool hasLiked =
        commentLikes.any((like) => like.userId == currentUserId);
    final likeCount = commentLikes.length;

    // Get parent user's name if this is a reply
    String? parentUserName;
    if (comment.parentId != null) {
      final parentComment = postProvider.comments.firstWhere(
        (c) => c.id == comment.parentId,
        orElse: () => comment,
      );
      final parentUser = usersProvider.getUserById(parentComment.userId);
      parentUserName = parentUser?.userName;
    }

    return Padding(
      padding: EdgeInsets.only(left: leftPadding, top: 8.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Picture
          GestureDetector(
            onTap: () {
              final isCurrentUser =
                  userProvider.isCurrentUser(commenter.userId);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountPage(
                    user: commenter,
                    isCurrentUser: isCurrentUser,
                    followUsers: followUsersProvider.followUsers,
                  ),
                ),
              );
            },
            child: CircleAvatar(
              backgroundImage: commenter.profilePictureUrl != null
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        final isCurrentUser =
                            userProvider.isCurrentUser(commenter.userId);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AccountPage(
                              user: commenter,
                              isCurrentUser: isCurrentUser,
                              followUsers: followUsersProvider.followUsers,
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
                    // Time difference
                    Text(
                      "Time Ago",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                // Indicate if replying to someone
                if (comment.parentId != null && parentUserName != null)
                  Text(
                    'Replying to $parentUserName',
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                // Comment Content
                GestureDetector(
                  onLongPress: () {
                    if (currentUserId == comment.userId) {
                      _showDeleteConfirmationDialog(comment.id);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300], // Light grey background
                      borderRadius:
                          BorderRadius.circular(10), // Rounded corners
                    ),
                    padding: const EdgeInsets.all(5), // Padding inside the box
                    child: Text(
                      comment.content,
                      style: const TextStyle(
                          fontSize: 14), // Adjust text size as needed
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                // Action Buttons: Reply and Like
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _replyToComment(comment.id),
                      icon: const Icon(Icons.comment),
                    ),
                    IconButton(
                      icon: Icon(
                        hasLiked ? Icons.favorite : Icons.favorite_border,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);
    final usersProvider = Provider.of<UsersProvider>(context);

    final comments = postProvider.getCommentsForPost(widget.post.id);

    // Sort comments and build the comments map
    comments.sort((a, b) => a.createdDate.compareTo(b.createdDate));
    _buildCommentsMap(comments);

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
                          id: -1, // Use a unique placeholder ID
                          postId: widget.post.id, // Provide the post ID
                          parentId: null, // Indicate no parent
                          userId: '', // Use an empty string for the user ID
                          content:
                              'This comment does not exist.', // Placeholder content
                          createdDate: DateTime(0), // Placeholder date
                        ),
                      );
                      final User? parentUser;
                      parentUser =
                          usersProvider.getUserById(parentComment.userId);
                      return parentUser != null
                          ? Text(
                              'Replying to ${parentUser.userName ?? "Unknown User"}')
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
                : ListView(
                    controller: _commentsScrollController,
                    children: _buildComments(null, 0),
                  ),
          ),
          const Divider(),
          // Input Field to Add Comment
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  focusNode: _commentFocusNode,
                  decoration: InputDecoration(
                    hintText: _replyingToCommentId != null
                        ? 'Write a reply...'
                        : 'Write a comment...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  onSubmitted: (_) =>
                      _addComment(parentId: _replyingToCommentId),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.blue),
                onPressed: () => _addComment(parentId: _replyingToCommentId),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
