import 'package:flutter/material.dart';
import '../../../../models/places/placefeedback.dart';
import '../../../models/places/placefeeedbackmedia.dart';
import '../../models/users/users.dart';
import 'detailcard/review_card.dart';
import '../../models/places/placefeedbackhelpful.dart';
import 'detailpagetabbars/form/reportform.dart';

class AllReviewsPage extends StatefulWidget {
  final List<int> favoritedFeedbackIds;
  final List<PlaceFeedback> feedbacks;
  final List<User> users;
  final List<PlaceFeedbackMedia> feedbackMediaList;
  final List<PlaceFeedbackHelpful> feedbackHelpfuls;
  final String userId;
  final int placeId;
  final int totalReviews;

  const AllReviewsPage({
    Key? key,
    required this.favoritedFeedbackIds,
    required this.feedbacks,
    required this.users,
    required this.feedbackMediaList,
    required this.placeId,
    required this.feedbackHelpfuls,
    required this.userId,
    required this.totalReviews,
  }) : super(key: key);

  @override
  State<AllReviewsPage> createState() => _AllReviewsPageState();
}

// FilterCell widget
class FilterCell extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.grey,
          border: isSelected ? Border.all(color: Colors.green) : Border.all(color: Colors.transparent),
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
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black, fontSize: 12,),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              count,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: labelColor ?? Colors.black, fontSize: 12,
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
  List<int> favoritedFeedbackIds = [];
  String sortByStars = "All";
  String sortOrder = "Latest";
  Color sortOrderColor = Colors.green;
  bool filterWithMedia = false;

  @override
  void initState() {
    super.initState();
    favoritedFeedbackIds = widget.favoritedFeedbackIds;
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
        return widget.feedbackMediaList.any((media) => media.feedbackId == feedback.placeFeedbackId);
      }).toList();
    }

    // Sort by the selected sort order
    filteredFeedbacks.sort((a, b) {
      switch (sortOrder) {
        case "Latest":
          return b.createdDate.compareTo(a.createdDate);
        case "Oldest":
          return a.createdDate.compareTo(b.createdDate);
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
            child: SingleChildScrollView(
              child: Column(
                children: filteredFeedbacks.map((feedback) {
                  final relevantHelpfuls = widget.feedbackHelpfuls
                      .where((helpful) => helpful.placeFeedbackId == feedback.placeFeedbackId)
                      .toList();

                  return ReviewCard(
                    isInAllProductPage: true,
                    feedback: feedback,
                    user: getUserDetails(feedback.userId),
                    feedbackMediaList: widget.feedbackMediaList
                        .where((media) => media.feedbackId == feedback.placeFeedbackId)
                        .toList(),
                    feedbackHelpfuls: relevantHelpfuls,
                    favoritedFeedbackIds: favoritedFeedbackIds,
                    onFavoriteToggle: _handleFavoriteToggle,
                    userId: widget.userId,
                    onReport: () {
                      ReportForm.show(
                        context,
                        'Have a problem with this person? Report them to us!',
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Count feedbacks with media
  int getMediaFeedbackCount() {
    return widget.feedbacks.where((feedback) {
      return widget.feedbackMediaList.any((media) => media.feedbackId == feedback.placeFeedbackId);
    }).length;
  }

  void _handleFavoriteToggle(int feedbackId, bool isFavorited) {
    setState(() {
      if (isFavorited) {
        favoritedFeedbackIds.add(feedbackId);
      } else {
        favoritedFeedbackIds.remove(feedbackId);
      }
    });
  }
}
