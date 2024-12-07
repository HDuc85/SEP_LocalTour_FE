
import 'package:flutter/material.dart';
import 'package:localtourapp/base/back_to_top_button.dart';
import 'package:localtourapp/base/weather_icon_button.dart';
import 'package:localtourapp/config/appConfig.dart';
import 'package:localtourapp/config/secure_storage_helper.dart';
import 'package:localtourapp/models/feedback/feedback_model.dart';
import 'package:localtourapp/page/detail_page/detail_card/review_card.dart';
import 'package:localtourapp/page/detail_page/detail_page.dart';
import 'package:localtourapp/page/detail_page/detail_page_tab_bars/form/reportform.dart';
import 'package:localtourapp/services/review_service.dart';

class ReviewedTabbar extends StatefulWidget {
  final String userId;

  const ReviewedTabbar({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<ReviewedTabbar> createState() => _ReviewedTabbarState();
}

class _ReviewedTabbarState extends State<ReviewedTabbar> {
  final ReviewService _reviewService = ReviewService();
  bool _showBackToTopButton = false;
  final ScrollController _scrollController = ScrollController();
  late int totalReviews;
  late List<FeedBackModel> _listFeedback;
  String _language = 'vi';

  bool isLoading = true;
  FeedBackModel feedBackModel = FeedBackModel(id: 1, userId: 'userId',placeId: 1,placeName: '',placePhotoDisplay: '' ,profileUrl: 'profileUrl', userName: 'userName', rating: 1, content: 'content', totalLike: 1, createDate: DateTime(2000), isLiked: true, placeFeedbackMedia: []);
  @override
  void initState() {
    super.initState();
    // Check if the current user is viewing their own reviews
    fetchInt();
    _scrollController.addListener(_scrollListener);
  }

  Future<void> fetchInt() async{
    var (listfeedback, totalreview) = await _reviewService.getFeedback(null,widget.userId);
    var language = await SecureStorageHelper().readValue(AppConfig.language);

    setState(() {
      _language = language!;
      _listFeedback = listfeedback;
      totalReviews = totalreview;
      isLoading = false;
    });
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

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return
      isLoading? const Center(child: CircularProgressIndicator()) :
      Stack(
      children: [
        SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                Container(
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("${_language != 'vi'?'Total Reviews:':'Tổng số đánh giá:'} $totalReviews", style:  TextStyle(fontSize: 18,fontWeight: FontWeight.bold,)),
                    ],
                  ),
                ),
                // Display user reviews
                ..._listFeedback.map((feedback) {
                  return GestureDetector(
                    onTap: () {
                      // Navigate to ReviewTabbar with the selected placeId
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(
                            placeId: feedback.placeId,
                          ),
                        ),
                      );
                    },
                    child: ReviewCard(
                      placeId: feedback.placeId,
                      feedBackCard: feedback,
                      userId: widget.userId,
                      onReport: () {
                        ReportForm.show(
                          context,
                            _language != 'vi'?'Have a problem with this person? Report them to us!':'Bạn có vấn đề với người dùng này? Hãy báo cáo cho chúng tôi!',
                          widget.userId,
                          -1,
                            _language
                        );
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          left: 40,
          child: WeatherIconButton(
            onPressed: _navigateToWeatherPage,
            assetPath: 'assets/icons/weather.png',
          ),
        ),
        Positioned(
          bottom: 12,
          left: 110,
          child: AnimatedOpacity(
            opacity: _showBackToTopButton ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: _showBackToTopButton
                ? BackToTopButton(
              onPressed: _scrollToTop, languageCode: 'vi',
            )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}


