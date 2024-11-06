import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/places/place.dart';
import '../../../models/places/placetranslation.dart';
import '../../../models/schedule/destination.dart';
import '../../../models/schedule/schedule.dart';
import '../../../models/schedule/schedulelike.dart';
import '../../../models/users/users.dart';
import 'dart:ui' as ui;

class ScheduleTabbar extends StatefulWidget {
  final String userId;
  final User user;
  final List<Schedule> schedules;
  final List<ScheduleLike> scheduleLikes;
  final List<Destination> destinations;
  final Function(int scheduleId, bool isFavorited) onFavoriteToggle;

  const ScheduleTabbar({
    super.key,
    required this.userId,
    required this.user,
    required this.schedules,
    required this.scheduleLikes,
    required this.destinations,
    required this.onFavoriteToggle,
  });

  @override
  State<ScheduleTabbar> createState() => _ScheduleTabbarState();
}

class _ScheduleTabbarState extends State<ScheduleTabbar> {
  String bullet = "\u2022 ";
  DateTime? _fromDate;
  DateTime? _toDate;
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  int? _expandedIndex;
  bool _isEditingName = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  Map<int, bool> scheduleVisibility = {};
  final Set<int> favoritedScheduleIds = {};

  @override
  void initState() {
    super.initState();
    _initializeFavoriteSchedules();
    for (var schedule in widget.schedules) {
      scheduleVisibility[schedule.id] = true;
    }
  }

  @override
  void dispose() {
    _detailController.dispose();
    searchFocusNode.dispose(); // Dispose FocusNode
    _nameController.dispose(); // Dispose the controller when done
    super.dispose();
  }

  void _initializeFavoriteSchedules() {
    for (var like in widget.scheduleLikes) {
      if (like.userId == widget.userId) {
        favoritedScheduleIds.add(like.scheduleId);
      }
    }
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

  // Separate the state update for date selection from the filtering.
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
      final matchesDate = (_fromDate == null ||
              (schedule.startDate != null &&
                  schedule.startDate!.isAfter(_fromDate!))) &&
          (_toDate == null ||
              (schedule.endDate != null &&
                  schedule.endDate!.isBefore(_toDate!)));
      return matchesName && matchesDate;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context)
          .unfocus(), // Deselect TextFields when clicking outside
      child: SingleChildScrollView(
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
                _buildScheduleList(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
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
            setState(
                () {}); // Trigger filtering by refreshing the list only on button press
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

  Widget _buildDestinationDetail(String detailText, Function(String) onSave) {
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

  // Usage in your destination list:
  Widget _buildDestinationList(List<Destination> scheduleDestinations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: scheduleDestinations.asMap().entries.map((entry) {
        final destination = entry.value;
        final isLast = entry.key == scheduleDestinations.length - 1;
        final place =
            dummyPlaces.firstWhere((p) => p.placeId == destination.placeId);
        final placeTranslation =
            translations.firstWhere((t) => t.placeId == destination.placeId);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(bullet),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    placeTranslation.placeName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
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
            _buildDestinationDetail(
                destination.detail ?? "No details available", (newDetail) {
              setState(() {
                destination.detail = newDetail;
              });
            }),
            if (!isLast) const Divider(),
          ],
        );
      }).toList(),
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
                      ? initialDate.toString().split(' ')[0]
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
            onPressed: () {},
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
            onPressed: () {},
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

  Widget _buildScheduleList() {
    List<Schedule> filteredSchedules = getFilteredSchedules();
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredSchedules.length,
      itemBuilder: (context, index) {
        final schedule = filteredSchedules[index];
        final isExpanded = _expandedIndex == index;
        final userOwnsSchedule = schedule.userId == widget.userId;
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
              _expandedIndex = isExpanded ? null : index;
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
                        onTap: () {
                          setState(() {
                            _isEditingName = !_isEditingName;
                            if (_isEditingName) {
                              _nameController.text = schedule.scheduleName;
                            }
                          });
                        },
                        child: _isEditingName
                            ? TextFormField(
                          controller: _nameController,
                          onFieldSubmitted: (newValue) {
                            setState(() {
                              schedule.scheduleName = newValue;
                              _isEditingName = false;
                            });
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 8),
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
                          Flexible(
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
                          Flexible(
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
                              color: favoritedScheduleIds.contains(schedule.id)
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
                          Text(likeCount.toString(),
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 12)),
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
                  margin: EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: _buildDestinationList(scheduleDestinations),
                ),
            ],
          ),
        );
      },
    );
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
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                _deleteSchedule(scheduleId); // Delete the schedule
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _deleteSchedule(int scheduleId) {
    setState(() {
      widget.schedules.removeWhere((schedule) => schedule.id == scheduleId);
    });
  }
}
