import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localtourapp/constants/getListApi.dart';
import 'package:localtourapp/models/schedule/schedule_model.dart';
import 'package:localtourapp/services/schedule_service.dart';
import '../../../base/back_to_top_button.dart';
import '../../../base/weather_icon_button.dart';
import 'dart:ui' as ui;

class FeaturedSchedulePage extends StatefulWidget {
  final String userId;

  const FeaturedSchedulePage({
    super.key,
    required this.userId,
  });

  @override
  State<FeaturedSchedulePage> createState() => _FeaturedSchedulePageState();
}

class _FeaturedSchedulePageState extends State<FeaturedSchedulePage> {
  final ScheduleService _scheduleService = ScheduleService();
  final ScrollController _scrollController = ScrollController();
  late List<ScheduleModel> _listSchedule = [];
  bool isLoading = true;
  bool _showBackToTopButton = false;
  int? _expandedIndex;
  final Set<int> favoritedScheduleIds = {};

  @override
  void initState() {
    _scrollController.addListener(_scrollListener);
    super.initState();
    _initializeSchedules();
  }


  Future<void> _initializeSchedules() async{
    var listSchedule = await _scheduleService.getListSchedule('',SortBy.liked,SortOrder.desc,1,20);
    _listSchedule = listSchedule;
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchData() async{
    var listSchedule = await _scheduleService.getListSchedule('',SortBy.liked,SortOrder.desc,1,20);
    setState(() {
      _listSchedule = listSchedule;
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



  void _toggleFavorite(int scheduleId) async {
    var result = await _scheduleService.LikeSchedule(scheduleId);
    if(result){
      _fetchData();
    }
  }


  Future<void> _cloneSchedule(ScheduleModel schedule) async{
    var result = await _scheduleService.CloneSchedule(schedule.id);
    if(!result){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Some thing wrong went clone !'),
          duration: Duration(seconds: 3),
        ),
      );
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Schedule is cloned!'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }



  void _showDetailDialog(String detailText) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Detail'),
          content: SingleChildScrollView(
            child: Text(
              detailText,
              style: const TextStyle(color: Colors.black),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDestinationDetail(String detailText) {
    return GestureDetector(
      onTap: () => _showDetailDialog(detailText),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final textSpan = TextSpan(
            text: "Detail:\n",
            style: const TextStyle(fontWeight: FontWeight.bold),
            children: [
              TextSpan(
                text: detailText,
                style: const TextStyle(color: Colors.black),
              ),
            ],
          );

          final textPainter = TextPainter(
            text: textSpan,
            maxLines: 4,
            textDirection: ui.TextDirection.ltr,
          )..layout(maxWidth: constraints.maxWidth);

          final isOverflowing = textPainter.didExceedMaxLines;

          return RichText(
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              text: "Detail:\n",
              style: const TextStyle(color: Colors.black),
              children: [
                TextSpan(
                  text: detailText,
                  style: const TextStyle(color: Colors.black),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => _showDetailDialog(detailText),
                ),
                if (isOverflowing)
                  const TextSpan(
                    text: " ...",
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Top Most Favorite Schedules",
          maxLines: 2,
        ),
      ),
      body: Stack(
        children: [
          ListView.builder(
            controller: _scrollController,
            itemCount: _listSchedule.length + 1, // Increased by 1
            itemBuilder: (context, index) {
              if (index == _listSchedule.length) {
                // Extra SizedBox at the bottom
                return const SizedBox(height: 100); // Adjust height as needed
              }

              final schedule = _listSchedule[index];


              final isExpanded = _expandedIndex == index;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _expandedIndex = _expandedIndex == index ? null : index;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                  child: Column(
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: const BorderSide(color: Colors.black, width: 1),
                        ),
                        margin: const EdgeInsets.only(bottom: 10),
                        color: const Color(0xFFD6B588),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                schedule.scheduleName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                  "Created date: ${DateFormat('yyyy-MM-dd').format(schedule.createdDate)}"),
                              Row(
                                children: [
                                  Flexible(
                                    child: _buildDateField(
                                      "From Date",
                                      true,
                                      schedule.startDate,
                                          (_) {},
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: _buildDateField(
                                      "To Date",
                                      false,
                                      schedule.endDate,
                                          (_) {},
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text("Created by: ${schedule.userName ?? 'Unknown'}"),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(
                                      schedule.isLiked
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: schedule.isLiked
                                          ? Colors.red
                                          : Colors.grey,
                                    ),
                                    onPressed: () {
                                      _toggleFavorite(schedule.id);
                                    },
                                  ),
                                  Text(
                                    schedule.totalLikes.toString(),
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 12),
                                  ),
                                ],
                              ),
                              if (schedule.userId == widget.userId)
                                const Text("This is your schedule"),
                              if (schedule.userId != widget.userId)
                                TextButton(
                                  onPressed: () {
                                    // Show confirmation dialog for cloning
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text("Clone Schedule"),
                                          content: const Text(
                                              "Do you want to clone this schedule to yours?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(); // Close the dialog
                                              },
                                              child: const Text("Cancel"),
                                            ),
                                            TextButton(
                                              onPressed: () {

                                                _cloneSchedule(schedule);
                                                Navigator.of(context).pop(); // Close the dialog after cloning
                                              },
                                              child: const Text("Clone"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: const Text("Clone this schedule to yours"),
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (isExpanded)
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          child: _buildDestinationList(schedule),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 20,
            left: 50,
            child: WeatherIconButton(
              onPressed: _navigateToWeatherPage,
              assetPath: 'assets/icons/weather.png',
            ),
          ),

          // Positioned Back to Top Button (Bottom Right) with AnimatedOpacity
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
      ),
    );
  }

  Widget _buildDateField(
    String labelText,
    bool isFromDate,
    DateTime? initialDate,
    Function(DateTime) onDateChanged,
  ) {
    return AbsorbPointer(
      child: SizedBox(
        height: 30,
        width: 160,
        child: TextFormField(
          decoration: InputDecoration(
            hintText: initialDate != null
                ? initialDate.toString().split(' ')[0]
                : labelText,
            hintStyle: const TextStyle(fontSize: 12),
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
        ),
      ),
    );
  }

  Widget _buildDestinationList(ScheduleModel schedule) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: schedule.destinations.map((destination) {

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text("•"),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    destination.placeName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Image.network(
                  destination.placePhotoDisplay!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ],
            ),
            Row(
              children: [
                _buildDateField(
                  "Start Date",
                  true,
                  destination.startDate,
                  (_) {}, // Not editable in FeaturedPage
                ),
                const SizedBox(width: 6),
                _buildDateField(
                  "End Date",
                  false,
                  destination.endDate,
                  (_) {}, // Not editable in FeaturedPage
                ),
              ],
            ),
            const SizedBox(height: 4),
            _buildDestinationDetail(
                destination.detail ),
            const Divider(),
          ],
        );
      }).toList(),
    );
  }
}
