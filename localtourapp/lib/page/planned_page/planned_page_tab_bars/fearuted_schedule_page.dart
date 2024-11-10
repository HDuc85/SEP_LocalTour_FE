import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../base/back_to_top_button.dart';
import '../../../base/weather_icon_button.dart';
import '../../../models/places/place.dart';
import '../../../models/places/placetranslation.dart';
import '../../../models/schedule/destination.dart';
import '../../../models/schedule/schedule.dart';
import '../../../models/schedule/schedulelike.dart';
import '../../../models/users/users.dart';
import 'dart:ui' as ui;

class FeaturedSchedulePage extends StatefulWidget {
  final String userId;
  final List<Schedule> allSchedules;
  final List<ScheduleLike> scheduleLikes;
  final List<Destination> destinations;
  final List<User> users;
  final Function(Schedule, List<Destination>) onClone;

  const FeaturedSchedulePage({
    super.key,
    required this.allSchedules,
    required this.scheduleLikes,
    required this.destinations,
    required this.users,
    required this.userId,
    required this.onClone,
  });

  @override
  State<FeaturedSchedulePage> createState() => _FeaturedSchedulePageState();
}

class _FeaturedSchedulePageState extends State<FeaturedSchedulePage> {
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;
  int? _expandedIndex;
  final Set<int> favoritedScheduleIds = {};

  @override
  void initState() {
    _scrollController.addListener(_scrollListener);
    super.initState();
    _initializeFavoriteSchedules();
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

  void _initializeFavoriteSchedules() {
    for (var like in widget.scheduleLikes) {
      favoritedScheduleIds.add(like.scheduleId);
    }
  }

  void _toggleFavorite(int scheduleId) {
    setState(() {
      if (favoritedScheduleIds.contains(scheduleId)) {
        favoritedScheduleIds.remove(scheduleId);
      } else {
        favoritedScheduleIds.add(scheduleId);
      }
    });
  }

  List<Schedule> _getTopSchedules() {
    final sortedSchedules = widget.allSchedules.toList()
      ..sort((a, b) {
        final aLikes = widget.scheduleLikes
            .where((like) => like.scheduleId == a.id)
            .length;
        final bLikes = widget.scheduleLikes
            .where((like) => like.scheduleId == b.id)
            .length;
        return bLikes.compareTo(aLikes);
      });
    return sortedSchedules.take(10).toList();
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
    final topSchedules = _getTopSchedules();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Top 10 Most Favorite Schedules",
          maxLines: 2,
        ),
      ),
      body: Stack(
        children: [
          ListView.builder(
            controller: _scrollController,
            itemCount: topSchedules.length + 1, // Increased by 1
            itemBuilder: (context, index) {
              if (index == topSchedules.length) {
                // Extra SizedBox at the bottom
                return const SizedBox(height: 100); // Adjust height as needed
              }

              final schedule = topSchedules[index];
              final scheduleLikes = widget.scheduleLikes
                  .where((like) => like.scheduleId == schedule.id)
                  .toList();
              final int likeCount = scheduleLikes.length;
              final scheduleDestinations = widget.destinations
                  .where((destination) => destination.scheduleId == schedule.id)
                  .toList();
              final isExpanded = _expandedIndex == index;

              // Find the user who created the schedule
              final user = widget.users.firstWhere(
                    (u) => u.userId == schedule.userId,
                orElse: () =>
                    User.minimal(userId: 'Unknown', userName: 'Unknown User'),
              );

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
                                  Text("Created by: ${user.userName ?? 'Unknown'}"),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(
                                      favoritedScheduleIds.contains(schedule.id)
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: favoritedScheduleIds.contains(schedule.id)
                                          ? Colors.red
                                          : Colors.grey,
                                    ),
                                    onPressed: () {
                                      _toggleFavorite(schedule.id);
                                    },
                                  ),
                                  Text(
                                    likeCount.toString(),
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
                                                // Perform the cloning action by calling onClone
                                                final clonedSchedule = Schedule(
                                                  id: widget.allSchedules.length + 1, // Use a unique ID
                                                  userId: 'anh-tuan-unique-id-1234', // Pass the current user ID
                                                  scheduleName: schedule.scheduleName,
                                                  startDate: schedule.startDate,
                                                  endDate: schedule.endDate,
                                                  createdDate: DateTime.now(),
                                                  isPublic: false,
                                                );

                                                // Clone the destinations for the schedule
                                                final clonedDestinations = widget.destinations
                                                    .where((destination) => destination.scheduleId == schedule.id)
                                                    .map((destination) => Destination(
                                                  id: widget.destinations.length + 1, // Keep the same ID or create a new unique ID
                                                  scheduleId: clonedSchedule.id, // Link to cloned schedule
                                                  placeId: destination.placeId,
                                                  startDate: destination.startDate,
                                                  endDate: destination.endDate,
                                                  detail: destination.detail,
                                                ))
                                                    .toList();

                                                widget.onClone(
                                                    clonedSchedule, clonedDestinations); // Call onClone with cloned schedule

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
                          child: _buildDestinationList(scheduleDestinations, schedule),
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

  Widget _buildDestinationList(
      List<Destination> scheduleDestinations, Schedule schedule) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: scheduleDestinations.map((destination) {
        final place =
            dummyPlaces.firstWhere((p) => p.placeId == destination.placeId);
        final placeTranslation =
            dummyTranslations.firstWhere((t) => t.placeId == destination.placeId);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text("•"),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    placeTranslation.placeName,
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
                  place.photoDisplay,
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
                destination.detail ?? "No details available"),
            const Divider(),
          ],
        );
      }).toList(),
    );
  }
}
