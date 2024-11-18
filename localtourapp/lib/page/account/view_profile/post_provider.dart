import 'package:flutter/material.dart';
import 'package:localtourapp/models/posts/post.dart';
import 'package:localtourapp/models/posts/postcomment.dart';
import 'package:localtourapp/models/posts/postcommentlike.dart';
import 'package:localtourapp/models/posts/postlike.dart';
import 'package:localtourapp/models/posts/postmedia.dart';

class PostProvider with ChangeNotifier {
  List<Post> _posts = [];
  List<PostComment> _comments = [];
  List<PostLike> _postLikes = [];
  List<PostCommentLike> _commentLikes = [];
  List<PostMedia> _media = [];

  // Initializing with dummy data (optional)
  PostProvider({
    List<Post>? posts,
    List<PostComment>? comments,
    List<PostLike>? postLikes,
    List<PostCommentLike>? commentLikes,
    List<PostMedia>? media,
  }) {
    _posts = posts ?? [];
    _comments = comments ?? [];
    _postLikes = postLikes ?? [];
    _commentLikes = commentLikes ?? [];
    _media = media ?? [];
  }

  bool isMediaAttached(PostMedia media) {
    return _media.any((existingMedia) => existingMedia.id == media.id);
  }

  // Getters for each list
  List<Post> get posts => _posts;
  List<PostComment> get comments => _comments;
  List<PostLike> get postLikes => _postLikes;
  List<PostCommentLike> get commentLikes => _commentLikes;
  List<PostMedia> get media => _media;

  // Post methods
  void addPost(Post post) {
    _posts.insert(0, post); // Insert at the beginning for latest first
    notifyListeners();
  }

  void updatePost(Post updatedPost) {
    int index = _posts.indexWhere((post) => post.id == updatedPost.id);
    if (index != -1) {
      _posts[index] = updatedPost;
      notifyListeners();
    }
  }

  void deletePost(int postId) {
    _posts.removeWhere((post) => post.id == postId);
    _comments.removeWhere((comment) => comment.postId == postId);
    _postLikes.removeWhere((like) => like.postId == postId);
    _media.removeWhere((media) => media.postId == postId);
    notifyListeners();
  }

  // Comment methods
  void addComment(PostComment comment) {
    _comments.add(comment);
    notifyListeners();
  }

  void deleteComment(int commentId) {
    _comments.removeWhere((comment) => comment.id == commentId);
    _commentLikes.removeWhere((like) => like.postCommentId == commentId);
    notifyListeners();
  }

  // Post Like methods
  void addPostLike(PostLike postLike) {
    // Prevent duplicate likes
    if (!_postLikes.any((like) => like.postId == postLike.postId && like.userId == postLike.userId)) {
      _postLikes.add(postLike);
      notifyListeners();
    }
  }

  void removePostLike(int postId, String userId) {
    _postLikes.removeWhere((like) => like.postId == postId && like.userId == userId);
    notifyListeners();
  }

  // Comment Like methods
  void addCommentLike(PostCommentLike like) {
    _commentLikes.add(like);
    notifyListeners();
  }

  void removeCommentLike(int commentId, String userId) {
    _commentLikes.removeWhere((like) => like.postCommentId == commentId && like.userId == userId);
    notifyListeners();
  }

  // Media methods
  void addMedia(PostMedia media) {
    _media.add(media);
    notifyListeners();
  }

  void removeMedia(int mediaId) {
    _media.removeWhere((media) => media.id == mediaId);
    notifyListeners();
  }

  // Utility methods
  List<Post> getPostsByUserId(String userId) {
    return _posts.where((post) => post.authorId == userId).toList();
  }

  List<PostComment> getCommentsForPost(int postId) {
    final postComments = _comments.where((comment) => comment.postId == postId).toList();
    return postComments;
  }

  List<PostLike> getLikesForPost(int postId) {
    return _postLikes.where((like) => like.postId == postId).toList();
  }

  List<PostCommentLike> getLikesForComment(int commentId) {
    return _commentLikes.where((like) => like.postCommentId == commentId).toList();
  }

  List<PostMedia> getMediaForPost(int postId) {
    return _media.where((media) => media.postId == postId).toList();
  }
}
