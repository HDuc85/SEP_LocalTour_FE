import 'package:flutter/material.dart';
import 'package:localtourapp/config/appConfig.dart';
import 'package:localtourapp/config/secure_storage_helper.dart';
import 'package:localtourapp/models/feedback/feedback_model.dart';
import 'package:localtourapp/services/review_service.dart';
import '../../base/back_to_top_button.dart';
import '../../base/weather_icon_button.dart';
import 'detail_card/review_card.dart';
import 'detail_page_tab_bars/form/reportform.dart';

class AllReviewsPage extends StatefulWidget {
  final int placeId;

  const AllReviewsPage({
    Key? key,
    required this.placeId,
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
            SizedBox(),
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
            SizedBox()
          ],
        ),
      ),
    );
  }
}

class _AllReviewsPageState extends State<AllReviewsPage> {
  final ReviewService _reviewService = ReviewService();

  List<FeedBackModel> _feedbackList = [];
  List<FeedBackModel> _feedbackListInit =[];
  int totalReview = -1;
  String currentUserId = '';
  String sortByStars = "All";
  String sortOrder = "Latest";
  Color sortOrderColor = Colors.green;
  bool filterWithMedia = false;

  int MediaCount = 0;
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _fetchFeedbackDate();
  }

  Future<void> _fetchFeedbackDate() async{
    var (fetchFeedback,total) = await _reviewService.getFeedback(widget.placeId);
    var myUserId = await SecureStorageHelper().readValue(AppConfig.userId);

    if(myUserId == null){
      myUserId ='';
    }

    var count = 0;
    for(var item in fetchFeedback){
      count += item.placeFeedbackMedia.length;
    }


    setState(() {
      _feedbackList = fetchFeedback;
      _feedbackListInit = fetchFeedback;
      totalReview = total;
      currentUserId = myUserId!;
      isLoading = false;
      MediaCount = count;
    });

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
  List<FeedBackModel> getFilteredFeedbacks() {
    // Start with feedbacks filtered by placeId
    List<FeedBackModel> filteredFeedbacks = _feedbackListInit;

    // Filter by star rating if needed
    if (sortByStars != "All") {
      int starFilter = int.parse(sortByStars);
      filteredFeedbacks = filteredFeedbacks.where((feedback) {
        return feedback.rating.toInt() == starFilter;
      }).toList();
    }

    // Filter by media presence
    if (filterWithMedia) {
      filteredFeedbacks = filteredFeedbacks.where((element) => element.placeFeedbackMedia.isNotEmpty).toList();
    }

    // Sort by the selected sort order
    filteredFeedbacks.sort((a, b) {
      switch (sortOrder) {
        case "Latest":
          return b.createDate.compareTo(a.createDate);
        case "Oldest":
          return a.createDate.compareTo(b.createDate);
        case "Favorite (High to Low)":
          return b.totalLike.compareTo(a.totalLike);
        case "Favorite (Low to High)":
          return a.totalLike.compareTo(b.totalLike);
        default:
          return 0;
      }
    });

    setState(() {
      _feedbackList = filteredFeedbacks;
    });

    return filteredFeedbacks;
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


  Future<void> onFavoriteToggle(int feedbackId) async{

  }

  @override
  Widget build(BuildContext context) {

    return isLoading
        ? Center(child: CircularProgressIndicator())
        :Scaffold(
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
                  count: "(${totalReview})",
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
                  count: "($MediaCount)",
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
                    children: _feedbackList.map((feedback) {

                      return ReviewCard(
                        feedBackCard: feedback,
                        placeId: widget.placeId,
                        onReport: () {
                          ReportForm.show(
                            context,
                            'Have a problem with this person? Report them to us!',
                            feedback.userId,
                            -1
                          );
                        },
                        userId: currentUserId,
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



}