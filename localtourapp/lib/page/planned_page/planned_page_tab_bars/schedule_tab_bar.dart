import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // Needed for TapGestureRecognizer
import 'package:localtourapp/provider/schedule_provider.dart';
import 'package:localtourapp/models/places/placemedia.dart';
import 'package:localtourapp/models/places/placetranslation.dart';
import 'package:localtourapp/models/places/place.dart'; // Import Place
import 'package:localtourapp/models/schedule/schedulelike.dart';
import 'package:localtourapp/models/users/users.dart';
import 'package:localtourapp/provider/user_provider.dart';
import 'package:localtourapp/page/detail_page/detail_page.dart';
import 'package:localtourapp/provider/count_provider.dart';
import 'package:localtourapp/page/planned_page/planned_page_tab_bars/add_schedule_dialog.dart';
import 'package:localtourapp/page/planned_page/planned_page_tab_bars/suggest_schedule_page.dart';
import 'package:localtourapp/page/search_page/search_page.dart';
import 'package:provider/provider.dart';
import 'package:localtourapp/base/back_to_top_button.dart';
import 'package:localtourapp/base/weather_icon_button.dart';
import '../../../models/schedule/schedule.dart';
import '../../../models/schedule/destination.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class ScheduleTabbar extends StatefulWidget {
  final String userId;
  final List<Schedule> schedules;
  final List<ScheduleLike> scheduleLikes;
  final List<Destination> destinations;
  final Function(int scheduleId, bool isFavorited) onFavoriteToggle;
  final List<User> users;
  final List<Place> places; // Added
  final List<PlaceTranslation> translations; // Added

  const ScheduleTabbar({
    Key? key,
    required this.userId,
    required this.schedules,
    required this.scheduleLikes,
    required this.destinations,
    required this.onFavoriteToggle,
    required this.users,
    required this.places, // Initialize
    required this.translations, // Initialize
  }) : super(key: key);

  @override
  State<ScheduleTabbar> createState() => _ScheduleTabbarState();
}

class _ScheduleTabbarState extends State<ScheduleTabbar>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  List<Place> placeList = dummyPlaces;
  late String userId;
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;
  final FocusNode _nameFocusNode = FocusNode();
  String bullet = "\u2022 ";
  DateTime? _fromDate;
  DateTime? _toDate;
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  int? _expandedIndex;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  Map<int, bool> scheduleVisibility = {};
  final Set<int> _editingScheduleIds = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _nameFocusNode.addListener(_onNameFieldFocusChange);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _detailController.dispose();
    searchFocusNode.dispose();
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
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

  void _onNameFieldFocusChange() {
    if (!_nameFocusNode.hasFocus && _editingScheduleIds.isNotEmpty) {
      _saveScheduleName();
    }
  }

  void _saveScheduleName() {
    if (_editingScheduleIds.isNotEmpty) {
      final scheduleId = _editingScheduleIds.first;
      final scheduleProvider =
          Provider.of<ScheduleProvider>(context, listen: false);
      final schedule = scheduleProvider.getScheduleById(scheduleId);
      if (schedule != null) {
        final updatedSchedule = Schedule(
          id: schedule.id,
          userId: schedule.userId,
          scheduleName: _nameController.text,
          startDate: schedule.startDate,
          endDate: schedule.endDate,
          createdAt: schedule.createdAt,
          isPublic: schedule.isPublic,
        );
        scheduleProvider.updateSchedule(updatedSchedule);
        setState(() {
          _editingScheduleIds.remove(scheduleId);
        });
      }
    }
  }

  void _toggleEditing(int scheduleId) {
    setState(() {
      if (_editingScheduleIds.contains(scheduleId)) {
        _editingScheduleIds.remove(scheduleId);
      } else {
        _editingScheduleIds.add(scheduleId);
        final scheduleProvider =
            Provider.of<ScheduleProvider>(context, listen: false);
        final schedule = scheduleProvider.getScheduleById(scheduleId);
        if (schedule != null) {
          _nameController.text = schedule.scheduleName;
          _nameFocusNode.requestFocus();
        }
      }
    });
  }

  void _toggleFavorite(int scheduleId) {
    final scheduleProvider =
        Provider.of<ScheduleProvider>(context, listen: false);

    bool isCurrentlyFavorited = scheduleProvider.scheduleLikes.any(
      (like) => like.scheduleId == scheduleId && like.userId == widget.userId,
    );

    // Invoke the callback to update the provider
    widget.onFavoriteToggle(scheduleId, !isCurrentlyFavorited);
  }

  void _toggleVisibility(int scheduleId) {
    setState(() {
      // Update visibility in the map
      scheduleVisibility[scheduleId] = !(scheduleVisibility[scheduleId] ?? true);

      // Update the schedule's isPublic field if needed
      final scheduleProvider =
      Provider.of<ScheduleProvider>(context, listen: false);
      final schedule = scheduleProvider.getScheduleById(scheduleId);
      if (schedule != null) {
        schedule.isPublic = scheduleVisibility[scheduleId]!;
        scheduleProvider.updateSchedule(schedule); // Save changes to the provider
      }
    });
  }


  void _showDetailDialog(String initialText, Function(String) onSave, bool isCurrentUser) {
    _detailController.text = initialText;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isCurrentUser ? 'Edit Detail' : 'Detail'),
          content: isCurrentUser
              ? TextFormField(
            controller: _detailController,
            maxLines: 10,
            maxLength: 500,
            decoration: const InputDecoration(
              hintText: "Enter detail (max 500 words)",
              border: OutlineInputBorder(),
            ),
          )
              :TextFormField(
              controller: _detailController,
              readOnly: true,
              maxLines: 10,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
              ),
            ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            if (isCurrentUser)
              TextButton(
                onPressed: () {
                  onSave(_detailController.text);
                  Navigator.of(context).pop();
                },
                child: const Text('Save'),
              ),
          ],
        );
      },
    );
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

  List<Schedule> getFilteredSchedules() {
    String searchText = searchController.text.toLowerCase();

    return widget.schedules.where((schedule) {
      final matchesName =
          schedule.scheduleName.toLowerCase().contains(searchText);
      final matchesDate =
          (_fromDate == null || schedule.createdAt.isAfter(_fromDate!)) &&
              (_toDate == null || schedule.createdAt.isBefore(_toDate!));

      return matchesName && matchesDate;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    userId = Provider.of<UserProvider>(context, listen: false).userId;

    if (userId.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final List<Schedule> filteredSchedules = getFilteredSchedules();

    // Use the existing isCurrentUser method from UserProvider
    final bool isCurrentUser = Provider.of<UserProvider>(context, listen: false)
        .isCurrentUser(widget.userId);

    if (userId.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    // Fetch all schedules from ScheduleProvider
    return Stack(
      children: [
        GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            controller: _scrollController,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterSection(),
                    const SizedBox(height: 20),
                    if (isCurrentUser) ...[
                      _buildButtonsSection(), // Only show buttons for current user
                      const SizedBox(height: 25),
                    ],
                    _buildScheduleSection(filteredSchedules),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
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
              labelText: "Search by name",
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {}); // Trigger filtering as user types
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
            setState(() {}); // Trigger the search with the current filters
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

  Widget _buildScheduleSection(List<Schedule> filteredSchedules) {
    final scheduleProvider =
    Provider.of<ScheduleProvider>(context, listen: false);

    if (filteredSchedules.isEmpty) {
      return const Center(
        child: Text(
          "No schedules found.",
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: filteredSchedules.length,
        itemBuilder: (context, index) {
          final schedule = filteredSchedules[index];
          final isEditingName = _editingScheduleIds.contains(schedule.id);
          bool isExpanded = _expandedIndex == index;
          // Define isOwner for each schedule
          final bool isOwner = Provider.of<UserProvider>(context, listen: false)
              .isCurrentUser(schedule.userId);
          // Initial states for visibility and favorites
          bool isVisible = schedule.isPublic || isOwner;
          // If the schedule is not visible, skip rendering it
          if (!isVisible) {
            return const SizedBox.shrink();
          }

          return GestureDetector(
            onTap: () {
              setState(() {
                _expandedIndex = _expandedIndex == index ? null : index;
              });
            },
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
                        // Schedule name, editing, visibility, favorite toggling, and like count
                        if (isOwner)
                        GestureDetector(
                          onTap: () => _toggleEditing(schedule.id),
                          child: isEditingName
                              ? TextFormField(
                                  controller: _nameController,
                                  focusNode: _nameFocusNode,
                                  onFieldSubmitted: (newValue) {
                                    _saveScheduleName();
                                  },
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 8),
                                  ),
                                )
                              : Text(
                                  schedule.scheduleName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                        Row(
                          children: [
                            Text(
                                "Created date: ${DateFormat('yyyy-MM-dd hh:mm').format(schedule.createdAt)}"),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDateField(
                                "From Date",
                                true,
                                schedule.startDate,
                                (newDate) {
                                  setState(() {
                                    schedule.startDate = newDate;
                                  });
                                },
                                clearable: true,
                                onClear: () {
                                  setState(() {
                                    schedule.startDate =
                                        null; // Correctly clears startDate
                                  });
                                },
                                isOwner: Provider.of<UserProvider>(context, listen: false)
                                    .isCurrentUser(widget.userId),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildDateField(
                                "To Date",
                                false,
                                schedule.endDate,
                                (newDate) {
                                  setState(() {
                                    schedule.endDate = newDate;
                                  });
                                },
                                clearable: true,
                                onClear: () {
                                  setState(() {
                                    schedule.endDate =
                                        null; // Correctly clears endDate
                                  });
                                },
                                isOwner: Provider.of<UserProvider>(context, listen: false)
                                    .isCurrentUser(widget.userId),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            if (isOwner)
                              IconButton(
                                icon: Icon(
                                  scheduleVisibility[schedule.id] ?? schedule.isPublic
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.white,
                                ),
                                onPressed: isOwner
                                    ? () => _toggleVisibility(schedule.id)
                                    : null, // Ensure only the owner can toggle visibility
                              ),

                            Consumer<ScheduleProvider>(
                              builder: (context, scheduleProvider, child) {
                                bool isFavorited =
                                    scheduleProvider.scheduleLikes.any(
                                  (like) =>
                                      like.scheduleId == schedule.id &&
                                      like.userId == widget.userId,
                                );
                                int likeCount = scheduleProvider
                                    .getLikesForSchedule(schedule.id)
                                    .length;

                                return Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        isFavorited
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: isFavorited
                                            ? Colors.red
                                            : Colors.grey,
                                      ),
                                      onPressed: () =>
                                          _toggleFavorite(schedule.id),
                                    ),
                                    Text(
                                      likeCount.toString(),
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 12),
                                    ),
                                  ],
                                );
                              },
                            ),
                              Row(
                                children: [
                                  if (isOwner)
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Color(0xFF4F4F4F)),
                                    onPressed: () {
                                      _showDeleteConfirmationDialog(
                                          schedule.id, schedule.scheduleName);
                                    },
                                  ),
                                ],
                              ),
                          ],
                        )
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
                    child: _buildDestinationList(
                        scheduleProvider
                            .getDestinationsForSchedule(schedule.id),
                        schedule),
                  ),
              ],
            ),
          );
        });
  }

  void _showDeleteConfirmationDialog(int scheduleId, String scheduleName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete "$scheduleName"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                _deleteSchedule(scheduleId);
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _deleteSchedule(int scheduleId) {
    final manager = Provider.of<ScheduleProvider>(context, listen: false);
    manager.removeSchedule(scheduleId);
    setState(() {
      widget.destinations
          .removeWhere((destination) => destination.scheduleId == scheduleId);
      widget.schedules.removeWhere((schedule) => schedule.id == scheduleId);
      Provider.of<CountProvider>(context, listen: false)
          .decrementScheduleCount();
    });
  }



  Widget _buildDestinationList(
      List<Destination> scheduleDestinations, Schedule schedule) {
    final bool isCurrentUser =
    Provider.of<UserProvider>(context, listen: false).isCurrentUser(schedule.userId);

    void updateStartDate(Destination destination, DateTime? newDate) {
      setState(() {
        destination.startDate = newDate;
      });
    }

    void updateEndDate(Destination destination, DateTime? newDate) {
      setState(() {
        destination.endDate = newDate;
      });
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ...scheduleDestinations.map((destination) {
        final placeTranslation = widget.translations
            .firstWhereOrNull((t) => t.placeId == destination.placeId);

        final place = widget.places
            .firstWhereOrNull((p) => p.placeId == destination.placeId);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                _navigateToDetail(
                  destination.placeId,
                  place!,
                  placeTranslation,
                  mediaList, // Use your mediaList data here
                );
              },
              child: Row(
                children: [
                  Text(bullet),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      placeTranslation?.placeName ?? "Unknown Place",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Image.network(
                    place?.photoDisplay ?? 'assets/images/default.png',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey,
                      child: const Icon(Icons.image, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                _buildDateField(
                  "Start Date",
                  true,
                  destination.startDate,
                      (newDate) => updateStartDate(destination, newDate),
                  clearable: isCurrentUser,
                  onClear: () {
                    setState(() {
                      destination.startDate = null;
                    });
                  },
                  isOwner: isCurrentUser,
                ),
                const SizedBox(width: 6),
                _buildDateField(
                  "End Date",
                  false,
                  destination.endDate,
                      (newDate) => updateEndDate(destination, newDate),
                  clearable: isCurrentUser,
                  onClear: () {
                    setState(() {
                      destination.endDate = null;
                    });
                  },
                  isOwner: isCurrentUser,
                ),
              ],
            ),
            const SizedBox(height: 4),
            _buildDetailSection(
              destination.detail ?? "No details available",
                  (newDetail) {
                if (isCurrentUser) {
                  setState(() {
                    destination.detail = newDetail;
                  });
                }
              },
              isCurrentUser,
            ),
            if (isCurrentUser)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // isArrived checkbox
                  Checkbox(
                    value: destination.isArrived,
                    onChanged: (bool? value) {
                      if (value != null) {
                        Provider.of<ScheduleProvider>(context, listen: false)
                            .toggleIsArrived(destination.id);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _showDeleteDestinationConfirmationDialog(
                          destination, placeTranslation!.placeName, destination.id);
                    },
                  ),
                ],
              ),
            const Divider(),
          ],
        );
      }).toList(),
      if (isCurrentUser)
        Center(
          child: ElevatedButton(
            onPressed: () {
              // Navigate to SearchPage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Add More Place',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
    ]);
  }

  Widget _buildDetailSection(String detailText, Function(String) onSave, bool isCurrentUser) {
    return GestureDetector(
      onTap: () {
        _showDetailDialog(detailText, onSave, isCurrentUser);
      },
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
              text: textSpan, maxLines: 4, textDirection: ui.TextDirection.ltr)
            ..layout(maxWidth: constraints.maxWidth);

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
                    ..onTap = () {
                      _showDetailDialog(detailText, onSave, isCurrentUser);
                    },
                ),
                if (isOverflowing)
                  const TextSpan(
                    text: " ...",
                    style: TextStyle(
                        color: Colors.blue, decoration: TextDecoration.underline),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDeleteDestinationConfirmationDialog(
      Destination destination, String placeName, int destinationId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Destination'),
          content: Text('Are you sure you want to delete "$placeName"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _deleteDestination(destinationId);
                });
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteDestination(int destinationId) {
    final manager = Provider.of<ScheduleProvider>(context, listen: false);
    manager.removeDestination(destinationId);
    setState(() {
      widget.destinations
          .removeWhere((destination) => destination.scheduleId == destinationId);
      widget.schedules.removeWhere((schedule) => schedule.id == destinationId);
      Provider.of<CountProvider>(context, listen: false)
          .decrementScheduleCount();
    });
  }

  void _navigateToDetail(int placeId, Place place,
      PlaceTranslation? translation, List<PlaceMedia> mediaList) {
    Place? selectedPlace =
        placeList.firstWhereOrNull((place) => place.placeId == placeId);

    List<PlaceMedia> filteredMediaList =
        mediaList.where((media) => media.placeId == place.placeId).toList();

    PlaceTranslation? selectedTranslation = dummyTranslations.firstWhereOrNull(
      (trans) => trans.placeId == selectedPlace!.placeId,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailPage(
          userId: userId, // Replace with actual userId
          placeName: selectedTranslation?.placeName ?? 'Unknown Place',
          placeId: selectedPlace!.placeId,
          mediaList: filteredMediaList,
          languageCode: 'en',
        ),
      ),
    );
  }

  Widget  _buildDateField(
      String labelText,
      bool isStartDate,
      DateTime? initialDate,
      Function(DateTime?) onDateChanged, {
        bool clearable = false,
        VoidCallback? onClear,
        bool isOwner = true,
  }) {
    return GestureDetector(
      onTap: isOwner ? () async {
        DateTime? selectedDate =
            initialDate; // Temporarily store the initial date
        if (isOwner) {
          // Date picker
          final DateTime? date = await showDatePicker(
            context: context,
            initialDate: selectedDate ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );

          // If date is selected, proceed to time selection
          if (date != null) {
            selectedDate = DateTime(date.year, date.month, date.day,
                selectedDate?.hour ?? 0, selectedDate?.minute ?? 0);

            // Time picker
            final TimeOfDay? time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(selectedDate),
            );

            // If time is selected, update both date and time
            if (time != null) {
              selectedDate = DateTime(
                  date.year, date.month, date.day, time.hour, time.minute);
              onDateChanged(
                  selectedDate); // Only update when both date and time are confirmed
            }
          }
        }
      } : null,
      child: Stack(
        children: [
          AbsorbPointer(
            child: SizedBox(
              height: 30,
              width: 160,
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: initialDate != null
                      ? DateFormat('yyyy-MM-dd HH:mm').format(initialDate)
                      : labelText,
                  hintStyle: const TextStyle(fontSize: 12),
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
              ),
            ),
          ),
          if (clearable && initialDate != null && isOwner)
            Positioned(
              right:0,
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            showAddScheduleDialog(context, (scheduleName, startDate, endDate) {
              final newSchedule = Schedule(
                id: widget.schedules.length + 1,
                userId: widget.userId,
                scheduleName: scheduleName,
                startDate: startDate,
                endDate: endDate,
                createdAt: DateTime.now(),
                isPublic: false,
              );

              // Add schedule using ScheduleProvider
              Provider.of<ScheduleProvider>(context, listen: false)
                  .addSchedule(newSchedule);

              // Increment schedule count in CountProvider
              Provider.of<CountProvider>(context, listen: false)
                  .incrementScheduleCount();
            });
          },
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text("Add Schedule", style: TextStyle(fontSize: 13.6),),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _showSuggestScheduleBottomSheet,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text("Suggest Schedule", style: TextStyle(fontSize: 14),),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }

  void _showSuggestScheduleBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SuggestSchedulePage(userId: widget.userId);
      },
    );
  }
}
