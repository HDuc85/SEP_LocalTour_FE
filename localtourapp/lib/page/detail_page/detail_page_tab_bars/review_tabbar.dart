import 'dart:io';
import 'package:flutter/material.dart';
import 'package:localtourapp/config/appConfig.dart';
import 'package:localtourapp/config/secure_storage_helper.dart';
import 'package:localtourapp/models/feedback/feedback_model.dart';
import 'package:localtourapp/models/places/place_detail_model.dart';
import 'package:localtourapp/models/users/userProfile.dart';
import 'package:localtourapp/services/place_service.dart';
import 'package:localtourapp/services/review_service.dart';
import 'package:localtourapp/services/user_service.dart';
import '../../../base/weather_icon_button.dart';
import '../../../services/report_service.dart';
import '../detail_card/review_card_list.dart';
import '../detail_card/review_card.dart';
import '../all_reviews_page.dart';
import 'form/reportform.dart';
import 'form/review_dialog.dart';

class ReviewTabbar extends StatefulWidget {
  final int placeId;
  final String userId;
  const ReviewTabbar({
    super.key,
    required this.placeId,
    required this.userId,
  });

  @override
  State<ReviewTabbar> createState() => _ReviewTabbarState();
}

class _ReviewTabbarState extends State<ReviewTabbar> {
  final ReviewService _reviewService = ReviewService();
  final PlaceService _placeService = PlaceService();
  final UserService _userService = UserService();
  List<FeedBackModel> _listFeedbacks = [];
  late FeedBackModel _userFeedback ;
  late Userprofile _userprofile;
  String currentUser = '';
  bool _isLogin = false;
  bool isLoading = true;
  bool showAllReviews = false;
  late int totalReviewers = 0;
  late PlaceDetailModel _placeDetailModel;
  void _navigateToWeatherPage() {
    Navigator.pushNamed(context, '/weather');
  }
  bool userHasReviewed = false;
  String _language = 'vi';
  @override
  void initState() {
    super.initState();
    fetchListReview();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Calculate the initial score after the widget builds
      //_updatePlaceScore();
    });

  }

  Future<void> fetchListReview() async{
    var (listDate,totalReview) = await _reviewService.getFeedback(widget.placeId);
    var fetchPlaceDetail = await _placeService.GetPlaceDetail(widget.placeId);
    var userId = await SecureStorageHelper().readValue(AppConfig.userId);
    var islogin = await SecureStorageHelper().readValue(AppConfig.isLogin);
    bool isLogin = false;
    if(islogin != null){
      isLogin = true;
    }
    if(userId != "" && userId != null){
      var userprofile = await _userService.getUserProfile(userId);
      setState(() {
        _userprofile = userprofile;
      });
    }else{
      userId = '';
    }
    if(listDate.isNotEmpty){
      setState(() {
        _listFeedbacks = listDate;
        userHasReviewed = userId!.contains(listDate.first.userId);
      });
    }
    if(listDate.isEmpty){
      setState(() {
        _listFeedbacks = listDate;
        userHasReviewed =false;
      });
    }
    if(userHasReviewed){
      setState(() {
        _userFeedback = listDate.first;
      });
    }
    var language = await SecureStorageHelper().readValue(AppConfig.language);

    setState(() {
      _language = language!;
      _isLogin = isLogin;
      totalReviewers = totalReview;
      currentUser = userId!;
      isLoading = false;
      _placeDetailModel = fetchPlaceDetail;
    });
  }


  Future<void> fetchDate() async {
    var (listDate,totalReview) = await _reviewService.getFeedback(widget.placeId);
    var fetchPlaceDetail = await _placeService.GetPlaceDetail(widget.placeId);

    setState(() {
      _listFeedbacks = listDate;
      totalReviewers = totalReview;
      _placeDetailModel = fetchPlaceDetail;
    });
  }

  /// Method to delete a user's review from ReviewProvider.

  /// Method to add or update a user's review using the ReviewProvider.
  void addOrUpdateUserReview(int rating, String content, List<File> images, List<File> videos, [int? feedbackId]) async {
    List<File> combinedList = [];
    combinedList.addAll(images);
    combinedList.addAll(videos);

    String result = '';

    bool isUpdate = userHasReviewed; // Determine if it's an update
    if (!isUpdate) {
      result = await _reviewService.CreateFeedback(widget.placeId, rating, content, combinedList);
    } else {
      result = await _reviewService.UpdateFeedback(widget.placeId, rating, feedbackId!, content, combinedList);
    }

    if (result != 'Success') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_language != 'vi'
              ? 'Something went wrong'
              : 'Có gì đó không ổn'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_language != 'vi'
              ? (isUpdate ? 'Your review has been updated.' : 'Your review has been added.')
              : (isUpdate ? 'Đánh giá của bạn đã được cập nhật.' : 'Đánh giá của bạn đã được thêm.')),
        ),
      );
      fetchListReview(); // Refresh the review list
    }
  }

  void deleteUserReview(int feedbackId, int placeId) async {
    var result = await _reviewService.DeleteFeedback(placeId, feedbackId);
    if(result){
      setState(() {
        fetchListReview();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool check = (userHasReviewed && _listFeedbacks.isNotEmpty);
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        :Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "${_language != 'vi'?'reviewers':'Tổng đánh giá'}: $totalReviewers",
                      style: const TextStyle(fontSize: 13),
                    ),
                    buildStarRating(_placeDetailModel.rating),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AllReviewsPage(
                              placeId: widget.placeId,
                            ),
                          ),
                        );
                      },
                      child:  Text(_language != 'vi'?"See all":"Xem tất cả", style: const TextStyle(color: Colors.blue),),
                    ),
                  ],
                ),
              ),
              if (!userHasReviewed && _isLogin)
                Container(
                  margin:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: _userprofile.userProfileImage != ''
                            ? NetworkImage(_userprofile.userProfileImage)
                            : null,
                        child: _userprofile.userProfileImage == ''
                            ? const Icon(Icons.account_circle, size: 60, color: Colors.grey)
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "${_userprofile.userName},${_language != 'vi'? "you have no reviews yet, let's explore and review it!" : 'Bạn chưa có đánh giá nào trước dây, hãy trải nghiệm và đánh giá!'}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return ReviewDialog(
                                onSubmit: (int rating, String content,
                                    List<File> images, List<File> videos) {
                                  addOrUpdateUserReview(
                                      rating, content, images, videos);
                                },
                             );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pinkAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 30),
                          elevation: 2,
                          side: const BorderSide(color: Colors.black, width: 1),
                        ),
                        child:  Text(
                          _language != 'vi'?'Review !!!':'Đánh giá!!!',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              check?
              ReviewCard(
                  userId: currentUser,
                  placeId: widget.placeId,
                  feedBackCard: _userFeedback,
                  onUpdate: fetchListReview,
                  onDelete: () {
                    deleteUserReview(_userFeedback.id,widget.placeId);
                  },
                  onReport:() {} ): const SizedBox(),
              ReviewCardList(
                placeId: widget.placeId,
                feedbacks: userHasReviewed?_listFeedbacks.sublist(1):_listFeedbacks,
                userId: currentUser,
                limit: 3,
                onSeeAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllReviewsPage(
                        placeId: widget.placeId,
                      ),
                    ),
                  );
                },
                // Updated onReport callback for other user reviews
                onReport: (userId) {
                  ReportForm.show(
                    context,
                    _language != 'vi' ? 'Have a problem with this person’s feedback? Please report it to us.' : 'Có vấn đề với đánh giá của người dùng này? Hãy báo cáo cho chúng tôi',
                    userId,
                    -1,
                    _language,
                    onSubmit: (String message) async {
                    },
                  );
                },
              ),
            ],
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
      ],
    );


  }

  Widget buildStarRating(double score) {
    int fullStars = score.floor(); // Full stars
    bool hasHalfStar =
        (score - fullStars) >= 0.5; // Determine if there's a half-star

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return const Icon(Icons.star, color: Colors.red, size: 20);
        } else if (index == fullStars && hasHalfStar) {
          return const Icon(Icons.star_half, color: Colors.red, size: 20);
        } else {
          return const Icon(Icons.star_border, color: Colors.red, size: 20);
        }
      }),
    );
  }
}

