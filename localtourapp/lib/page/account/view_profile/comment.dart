// comments_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:localtourapp/config/appConfig.dart';
import 'package:localtourapp/config/secure_storage_helper.dart';
import 'package:localtourapp/models/posts/comment_model.dart';
import 'package:localtourapp/models/posts/post_model.dart';
import 'package:localtourapp/page/account/account_page.dart';
import 'package:localtourapp/services/post_service.dart';
import 'package:localtourapp/models/posts/postcomment.dart';

class CommentsBottomSheet extends StatefulWidget {
  final PostModel post;

  const CommentsBottomSheet({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  _CommentsBottomSheetState createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final PostService _postService = PostService();
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _commentsScrollController = ScrollController();
  final FocusNode _commentFocusNode = FocusNode();
  late List<CommentModel> _listComment;
  late String _userId;
  late String languageCode;
  // For tracking which comment is being replied to
  int? _replyingToCommentId;
  bool isLoading = true;
  Map<int?, List<PostComment>> commentsMap = {};

  @override
  void initState() {
    super.initState();
    _commentsScrollController.addListener(_scrollListener);
    fetchDataInit();
  }

  Future<void> fetchDataInit() async{
    var (post, listcomment) = await _postService.GetPostDetail(widget.post.id);
    var userid = await SecureStorageHelper().readValue(AppConfig.userId);
    var language = await SecureStorageHelper().readValue(AppConfig.language);
    if(language != null){
      languageCode = language;
    }

    if(userid != null){
      _userId = userid;
    }

    setState(() {
        _listComment = listcomment;
        isLoading = false;
      });
  }

  Future<void> fetchData() async{
    var (post, listcomment) = await _postService.GetPostDetail(widget.post.id);
    setState(() {
      _listComment = listcomment;
    });
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


  void _addComment({int? parentId}) async {
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) return;

    var result = await _postService.CreateComment(widget.post.id, parentId, commentText);
    if(result){
      fetchData();
    }

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

  String formatTimeAgo(DateTime pastTime) {
    final now = DateTime.now();
    final difference = now.difference(pastTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${languageCode == 'vi'? 'phút trước':(difference.inMinutes > 1?'minutes':'minute')}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${languageCode == 'vi'? 'tiếng trước': (difference.inHours > 1?'hours':'hour')}';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} ${languageCode == 'vi'? 'ngày trước': (difference.inDays > 1?'days':'day')}';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).round()} ${languageCode == 'vi'? 'tháng trước': ((difference.inDays / 30).round() > 1?'months':'month')}';
    } else {
      return '${(difference.inDays / 365).round()} ${languageCode == 'vi'? 'năm trước': ((difference.inDays / 30).round() > 1?'years':'year')}';
    }
  }

  Future<void> _likeComment(int commentId) async {
  var result = await _postService.LikeComment(commentId);
  if(result){
    fetchData();
  }
    // Obtain the current user's ID

  }

  List<Widget> _buildComments(int? parentId, int depth, [List<CommentModel>? list]) {

    List<CommentModel> commentsList = [];

    if(parentId != null){
      if(list!.length > 0){
        commentsList = list;
      }
    }else if(parentId == null){
      commentsList = _listComment;
    }

    if (commentsList.length == 0) return [];


    List<Widget> commentWidgets = [];

    for (var comment in commentsList) {
      commentWidgets.add(_buildCommentItem(comment, depth));

      // Recursively add replies to this comment
      commentWidgets.addAll(_buildComments(comment.id, depth + 1,comment.childComments));
    }

    return commentWidgets;
  }

  void _showDeleteConfirmationDialog(int commentId)  {
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
            onPressed: () async {
              Navigator.of(context).pop(); // Close the dialog

              var result = await _postService.DeleteComment(commentId);
              if(result ){
                fetchData();
              }

            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(CommentModel comment, int depth) {
    // Adjust left padding based on depth
    double leftPadding = depth * 30.0;

    final bool hasLiked = comment.likedByUser;

    final likeCount = comment.totalLikes;

    // Get parent user's name if this is a reply
    String? parentUserName;
    if (comment.parentId != null) {
      final parentComment = _listComment.firstWhere(
        (c) => c.id == comment.parentId,
        orElse: () => comment,
      );
      parentUserName = parentComment.userFullName;
    }

    return Padding(
      padding: EdgeInsets.only(left: leftPadding, top: 8.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Picture
          GestureDetector(
            onTap: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountPage(
                    userId: comment.userId,
                  ),
                ),
              );
            },
            child: CircleAvatar(
              backgroundImage: comment.userProfilePictureUrl != null
                  ? NetworkImage(comment.userProfilePictureUrl!)
                  : null,
              child: comment.userProfilePictureUrl == null
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

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AccountPage(
                              userId: comment.userId,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        comment.userFullName ?? "Unknown User",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Time difference
                    Text(
                      formatTimeAgo(comment.createdDate),
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
                    if (_userId == comment.userId) {
                      _showDeleteConfirmationDialog(comment.id);
                    }
                  },
                  child: Container(
                    constraints: BoxConstraints(
                      minWidth: 130.0,
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
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

    return
      isLoading ? const Center(child: CircularProgressIndicator()) :
      Container(
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
            child: _listComment.isEmpty
                ?
            const Center(
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
