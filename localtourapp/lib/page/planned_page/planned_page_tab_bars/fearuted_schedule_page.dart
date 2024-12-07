import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localtourapp/constants/getListApi.dart';
import 'package:localtourapp/models/schedule/schedule_model.dart';
import 'package:localtourapp/services/schedule_service.dart';
import '../../../base/back_to_top_button.dart';
import 'dart:ui' as ui;
import '../../../base/weather_icon_button.dart';
import '../../../models/schedule/destination_model.dart';
import '../../detail_page/detail_page.dart';
import 'dashed_line.dart';

class FeaturedSchedulePage extends StatefulWidget {
  final String userId;
  final String language;
  const FeaturedSchedulePage(
      {super.key, required this.userId, required this.language});

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

  @override
  void initState() {
    _scrollController.addListener(_scrollListener);
    super.initState();
    _initializeSchedules();
  }

  Future<void> _initializeSchedules() async {
    var listSchedule = await _scheduleService.getListSchedule(
        '', SortBy.liked, SortOrder.desc, 1, 20);
    _listSchedule = listSchedule;
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchData() async {
    var listSchedule = await _scheduleService.getListSchedule(
        '', SortBy.liked, SortOrder.desc, 1, 20);
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
    if (result) {
      _fetchData();
    }
  }

  Future<void> _cloneSchedule(ScheduleModel schedule) async {
    var result = await _scheduleService.CloneSchedule(schedule.id);
    if (!result) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.language != 'vi'
              ? "Có gì đó không ổn khi sao chép!"
              :'Some thing wrong went clone !'),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.language != 'vi'
              ? "Lịch trình đã được sao chép"
              :'Schedule is cloned!'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showDetailDialog(String detailText) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(widget.language != 'vi'
              ? "Chi tiết"
              :'Detail'),
          content: SingleChildScrollView(
            child: Text(
              detailText,
              style: const TextStyle(color: Colors.black),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(widget.language != 'vi'
                  ? "Đóng"
                  :'Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.language != 'vi'
              ? "Top Most Favorite Schedules"
              : "Top Lịch Trình Được Yêu Thích",
          maxLines: 2,
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          ListView.builder(
            controller: _scrollController,
            itemCount: _listSchedule.length + 1,
            itemBuilder: (context, index) {
              if (index == _listSchedule.length) {
                // Add some padding at the end of the list
                return const SizedBox(height: 100);
              }

              final schedule = _listSchedule[index];
              final isExpanded = _expandedIndex == index;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _expandedIndex =
                    _expandedIndex == index ? null : index;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 8),
                  child: Column(
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: const BorderSide(
                              color: Colors.black, width: 1),
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
                                "${widget.language != 'vi' ? 'Created date:' : 'Tạo lúc'} ${DateFormat('yyyy-MM-dd').format(schedule.createdDate)}",
                              ),
                              Row(
                                children: [
                                  Flexible(
                                    child: _buildDateField(
                                      widget.language != 'vi'
                                          ? "From Date"
                                          : 'Từ ngày',
                                      true,
                                      schedule.startDate,
                                          (_) {},
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: _buildDateField(
                                      widget.language != 'vi'
                                          ? "To Date"
                                          : 'Tới ngày',
                                      false,
                                      schedule.endDate,
                                          (_) {},
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      schedule.isLiked
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: schedule.isLiked
                                          ? Colors.red
                                          : Colors.grey,
                                    ),
                                    onPressed: () => _toggleFavorite(schedule.id),
                                  ),
                                  Text(
                                    schedule.totalLikes.toString(),
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (schedule.userId == widget.userId)
                                Text(
                                  widget.language != 'vi'
                                      ? "This is your schedule"
                                      : "Lịch trình của bạn",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                )
                              else
                                Row(
                                  children: [
                                    Text(
                                      "${widget.language != 'vi' ? 'Created by' : 'Tạo bởi'}: ${schedule.userName ?? 'Unknown'}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text(
                                                widget.language != 'vi'
                                                    ? "Clone Schedule"
                                                    : "Sao chép Lịch trình",
                                              ),
                                              content: Text(
                                                widget.language != 'vi'
                                                    ? "Do you want to clone this schedule to yours?"
                                                    : "Bạn có muốn sao chép lịch trình này không?",
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop();
                                                  },
                                                  child: Text(widget
                                                      .language !=
                                                      'vi'
                                                      ? "Cancel"
                                                      : "Hủy"),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    _cloneSchedule(
                                                        schedule);
                                                    Navigator.of(context)
                                                        .pop();
                                                  },
                                                  child: Text(widget
                                                      .language !=
                                                      'vi'
                                                      ? "Clone"
                                                      : "Sao chép"),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: Text(
                                        widget.language != 'vi'
                                            ? "Clone this schedule to yours"
                                            : "Sao chép lịch trình",
                                      ),
                                    ),
                                  ],
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
                            border:
                            Border.all(color: Colors.black, width: 1),
                          ),
                          child: _buildDestinationGrid(
                              schedule.destinations, schedule),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 0,
            left: 20,
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
                languageCode: widget.language,
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

  Widget _buildDestinationDetailSheet(
    DestinationModel destination,
  ) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * (2 / 3),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 16,
          left: 16,
          right: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  // Navigate to detail page when placeName is tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailPage(
                        placeId: destination.placeId,
                      ),
                    ),
                  );
                },
                child: Text(
                  destination.placeName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  // Navigate to detail page when placePhotoDisplay is tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailPage(
                        placeId: destination.placeId,
                      ),
                    ),
                  );
                },
                child: Image.network(
                  destination.placePhotoDisplay ?? 'assets/images/default.png',
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
              _buildDateField(
                widget.language == 'vi' ? 'Từ ngày' : "From Date",
                true,
                destination.startDate,
                (_) {},
              ),
              const SizedBox(height: 6),
              _buildDateField(
                widget.language == 'vi' ?'Tới ngày':
                "End Date",
                false,
                destination.endDate,
                (_) {},
              ),
              const SizedBox(height: 10),
              _buildDetailSection(
                destination.detail,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String detailText) {
    return GestureDetector(
      onTap: () {
        _showDetailDialog(detailText);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final textSpan = TextSpan(
            text: detailText.isNotEmpty
                ? detailText
                : (widget.language == 'vi'
                ? "Nhấn để thêm chi tiết..."
                : "Tap to add details..."),

            style: TextStyle(
              color: detailText.isNotEmpty ? Colors.black : Colors.grey,
              fontStyle:
                  detailText.isEmpty ? FontStyle.italic : FontStyle.normal,
            ),
          );

          final textPainter = TextPainter(
            text: textSpan,
            maxLines: 25,
            textDirection: ui.TextDirection.ltr,
          )..layout(maxWidth: constraints.maxWidth);

          final isOverflowing = textPainter.didExceedMaxLines;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.language != 'vi'
                  ? "Chi tiết"
                  : "Detail:",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black,
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: constraints.maxWidth,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: RichText(
                  maxLines: 25,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    text: detailText.isNotEmpty
                        ? detailText
                        : (widget.language == 'vi'
                        ? "Nhấn để thêm chi tiết..."
                        : "Tap to add details..."),

                    style: TextStyle(
                      color: detailText.isNotEmpty ? Colors.black : Colors.grey,
                      fontStyle: detailText.isEmpty
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                    children: [
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDestinationDetails(DestinationModel destination) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return _buildDestinationDetailSheet(destination);
          },
        );
      },
    );
  }

  Widget _buildDestinationGrid(List<DestinationModel> destinations, ScheduleModel schedule) {
    if (destinations.isEmpty) {
      return Center(
        child: Text(
          widget.language != 'vi'
              ? 'No destinations available.'
              : 'Không có địa điểm nào.',
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
      );
    }

    List<Widget> rows = [];
    int index = 0;
    int columns = 3;
    double connectorHeight = 40; // Vertical connector height
    double circleSize = 50; // Diameter of CircleAvatar

    // Add a placeholder for the add button at the end of the destinations list
    List<DestinationModel?> allItems = List.from(destinations);

    while (index < allItems.length) {
      // Get the items for the current row
      List<DestinationModel?> rowItems = allItems.sublist(
        index,
        (index + columns > allItems.length) ? allItems.length : index + columns,
      );

      // Determine if the row should be reversed
      bool isEvenRow = (index ~/ columns) % 2 == 1;

      // Build the row with connectors
      List<Widget> rowWidgets = [];
      for (int i = 0; i < rowItems.length; i++) {
        DestinationModel? destination = rowItems[i];

        if (destination != null) {
          // Wrap the CircleAvatar with GestureDetector for onTap to show details
          Widget circleAvatar = GestureDetector(
            onTap: () => _showDestinationDetails(destination),
            child: Column(
              children: [
                CircleAvatar(
                  radius: circleSize / 2,
                  backgroundImage: NetworkImage(
                    destination.placePhotoDisplay ?? 'assets/images/default.png',
                  ),
                  backgroundColor: Colors.grey,
                ),
                SizedBox(
                  width: 70,
                  child: Text(
                    destination.placeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
          rowWidgets.add(circleAvatar);

          // Add horizontal dashed connector except after the last item
          if (i < rowItems.length - 1) {
            rowWidgets.add(
              Container(
                padding: EdgeInsets.only(top: circleSize / 1.5),
                height: circleSize,
                alignment: Alignment.center,
                child: Transform.rotate(
                  angle: isEvenRow ? pi : 0,
                  child: DashedLine(
                    isHorizontal: true,
                    length: MediaQuery.of(context).size.width / 6.55,
                  ),
                ),
              ),
            );
          }
        }
      }

      // Reverse the row if it's an even row
      if (isEvenRow) {
        rowWidgets = rowWidgets.reversed.toList();
      }

      // Build the row widget
      rows.add(Row(
        mainAxisAlignment:
        isEvenRow ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: rowWidgets,
      ));

      // Add vertical dashed connector under the last item of the previous row
      if (index + columns < allItems.length) {
        rows.add(
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: isEvenRow
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                    width: circleSize,
                    alignment: Alignment.center,
                    child: DashedLine(
                      isHorizontal: false,
                      length: connectorHeight,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      index += columns;
    }

    // Ensure a widget is always returned
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: rows,
    );
  }

}
