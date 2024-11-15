import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/places/placefeedback.dart';
import '../../../models/places/placefeedbackmedia.dart';
import '../../base/back_to_top_button.dart';
import '../../base/weather_icon_button.dart';
import '../../models/users/followuser.dart';
import '../../models/users/users.dart';
import '../../provider/review_provider.dart';
import 'detail_card/review_card.dart';
import '../../models/places/placefeedbackhelpful.dart';
import 'detail_page_tab_bars/form/reportform.dart';

class AllReviewsPage extends StatefulWidget {
  final List<PlaceFeedback> feedbacks;
  final List<User> users;
  final List<FollowUser> followUsers;
  final List<PlaceFeedbackMedia> feedbackMediaList;
  final List<PlaceFeedbackHelpful> feedbackHelpfuls;
  final String userId;
  final int placeId;
  final int totalReviews;

  const AllReviewsPage({
    Key? key,
    required this.feedbacks,
    required this.users,
    required this.feedbackMediaList,
    required this.placeId,
    required this.feedbackHelpfuls,
    required this.userId,
    required this.followUsers,
    required this.totalReviews,
  }) : super(key: key);

  @override
  State<AllReviewsPage> createState() => _AllReviewsPageState();
}

// FilterCell widget
class FilterCell extends StatefulWidget {
  final String label;
  final String count;
  final VoidCallback onTap;
  final Color? labelColor;
  final bool isSelected;

  const FilterCell({
    Key? key,
    required this.label,
    required this.count,
    required this.onTap,
    this.labelColor,
    this.isSelected = false,
  }) : super(key: key);

  @override
  State<FilterCell> createState() => _FilterCellState();
}

class _FilterCellState extends State<FilterCell> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: widget.isSelected ? Colors.white : Colors.grey,
          border: widget.isSelected ? Border.all(color: Colors.green) : Border.all(color: Colors.transparent),
          borderRadius: BorderRadius.circular(8),
        ),
        constraints: const BoxConstraints(
          minWidth: 85,
          minHeight: 50,
          maxHeight: 55, // Fixed height for 4 lines
          maxWidth: 85,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black, fontSize: 12,),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              widget.count,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: widget.labelColor ?? Colors.black, fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _AllReviewsPageState extends State<AllReviewsPage> {
  String sortByStars = "All";
  String sortOrder = "Latest";
  Color sortOrderColor = Colors.green;
  bool filterWithMedia = false;
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;

  late List<PlaceFeedbackMedia> relevantMediaList;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);

    relevantMediaList = widget.feedbackMediaList.where((media) {
      return widget.feedbacks.any((feedback) =>
      feedback.placeFeedbackId == media.feedbackId && feedback.placeId == widget.placeId);
    }).toList();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  // Listener to handle scroll events
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

  // Function to navigate to the Weather page
  void _navigateToWeatherPage() {
    Navigator.pushNamed(context, '/weather');
  }

  // Function to scroll back to the top
  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  // Get the list of PlaceFeedback objects filtered by the selected criteria
  List<PlaceFeedback> getFilteredFeedbacks() {
    // Start with feedbacks filtered by placeId
    List<PlaceFeedback> filteredFeedbacks = widget.feedbacks.where((feedback) {
      return feedback.placeId == widget.placeId;
    }).toList();

    // Filter by star rating if needed
    if (sortByStars != "All") {
      int starFilter = int.parse(sortByStars);
      filteredFeedbacks = filteredFeedbacks.where((feedback) {
        return feedback.rating.toInt() == starFilter;
      }).toList();
    }

    // Filter by media presence
    if (filterWithMedia) {
      filteredFeedbacks = filteredFeedbacks.where((feedback) {
        return relevantMediaList.any((media) => media.feedbackId == feedback.placeFeedbackId);
      }).toList();
    }

    // Sort by the selected sort order
    filteredFeedbacks.sort((a, b) {
      switch (sortOrder) {
        case "Latest":
          return b.createdAt.compareTo(a.createdAt);
        case "Oldest":
          return a.createdAt.compareTo(b.createdAt);
        case "Favorite (High to Low)":
          return _getHelpfulCount(b).compareTo(_getHelpfulCount(a));
        case "Favorite (Low to High)":
          return _getHelpfulCount(a).compareTo(_getHelpfulCount(b));
        default:
          return 0;
      }
    });

    return filteredFeedbacks;
  }

  // Helper to get the helpful count for sorting by "Favorite"
  int _getHelpfulCount(PlaceFeedback feedback) {
    return widget.feedbackHelpfuls.where((helpful) => helpful.placeFeedbackId == feedback.placeFeedbackId).length;
  }

  void _showSortByStarsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Sort by Stars"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStarFilterOption("All", "All"),
              for (int i = 5; i >= 1; i--) _buildStarFilterOption("$i Stars", "$i"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStarFilterOption(String title, String value) {
    return ListTile(
      leading: Icon(
        Icons.check_circle,
        color: sortByStars == value ? Colors.yellow : Colors.grey,
      ),
      title: Text(title),
      onTap: () {
        setState(() {
          sortByStars = value;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showSortOrderDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Sort by"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSortOrderOption("Latest", Colors.green),
              _buildSortOrderOption("Oldest", Colors.grey),
              _buildSortOrderOption("Favorite (High to Low)", Colors.red),
              _buildSortOrderOption("Favorite (Low to High)", Colors.purple),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOrderOption(String title, Color color) {
    return ListTile(
      leading: Icon(
        Icons.check_circle,
        color: sortOrder == title ? color : Colors.transparent,
      ),
      title: Text(title, style: TextStyle(color: color)),
      onTap: () {
        setState(() {
          sortOrder = title;
          sortOrderColor = color;
        });
        Navigator.pop(context);
      },
    );
  }

  User getUserDetails(String userId) {
    return widget.users.firstWhere(
          (user) => user.userId == userId,
      orElse: () => User(
        userId: 'default',
        userName: 'Unknown User',
        emailConfirmed: false,
        phoneNumberConfirmed: false,
        dateCreated: DateTime.now(),
        dateUpdated: DateTime.now(),
        reportTimes: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredFeedbacks = getFilteredFeedbacks();
    final mediaFeedbackCount = getMediaFeedbackCount();
    final reviewProvider = Provider.of<ReviewProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "All Reviews",
          style: TextStyle(
            color: Colors.brown,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                child: FilterCell(
                  label: "All",
                  count: "(${widget.totalReviews})",
                  isSelected: !filterWithMedia && sortByStars == "All" && sortOrder == "Latest",
                  onTap: () {
                    setState(() {
                      filterWithMedia = false;
                      sortByStars = "All";
                      sortOrder = "Latest";
                    });
                  },
                ),
              ),
              Flexible(
                child: FilterCell(
                  label: "With photo/video",
                  count: "($mediaFeedbackCount)",
                  isSelected: filterWithMedia,
                  onTap: () {
                    setState(() {
                      filterWithMedia = !filterWithMedia;
                    });
                  },
                ),
              ),
              Flexible(
                child: FilterCell(
                  label: "Sort by ⭐",
                  count: "($sortByStars)",
                  isSelected: sortByStars != "All",
                  onTap: _showSortByStarsDialog,
                ),
              ),
              Flexible(
                child: FilterCell(
                  label: "Sort by ⬇️",
                  count: "($sortOrder)",
                  labelColor: sortOrderColor,
                  isSelected: sortOrder != "Latest",
                  onTap: _showSortOrderDialog,
                ),
              ),
            ],
          ),
          const Divider(height: 20, thickness: 1, color: Colors.black12),
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: filteredFeedbacks.map((feedback) {
                      final relevantHelpfuls = widget.feedbackHelpfuls
                          .where((helpful) => helpful.placeFeedbackId == feedback.placeFeedbackId)
                          .toList();
                      final mediaForFeedback = relevantMediaList
                          .where((media) => media.feedbackId == feedback.placeFeedbackId)
                          .toList();

                      return ReviewCard(
                        isInAllProductPage: true,
                        feedback: feedback,
                        user: getUserDetails(feedback.userId),
                        feedbackMediaList: mediaForFeedback,
                        feedbackHelpfuls: relevantHelpfuls,
                        userId: widget.userId,
                        onFavoriteToggle: (feedbackId, isFavorited) {
                          reviewProvider.toggleFavorite(feedbackId, widget.userId);
                          // Refresh the page to reflect changes.
                          setState(() {});
                        },
                        onReport: () {
                          ReportForm.show(
                            context,
                            'Have a problem with this person? Report them to us!',
                          );
                        },
                        followUsers: widget.followUsers,
                      );
                    }).toList(),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 20,
                  child: WeatherIconButton(
                    onPressed: _navigateToWeatherPage,
                    assetPath: 'assets/icons/weather.png',
                  ),
                ),

                // Positioned Back to Top Button (Bottom Right) with AnimatedOpacity
                Positioned(
                  bottom: 12,
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
            ),
          ),
        ],
      ),
    );
  }

  // Count feedbacks with media
  int getMediaFeedbackCount() {
    return relevantMediaList.length;
  }

}