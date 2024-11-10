
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // Needed for TapGestureRecognizer
import 'package:localtourapp/base/schedule_provider.dart';
import 'package:localtourapp/models/places/placemedia.dart';
import 'package:localtourapp/models/places/placetranslation.dart';
import 'package:localtourapp/models/places/place.dart'; // Import Place
import 'package:localtourapp/models/schedule/schedulelike.dart';
import 'package:localtourapp/models/users/users.dart';
import 'package:localtourapp/page/account/user_provider.dart';
import 'package:localtourapp/page/detail_page/detail_page.dart';
import 'package:localtourapp/page/detail_page/detail_page_tab_bars/count_provider.dart';
import 'package:localtourapp/page/planned_page/planned_page_tab_bars/add_schedule_dialog.dart';
import 'package:localtourapp/page/planned_page/planned_page_tab_bars/fearuted_schedule_page.dart';
import 'package:localtourapp/page/search_page/search_page.dart';
import 'package:provider/provider.dart';
import 'package:localtourapp/base/back_to_top_button.dart';
import 'package:localtourapp/base/schedule_destination_manager.dart';
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

class _ScheduleTabbarState extends State<ScheduleTabbar> {
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
  final Set<int> favoritedScheduleIds = {};
  final Set<int> _editingScheduleIds = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _nameFocusNode.addListener(_onNameFieldFocusChange);
    _initializeFavoriteSchedules();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize visibility based on passed schedules
      for (var schedule in widget.schedules) {
        scheduleVisibility[schedule.id] = true;
      }
      Provider.of<CountProvider>(context, listen: false)
          .setScheduleCount(widget.schedules.length);
    });
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
          createdDate: schedule.createdDate,
          isPublic: schedule.isPublic,
        );
        scheduleProvider.updateSchedule(updatedSchedule);
        setState(() {
          _editingScheduleIds.remove(scheduleId);
        });
      }
    }
  }

  void _initializeFavoriteSchedules() {
    for (var like in widget.scheduleLikes) {
      if (like.userId == widget.userId) {
        favoritedScheduleIds.add(like.scheduleId);
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

  void _showDetailDialog(String initialText, Function(String) onSave) {
    _detailController.text = initialText;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Detail'),
          content: TextFormField(
            controller: _detailController,
            maxLines: 10,
            maxLength: 500,
            decoration: const InputDecoration(
              hintText: "Enter detail (max 500 words)",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
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
    final filtered = widget.schedules.where((schedule) {
      final matchesName =
          schedule.scheduleName.toLowerCase().contains(searchText);
      final matchesDate = (_fromDate == null ||
              (schedule.startDate != null &&
                  schedule.startDate!.isAfter(_fromDate!))) &&
          (_toDate == null ||
              (schedule.endDate != null &&
                  schedule.endDate!.isBefore(_toDate!)));
      return matchesName && matchesDate;
    }).toList();
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    userId = Provider.of<UserProvider>(context).userId;

    if (userId.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final List<Schedule> filteredSchedules = getFilteredSchedules();
    // Fetch all schedules from ScheduleProvider
    final List<Schedule> allSchedules =
        Provider.of<ScheduleProvider>(context, listen: false).schedules;
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
                    _buildButtonsSection(),
                    const SizedBox(height: 25),
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
        const SizedBox(
          height: 10,
        ),
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
                }),
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
                }),
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
                        'Please choose both "From Date" and "To Date" for filtering.')),
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

  Widget _buildScheduleSection(List<Schedule> filteredSchedules) {
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
          final userOwnsSchedule = schedule.userId == widget.userId;
          final isEditingName = _editingScheduleIds.contains(schedule.id);
          final isExpanded = _expandedIndex == index;
          final scheduleLikes = widget.scheduleLikes
              .where((like) => like.scheduleId == schedule.id)
              .toList();
          final int likeCount = scheduleLikes.length;

          final scheduleDestinations = widget.destinations
              .where((destination) => destination.scheduleId == schedule.id)
              .toList();

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
                                "Created date: ${DateFormat('yyyy-MM-dd').format(schedule.createdDate)}"),
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
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(
                                scheduleVisibility[schedule.id] == false
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                if (userOwnsSchedule) {
                                  setState(() {
                                    scheduleVisibility[schedule.id] =
                                        !(scheduleVisibility[schedule.id] ??
                                            true);
                                  });
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                favoritedScheduleIds.contains(schedule.id)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color:
                                    favoritedScheduleIds.contains(schedule.id)
                                        ? Colors.red
                                        : Colors.grey,
                              ),
                              onPressed: () {
                                final isFavorited =
                                    favoritedScheduleIds.contains(schedule.id);
                                widget.onFavoriteToggle(
                                    schedule.id, !isFavorited);
                                setState(() {
                                  _toggleFavorite(schedule.id);
                                });
                              },
                            ),
                            Text(
                              likeCount.toString(),
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 12),
                            ),
                            if (userOwnsSchedule)
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
                    child:
                        _buildDestinationList(scheduleDestinations, schedule),
                  ),
              ],
            ),
          );
        });
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
    final manager =
        Provider.of<ScheduleDestinationManager>(context, listen: false);
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                  (newDate) {
                    setState(() {
                      destination.startDate = newDate;
                    });
                  },
                ),
                const SizedBox(width: 6),
                _buildDateField(
                  "End Date",
                  false,
                  destination.endDate,
                  (newDate) {
                    setState(() {
                      destination.endDate = newDate;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            _buildDetailSection(destination.detail ?? "No details available",
                (newDetail) {
              setState(() {
                destination.detail = newDetail;
              });
            }),
            if (schedule.userId == widget.userId)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _showDeleteDestinationConfirmationDialog(destination);
                },
              ),
            const Divider(),
          ],
        );
      }).toList(),
        // Add "Add More Place" button at the bottom
        Center(
          child: ElevatedButton(
            onPressed: () {
              // Navigate to SearchPage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchPage(),
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
]
    );
  }

  Widget _buildDetailSection(String detailText, Function(String) onSave) {
    return GestureDetector(
      onTap: () => _showDetailDialog(detailText, onSave),
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
                    ..onTap = () => _showDetailDialog(detailText, onSave),
                ),
                if (isOverflowing)
                  const TextSpan(
                    text: " ...",
                    style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDeleteDestinationConfirmationDialog(Destination destination) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Destination'),
          content:
              const Text('Are you sure you want to delete this destination?'),
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
                  widget.destinations
                      .removeWhere((d) => d.id == destination.id);
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

  void _navigateToDetail(int placeId, Place place, PlaceTranslation? translation, List<PlaceMedia> mediaList) {
    Place? selectedPlace = placeList.firstWhereOrNull((place) => place.placeId == placeId);

    List<PlaceMedia> filteredMediaList = mediaList
        .where((media) => media.placeId == place.placeId)
        .toList();

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
        ),
      ),
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
    final scheduleProvider =
        Provider.of<ScheduleProvider>(context, listen: false);
    final schedules = scheduleProvider.schedules;
    return Center(
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text("Recommended Schedule"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FeaturedSchedulePage(
                    allSchedules: schedules,
                    scheduleLikes: widget.scheduleLikes,
                    destinations: widget.destinations,
                    users: widget.users,
                    userId: widget.userId,
                    onClone: (Schedule clonedSchedule,
                        List<Destination> clonedDestinations) {
                      setState(() {
                        // Add cloned schedule to ScheduleProvider
                        Provider.of<ScheduleProvider>(context, listen: false)
                            .addSchedule(clonedSchedule);
                        Provider.of<ScheduleProvider>(context, listen: false)
                            .destinations
                            .addAll(clonedDestinations);
                      });
                    },
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text("Most Schedule Like"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              showAddScheduleDialog(context,
                  (scheduleName, startDate, endDate) {
                final newSchedule = Schedule(
                  id: widget.schedules.length + 1,
                  userId: widget.userId,
                  scheduleName: scheduleName,
                  startDate: startDate,
                  endDate: endDate,
                  createdDate: DateTime.now(),
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
            label: const Text("Add Schedule"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}
