// post_tab_bar.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localtourapp/base/back_to_top_button.dart';
import 'package:localtourapp/provider/place_provider.dart';
import 'package:localtourapp/provider/schedule_provider.dart';
import 'package:localtourapp/base/weather_icon_button.dart';
import 'package:localtourapp/full_media/full_screen_post_media_viewer.dart';
import 'package:localtourapp/models/users/followuser.dart';
import 'package:localtourapp/page/account/view_profile/comment.dart';
import 'package:localtourapp/page/account/view_profile/create_post.dart';
import 'package:localtourapp/provider/count_provider.dart';
import 'package:localtourapp/video_player/video_thumbnail.dart';
import 'package:provider/provider.dart';
import 'package:localtourapp/models/posts/post.dart';
import 'package:localtourapp/models/posts/postmedia.dart';
import 'package:localtourapp/models/posts/postlike.dart';
import 'package:localtourapp/models/users/users.dart';
import 'package:localtourapp/models/schedule/schedule.dart';
import 'package:localtourapp/page/account/view_profile/post_provider.dart';

class PostTabBar extends StatefulWidget {
  final List<FollowUser>followUsers;
  final String userId;
  final Map<int, String>? scheduleNames;
  final User user;
  final bool isCurrentUser;
  final Function(int postId, bool isFavorited) onFavoriteToggle;
  final Function() onCommentPressed;
  final Function(Post post) onUpdatePressed; // Accepts Post
  final Function(Post post) onDeletePressed; // Accepts Post

  const PostTabBar({
    Key? key,
    required this.followUsers,
    required this.userId,
    required this.user,
    this.scheduleNames,
    required this.isCurrentUser,
    required this.onFavoriteToggle,
    required this.onCommentPressed,
    required this.onUpdatePressed,
    required this.onDeletePressed,
  }) : super(key: key);

  @override
  State<PostTabBar> createState() => _PostTabBarState();
}

class _PostTabBarState extends State<PostTabBar> {
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;
  DateTime? _fromDate;
  DateTime? _toDate;
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  Map<int, bool> postVisibility = {};
  Map<int, bool> expandedPosts = {}; // Tracks expansion state per post

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    searchFocusNode.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _toggleVisibility(int postId) {
    setState(() {
      postVisibility[postId] = !(postVisibility[postId] ?? true);
    });
  }

  void toggleLike(int postId) {
    final postProvider = Provider.of<PostProvider>(context, listen: false);

    bool isCurrentlyFavorited = postProvider.postLikes.any(
          (like) => like.postId == postId && like.userId == widget.user.userId,
    );

    // Invoke the callback to update the provider
    widget.onFavoriteToggle(postId, !isCurrentlyFavorited);
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

  List<Post> getFilteredPosts(List<Post> userPosts) {
    String searchText = searchController.text.toLowerCase();

    return userPosts.where((post) {
      // Match title
      final matchesTitle = post.title.toLowerCase().contains(searchText);

      // Match schedule name
      final scheduleName = widget.scheduleNames?[post.scheduleId] ?? '';
      final matchesScheduleName =
      scheduleName.toLowerCase().contains(searchText);

      // Match place name
      final placeName = post.placeId != null
          ? Provider.of<ScheduleProvider>(context, listen: false)
          .getPlaceName(post.placeId!, Localizations.localeOf(context).languageCode)
          : '';
      final matchesPlaceName = placeName.toLowerCase().contains(searchText);

      // Match date filter by createdAt
      final matchesDate =
          (_fromDate == null || post.createdAt.isAfter(_fromDate!)) &&
              (_toDate == null || post.createdAt.isBefore(_toDate!));

      // Combine all filters
      return (matchesTitle || matchesScheduleName || matchesPlaceName) &&
          matchesDate;
    }).toList();
  }

  void _confirmDeletePost(Post post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.onDeletePressed(post); // Pass the post to the callback
              Navigator.of(context).pop(); // Close the dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Post deleted successfully!')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _openCommentsBottomSheet(Post post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CommentsBottomSheet(post: post, userId: widget.userId, user: widget.user, followUsers: widget.followUsers,),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PostProvider>(
      builder: (context, postProvider, _) {
        final List<Post> userPosts = postProvider.getPostsByUserId(widget.userId);
        final List<Post> filteredPosts = getFilteredPosts(userPosts);

        // Initialize or update postVisibility and expandedPosts if necessary
        for (var post in userPosts) {
          postVisibility.putIfAbsent(post.id, () => true);
          expandedPosts.putIfAbsent(post.id, () => false); // Initialize as not expanded
        }
        Provider.of<CountProvider>(context, listen: false)
            .setPostCount(userPosts.length);

        return Stack(
          children: [
            GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: ListView.builder(
                controller: _scrollController,
                itemCount:
                4 + (filteredPosts.isNotEmpty ? filteredPosts.length : 1) + 2,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildFilterSection();
                  } else if (index == 1) {
                    return const SizedBox(height: 10);
                  } else if (index == 2) {
                    return _buildButtonsSection();
                  } else if (index == 3) {
                    return const SizedBox(height: 10);
                  } else if (index <=
                      3 + (filteredPosts.isNotEmpty ? filteredPosts.length : 1)) {
                    if (filteredPosts.isNotEmpty) {
                      final post = filteredPosts[index - 4];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: _buildSinglePostItem(post),
                      );
                    } else {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Center(
                          child: Text(
                            "No posts found",
                            style: TextStyle(fontSize: 18, color: Colors.grey),
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
                )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterSection() {
    return Column(
      children: [
        const SizedBox(height: 10),
        SizedBox(
          height: 40,
          width: 250,
          child: TextField(
            controller: searchController,
            focusNode: searchFocusNode,
            decoration: const InputDecoration(
              labelText: "Search by title, schedule, placeName",
              border: OutlineInputBorder(),
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
              "From Date",
              true,
              _fromDate,
                  (newDate) {
                _onDateSelected(newDate, true);
              },
              clearable: true,
              onClear: () {
                _onDateSelected(null, true);
              },
            ),
            const SizedBox(width: 5),
            _buildDateField(
              "To Date",
              false,
              _toDate,
                  (newDate) {
                _onDateSelected(newDate, false);
              },
              clearable: true,
              onClear: () {
                _onDateSelected(null, false);
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            if ((_fromDate != null && _toDate == null) ||
                (_fromDate == null && _toDate != null)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Please choose both "From Date" and "To Date" for filtering.'),
                ),
              );
              return;
            }
            setState(() {});
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDCA1A1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Colors.black, width: 2),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
          ),
          child: const Text(
            "Search",
            style: TextStyle(
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
                  suffixIcon: const Icon(Icons.calendar_today),
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
    return Center(
      child: SizedBox(
        height: 40,
        width: 150,
        child: ElevatedButton.icon(
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => CreatePostOverlay(
              userId: widget.userId,
            ),
          ),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text("Add Post"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSinglePostItem(Post post) {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    bool isVisible = postVisibility[post.id] ?? true;
    // Fetch media specific to this post from PostProvider
    List<PostMedia> mediaForPost = postProvider.getMediaForPost(post.id);

    final scheduleProvider =
    Provider.of<ScheduleProvider>(context, listen: false);
    final photoDisplay = post.placeId != null
        ? scheduleProvider.getPhotoDisplay(post.placeId!)
        : 'assets/images/default_image.png';

    // Get the scheduleName by finding the corresponding schedule
    final scheduleName = post.scheduleId != null
        ? scheduleProvider.getScheduleById(post.scheduleId!)
        ?.scheduleName ??
        'Unknown Schedule'
        : 'Unknown Schedule';

    final String currentLanguageCode =
        Localizations.localeOf(context).languageCode;

    final placeName = post.placeId != null
        ? scheduleProvider.getPlaceName(post.placeId!, currentLanguageCode)
        : 'Unknown Place';

    final likes = postProvider.getLikesForPost(post.id).length;
    bool isLiked = postProvider.postLikes.any(
            (like) => like.postId == post.id && like.userId == widget.user.userId);
    int likeCount = likes;

    final int commentCount = postProvider.getCommentsForPost(post.id).length;

    bool isExpandedLocal = expandedPosts[post.id] ?? false;

    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1),
        borderRadius:
        BorderRadius.circular(10), // Optional: rounded corners
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
                    backgroundImage: NetworkImage(
                        widget.user.profilePictureUrl ??
                            'https://example.com/default.jpg'),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.user.userName ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(DateFormat('MM/dd/yyyy').format(post.createdAt)),
                    ],
                  ),
                ],
              ),
              if (widget.isCurrentUser) ...[
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isVisible ? Icons.public : Icons.lock,
                        color: Colors.white,
                      ),
                      onPressed: () => _toggleVisibility(post.id),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => widget.onUpdatePressed(post),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _confirmDeletePost(post),
                    ),
                  ],
                ),
              ],
            ],
          ),
          // Schedule name
          Text(
            scheduleName,
            maxLines: 2,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  placeName,
                  maxLines: 2,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Image.network(
                photoDisplay,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              )
            ],
          ),
          const SizedBox(height: 10),
          // Post Content with See More/See Less
          if (post.content != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.content!.length > 1000 && !isExpandedLocal
                      ? '${post.content!.substring(0, 1000)}...'
                      : post.content!,
                ),
                if (post.content!.length > 1000)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        expandedPosts[post.id] = !isExpandedLocal;
                      });
                    },
                    child: Text(isExpandedLocal ? 'See less' : 'See more...'),
                  ),
              ],
            ),

          const SizedBox(height: 10),

          // Media List
          if (mediaForPost.isNotEmpty) _buildMediaList(mediaForPost),

          const SizedBox(height: 10),

          // Like, Comment Counts Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.red),
                  Text('$likeCount'),
                ],
              ),
              Text('$commentCount comment${commentCount != 1 ? 's' : ''}'),
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
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                  ),
                  label: const Text(
                    'Loved',
                    style: TextStyle(color: Colors.red),
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
                    '$commentCount Comment${commentCount != 1 ? 's' : ''}',
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

  Widget _buildMediaList(List<PostMedia> mediaForPost) {
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
                  mediaForPost[index].type == 'photo'
                      ? Image(
                    image: mediaForPost[index].url.startsWith('http')
                        ? NetworkImage(mediaForPost[index].url)
                        : FileImage(File(mediaForPost[index].url))
                    as ImageProvider,
                    fit: BoxFit.cover,
                  )
                      : VideoThumbnail(videoPath: mediaForPost[index].url),
                  if (index == 4 && mediaForPost.length > 5)
                    Container(
                      color: Colors.black54,
                      child: const Center(
                        child: Text(
                          'See more',
                          style: TextStyle(color: Colors.white),
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
