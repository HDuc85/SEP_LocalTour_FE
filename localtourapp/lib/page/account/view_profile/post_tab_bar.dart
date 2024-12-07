// post_tab_bar.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localtourapp/base/back_to_top_button.dart';
import 'package:localtourapp/config/appConfig.dart';
import 'package:localtourapp/config/secure_storage_helper.dart';
import 'package:localtourapp/models/media_model.dart';
import 'package:localtourapp/models/posts/post_model.dart';
import 'package:localtourapp/models/users/userProfile.dart';
import 'package:localtourapp/base/weather_icon_button.dart';
import 'package:localtourapp/full_media/full_screen_post_media_viewer.dart';
import 'package:localtourapp/page/account/view_profile/comment.dart';
import 'package:localtourapp/page/account/view_profile/create_post.dart';
import 'package:localtourapp/services/post_service.dart';
import 'package:localtourapp/video_player/video_thumbnail.dart';

import '../../detail_page/detail_page_tab_bars/form/reportform.dart';

class PostTabBar extends StatefulWidget {
  final String userId;
  final Userprofile user;
  final bool isCurrentUser;
  const PostTabBar({
    Key? key,
    required this.userId,
    required this.user,
    required this.isCurrentUser,
  }) : super(key: key);

  @override
  State<PostTabBar> createState() => _PostTabBarState();
}

class _PostTabBarState extends State<PostTabBar> {
  final ScrollController _scrollController = ScrollController();
  final PostService _postService = PostService();
  bool _showBackToTopButton = false;
  DateTime? _fromDate;
  DateTime? _toDate;
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  Map<int, bool> postVisibility = {};
  Map<int, bool> expandedPosts = {}; // Tracks expansion state per post
  late List<PostModel> listPost;
  late List<PostModel> initListPost;
  bool isLoading = true;
  bool isLogin = false;
  bool isCurrentUser = false;
  String _languageCode = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    fetchDate();
  }

  Future<void> fetchDate() async {
    var languageCode =
        await SecureStorageHelper().readValue(AppConfig.language);
    var result = await _postService.getListPost(widget.userId);
    var userId = await SecureStorageHelper().readValue(AppConfig.userId);

    if (userId != null) {
      isLogin = true;
    }
    if (isLogin = true) {
      isCurrentUser = userId == widget.userId;
    }
    setState(() {
      listPost = result;
      initListPost = result;
      isLoading = false;
      _languageCode = languageCode!;
    });
  }

  Future<void> SearchEvent() async {
    var searchList = initListPost;
    if (searchController.text != '') {
      String searchTxt = searchController.text;
      searchList = searchList
          .where(
            (element) =>
                element.title.toLowerCase().contains(searchTxt.toLowerCase()) ||
                element.scheduleName!
                    .toLowerCase()
                    .contains(searchTxt.toLowerCase()) ||
                element.placeName!
                    .toLowerCase()
                    .contains(searchTxt.toLowerCase()),
          )
          .toList();
    }
    if (_fromDate != null) {
      searchList = searchList
          .where(
            (element) => element.createdDate!.isAfter(_fromDate!),
          )
          .toList();
    }
    if (_toDate != null) {
      searchList = searchList
          .where(
            (element) => element.createdDate!.isBefore(_toDate!),
          )
          .toList();
    }

    setState(() {
      listPost = searchList;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    searchFocusNode.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _toggleVisibility(
      int postId, bool ispublic, String tilte, String content) async {
    var result =
        await _postService.UpdatePostStatus(postId, !ispublic, tilte, content);
    fetchDate();
    }

  Future<void> _deletePost(int postId) async {
    var result = await _postService.DeletePost(postId);
    if (result) {
      fetchDate();
    }
  }

  void toggleLike(int postId) async {
    var result = await _postService.LikePost(postId);
    if (result) {
      fetchDate();
    }
  }

  void _scrollListener() {
    if (_scrollController.offset >= 200 && !_showBackToTopButton) {
      setState(() {
        _showBackToTopButton = true;
      });
    } else if (_scrollController.offset < 200 && _showBackToTopButton) {
      setState(() {
        _showBackToTopButton = false;
      });
    }
  }

  void _onDateSelected(DateTime? newDate, bool isFromDate) {
    setState(() {
      if (isFromDate) {
        _fromDate = newDate;
      } else {
        _toDate = newDate;
      }
    });
  }

  void _confirmDeletePost(PostModel post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_languageCode == 'vi' ? 'Xóa bài' : 'Delete Post'),
        content: Text(_languageCode == 'vi'
            ? 'Bạn có chắc chắn muốn xóa bài viết này không?'
            : 'Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(_languageCode == 'vi' ? 'Thoát' : 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deletePost(post.id); // Pass the post to the callback
              Navigator.of(context).pop(); // Close the dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(_languageCode == 'vi'
                        ? 'Bài đã xóa thành công'
                        : 'Post deleted successfully!')),
              );
            },
            child: Text(_languageCode == 'vi' ? 'Xóa' : 'Delete'),
          ),
        ],
      ),
    );
  }

  void _openCommentsBottomSheet(PostModel post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CommentsBottomSheet(
        post: post,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Stack(
            children: [
              GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount:
                      4 + (listPost.isNotEmpty ? listPost.length : 1) + 2,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildFilterSection();
                    } else if (index == 1) {
                      return const SizedBox(height: 10);
                    } else if (index == 2 && isCurrentUser) {
                      return Column(
                        children: [
                          const Divider(
                            color: Colors.grey, // Divider color
                            thickness: 1, // Divider thickness
                          ),
                          _buildButtonsSection(),
                        ],
                      );
                    } else if (index == 3) {
                      return const SizedBox(height: 10);
                    } else if (index <=
                        3 + (listPost.isNotEmpty ? listPost.length : 1)) {
                      if (listPost.isNotEmpty) {
                        final post = listPost[index - 4];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: _buildSinglePostItem(post),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Center(
                            child: Text(
                              _languageCode == 'vi'
                                  ? 'Không tìm thấy bài nào'
                                  : "No posts found",
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.grey),
                            ),
                          ),
                        );
                      }
                    } else {
                      return const SizedBox(height: 50);
                    }
                  },
                ),
              ),
              Positioned(
                bottom: 10,
                left: 55,
                child: WeatherIconButton(
                  onPressed: _navigateToWeatherPage,
                  assetPath: 'assets/icons/weather.png',
                ),
              ),
              Positioned(
                bottom: 50,
                left: 110,
                child: AnimatedOpacity(
                  opacity: _showBackToTopButton ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: _showBackToTopButton
                      ? BackToTopButton(
                          onPressed: _scrollToTop,
                          languageCode: 'vi',
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          );
  }

  Widget _buildFilterSection() {
    return Column(
      children: [
        const SizedBox(height: 10),
        SizedBox(
          height: 40,
          width: 330,
          child: TextField(
            controller: searchController,
            focusNode: searchFocusNode,
            decoration: InputDecoration(
              labelText: _languageCode == 'vi'
                  ? 'Tìm kiếm theo tiêu đề, lịch trình, tên địa điểm, ...'
                  : "Search by title, schedule, place name, ...",
              border: const OutlineInputBorder(),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        setState(() {});
                        SearchEvent();
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDateField(
              _languageCode == 'vi' ? 'Từ ngày' : "From Date",
              true,
              _fromDate,
              (newDate) {
                _onDateSelected(newDate, true);
              },
              clearable: true,
              onClear: () {
                _onDateSelected(null, true);
                SearchEvent();
              },
            ),
            const SizedBox(width: 5),
            _buildDateField(
              _languageCode == 'vi' ? 'Đến ngày' : "To Date",
              false,
              _toDate,
              (newDate) {
                _onDateSelected(newDate, false);
              },
              clearable: true,
              onClear: () {
                _onDateSelected(null, false);
                SearchEvent();
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            SearchEvent();

            return;
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDCA1A1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.black, width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 142, vertical: 10),
          ),
          child: Text(
            _languageCode == 'vi' ? 'Tìm kếm' : "Search",
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(
    String labelText,
    bool isFromDate,
    DateTime? initialDate,
    Function(DateTime) onDateChanged, {
    bool clearable = false,
    VoidCallback? onClear,
  }) {
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: initialDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          onDateChanged(picked);
          SearchEvent();
        }
      },
      child: Stack(
        children: [
          AbsorbPointer(
            child: SizedBox(
              height: 30,
              width: 160,
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: initialDate != null
                      ? DateFormat('yyyy-MM-dd').format(initialDate)
                      : labelText,
                  hintStyle: const TextStyle(fontSize: 12),
                  border: const OutlineInputBorder(),
                  suffixIcon:
                      (initialDate == null) ? const Icon(Icons.calendar_today) : null,
                ),
              ),
            ),
          ),
          if (clearable && initialDate != null)
            Positioned(
              right: 5,
              top: 5,
              child: GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close, size: 18, color: Colors.grey[600]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildButtonsSection() {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      SizedBox(
        height: 40,
        width: 150,
        child: ElevatedButton.icon(
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => CreatePostOverlay(
              callback: () {},
            ),
          ).then(
            (value) {
              fetchDate();
            },
          ),
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            _languageCode == 'vi' ? 'Thêm bài' : "Add Post",
            style: const TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      const SizedBox(
        width: 15,
      )
    ]);
  }

  Widget _buildSinglePostItem(PostModel post) {
    bool isExpandedLocal = expandedPosts[post.id] ?? false;
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(10), // Optional: rounded corners
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          // User Information Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(widget.user.userProfileImage),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.user.userName,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(DateFormat('MM/dd/yyyy').format(post.createdDate!)),
                    ],
                  ),
                ],
              ),
                  if (widget.isCurrentUser) ...[
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            post.isPublic ? Icons.public : Icons.lock,
                            color: Colors.green,
                          ),
                          onPressed: () => _toggleVisibility(
                              post.id, post.isPublic, post.title, post.content),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) => CreatePostOverlay(
                                existingPost: post,
                                callback: () {},
                              ),
                            ).then((value) {
                              fetchDate();
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () => _confirmDeletePost(post),
                        ),
                      ],
                    ),
                  ],
                  if (!widget.isCurrentUser) ...[
                    IconButton(
                      icon: const Icon(
                        Icons.report,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        ReportForm.show(
                          context,
                          _languageCode != 'vi'
                              ? 'Report this post if it violates community guidelines.'
                              : 'Báo cáo bài viết này nếu vi phạm nguyên tắc cộng đồng.',
                          post.authorId, // Pass the userId for reporting
                          post.placeId, // Pass placeId if applicable
                          _languageCode,
                          onSubmit: (String message) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  _languageCode != 'vi'
                                      ? 'Report submitted successfully.'
                                      : 'Báo cáo đã được gửi thành công.',
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
            ],
          ),
          post.scheduleId != null
              ? // Schedule name
              Text(
                  post.scheduleName!,
                  maxLines: 2,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                )
              : const SizedBox(),
          post.placeId != null
              ? Row(
                  children: [
                    Expanded(
                      child: Text(
                        post.placeName!,
                        maxLines: 2,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Image.network(
                      post.placePhotoDisplay!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    )
                  ],
                )
              : const SizedBox(),
          const SizedBox(height: 10),
          // Post Content with See More/See Less
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.content.length > 1000 && !isExpandedLocal
                    ? '${post.content.substring(0, 1000)}...'
                    : post.content,
              ),
              if (post.content.length > 1000)
                TextButton(
                  onPressed: () {
                    setState(() {
                      expandedPosts[post.id] = !isExpandedLocal;
                    });
                  },
                  child: Text(_languageCode == 'vi'
                      ? (isExpandedLocal ? 'Ít hơn' : 'Nhiều hơn')
                      : (isExpandedLocal ? 'See less' : 'See more...')),
                ),
            ],
          ),

          const SizedBox(height: 10),

          // Media List
          if (post.media.isNotEmpty) _buildMediaList(post.media),

          const SizedBox(height: 10),

          // Like, Comment Counts Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.red),
                  Text('${post.totalLikes}'),
                ],
              ),
              Text(_languageCode == 'vi'
                  ? '${post.totalComments} bình luận${post.totalComments != 1 ? 's' : ''}'
                  : '${post.totalComments} comment${post.totalComments != 1 ? 's' : ''}'),
            ],
          ),
          const Divider(),

          // Interactive Buttons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFFFDD0), // Favorite background color
                ),
                child: TextButton.icon(
                  onPressed: () => toggleLike(post.id),
                  icon: Icon(
                    post.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                  ),
                  label: Text(
                    _languageCode == 'vi' ? 'Thích' : 'Loved',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF9DC183), // Comment background color
                ),
                child: TextButton.icon(
                  onPressed: () => _openCommentsBottomSheet(post),
                  icon: const Icon(
                    Icons.comment,
                    color: Color(0xFF008080),
                  ),
                  label: Text(
                    _languageCode == 'vi'
                        ? '${post.totalComments} Bình Luận${post.totalComments != 1 ? 's' : ''}'
                        : '${post.totalComments} Comment${post.totalComments != 1 ? 's' : ''}',
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMediaList(List<MediaModel> mediaForPost) {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: mediaForPost.length > 6 ? 6 : mediaForPost.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullScreenPostMediaViewer(
                      postMediaList: mediaForPost,
                      initialIndex: index,
                    ),
                  ),
                );
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  mediaForPost[index].type == 'Image'
                      ? Image(
                          image: mediaForPost[index].url.startsWith('http')
                              ? NetworkImage(mediaForPost[index].url)
                              : FileImage(File(mediaForPost[index].url))
                                  as ImageProvider,
                          fit: BoxFit.cover,
                        )
                      : VideoThumbnail(videoPath: mediaForPost[index].url),
                  if (index == 5 && mediaForPost.length > 6)
                    Container(
                      color: Colors.black54,
                      child: Center(
                        child: Text(
                          _languageCode == 'vi' ? 'xem thêm' : 'See more',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _navigateToWeatherPage() {
    Navigator.pushNamed(context, '/weather');
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}
