import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // Needed for TapGestureRecognizer
import 'package:localtourapp/config/appConfig.dart';
import 'package:localtourapp/config/secure_storage_helper.dart';
import 'package:localtourapp/models/schedule/destination_model.dart';
import 'package:localtourapp/models/schedule/schedule_model.dart';
import 'package:localtourapp/page/detail_page/detail_page.dart';
import 'package:localtourapp/page/planned_page/planned_page_tab_bars/add_schedule_dialog.dart';
import 'package:localtourapp/page/planned_page/planned_page_tab_bars/suggest_schedule_page.dart';
import 'package:localtourapp/page/search_page/search_page.dart';
import 'package:localtourapp/services/schedule_service.dart';
import 'package:localtourapp/base/back_to_top_button.dart';
import 'package:localtourapp/base/weather_icon_button.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class ScheduleTabbar extends StatefulWidget {
  final String userId;


  const ScheduleTabbar({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<ScheduleTabbar> createState() => _ScheduleTabbarState();
}

class _ScheduleTabbarState extends State<ScheduleTabbar>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final ScheduleService _scheduleService = ScheduleService();
  late List<ScheduleModel> _listSchedule;
  late List<ScheduleModel> _listScheduleInit;
  String _myUserId = '';
  bool isLoading = true;
  late String _userId;
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
  bool isCurrentUser = false;
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _nameFocusNode.addListener(_onNameFieldFocusChange);
    
    fetchInit();
  }

  Future<void> fetchInit() async{
    String? userid = '';
    if(widget.userId == ''){
        userid = await SecureStorageHelper().readValue(AppConfig.userId);
      if(userid == null){
        setState(() {
          _listSchedule = [];
          isLoading = false;
        });
        return;
      }
      _myUserId = userid;
    }else{
      userid = widget.userId;
    }

    var listschedule = await _scheduleService.getListSchedule(userid);
    if(_myUserId == userid){
      isCurrentUser = true;
    }
    _userId= userid;
    setState(() {
      _listScheduleInit = listschedule;
      _listSchedule = listschedule;
      isLoading = false;
    });
  }


  Future<void> fetchData() async {
    var listschedule = await _scheduleService.getListSchedule(_userId);
    setState(() {
      _listScheduleInit = listschedule;
      _listSchedule = listschedule;
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

        setState(() {
          _editingScheduleIds.remove(scheduleId);
        });
      }

  }

  void _toggleEditing(int scheduleId) {
    _editingScheduleIds.add(scheduleId);
  }

  void _toggleFavorite(int scheduleId) async {
    var success = await _scheduleService.LikeSchedule(scheduleId);
    if(success){
      fetchData();
    }
  }

  void _toggleVisibility(ScheduleModel schedule, String scheduleName) async {
    var result = await _scheduleService.UpdateSchedule(schedule.id, scheduleName != ''? scheduleName:schedule.scheduleName, null, null, !schedule.isPublic);
    if(result){
      fetchData();
    }
  }

  void _EditPlaceName(ScheduleModel schedule, String scheduleName) async {
    var result = await _scheduleService.UpdateSchedule(schedule.id, scheduleName != ''? scheduleName:schedule.scheduleName, schedule.startDate, schedule.endDate, schedule.isPublic);
    if(result){
      fetchData();
    }
  }

  void _showDetailDialog(
      String initialText, Function(String) onSave, bool isCurrentUser) {
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
              : TextFormField(
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
      if (isFromDate) {
        _fromDate = newDate;
      } else {
        _toDate = newDate;
      }
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Fetch all schedules from ScheduleProvider
    return
      isLoading?const Center(child: CircularProgressIndicator()):
      Stack(
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
                    _buildScheduleSection(_listSchedule),
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
            _filterSchedule();

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

  Widget _buildScheduleSection(List<ScheduleModel> filteredSchedules) {


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
          final bool isOwner = schedule.userId == _myUserId;
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
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Schedule name, editing, visibility, favorite toggling, and like count
                        GestureDetector(
                          onTap: () => _toggleEditing(schedule.id),
                          child: isEditingName
                              ? TextFormField(
                                  controller: _nameController,
                                  focusNode: _nameFocusNode,
                                  onFieldSubmitted: (newValue) {
                                    _saveScheduleName();
                                    _EditPlaceName(schedule,newValue);
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
                                  _EditPlaceName(schedule,_nameController.text);
                                },
                                clearable: true,
                                onClear: () {
                                  setState(() {
                                    schedule.startDate =
                                        null; // Correctly clears startDate
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
                                  _EditPlaceName(schedule,_nameController.text);
                                },
                                clearable: true,
                                onClear: () {
                                  setState(() {
                                    schedule.endDate =
                                        null; // Correctly clears endDate
                                  });
                                },
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
                                          schedule.isPublic
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: schedule.isPublic? Colors.blue : Colors.red,
                                ),
                                onPressed: isOwner
                                    ? () => _toggleVisibility(schedule, _nameController.text)
                                    : null, // Ensure only the owner can toggle visibility
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
                                      onPressed: () =>
                                          _toggleFavorite(schedule.id),
                                    ),
                                    Text(
                                      schedule.totalLikes.toString(),
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 12),
                                    ),
                                  ],
                                ),

                            Row(
                              children: [
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
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: _buildDestinationList(schedule.destinations),
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

  void _deleteSchedule(int scheduleId) async {
    var result = await _scheduleService.DeleteSchedule(scheduleId);
    if(result){
      fetchData();
    }
  }

  Widget _buildDestinationList(
      List<DestinationModel> scheduleDestinations) {


    void updateStartDate(DestinationModel destination, DateTime? newDate) {
      setState(() {
        destination.startDate = newDate;
      });
    }

    void updateEndDate(DestinationModel destination, DateTime? newDate) {
      setState(() {
        destination.endDate = newDate;
      });
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ...scheduleDestinations.map((destination) {


        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                _navigateToDetail(
                  destination.placeId,
                );
              },
              onLongPress: () {
                //DeleteIconButton(
                //                     icon: const Icon(Icons.delete, color: Colors.red),
                //                     onPressed: () {
                 _showDeleteDestinationConfirmationDialog(destination);
                //                     },
                //                   ),


              },
              child: Row(
                children: [
                  Text(bullet),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      destination.placeName ?? "Unknown Place",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      destination.placePhotoDisplay ?? 'assets/images/default.png',
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey,
                        child: const Icon(Icons.image, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
            const SizedBox(height: 5),
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
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // isArrived checkbox
                  Checkbox(
                    value: destination.isArrived,
                    onChanged: (bool? value)  async {
                    var result = await _scheduleService.UpdateDestination(destination.id, destination.scheduleId,destination.placeId ,null, null, destination.detail, value);
                    if(result){
                      fetchData();
                    }
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

  Widget _buildDetailSection(
      String detailText, Function(String) onSave, bool isCurrentUser) {
    return GestureDetector(
      onTap: () {
        _showDetailDialog(detailText, onSave, isCurrentUser);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final textSpan = TextSpan(
            text: "Detail:\n",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
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

  void _showDeleteDestinationConfirmationDialog(
      DestinationModel destination) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Destination'),
          content: Text('Are you sure you want to delete "${destination.placeName}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: ()  async {
                var result = await _scheduleService.DeleteDestination(destination.id);
                if(result){
                  fetchData();
                }
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }


  void _navigateToDetail(int placeId) {


    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailPage(
          placeId: placeId,
        ),
      ),
    );
  }

  Future<void> _filterSchedule() async{
    String searchText = searchController.text.toLowerCase();
    var search = _listScheduleInit;
    if(searchText != null && searchText != ''){
      search = search.where((element) => element.scheduleName.toLowerCase().contains(searchText),).toList();
    }
    if(_fromDate != null){
      search = search.where((element) {
        if(element.startDate != null){
          return element.startDate!.isAfter(_fromDate!);
        }
        return false;
      }).toList();
    }

    if(_toDate != null){
      search = search.where((element) {
        if(element.endDate != null){
          return element.endDate!.isBefore(_fromDate!);
        }
        return false;
      }).toList();
    }

    setState(() {
      _listSchedule = search;
    });

    /* widget.schedules.where((schedule) {
      final matchesName =
      schedule.scheduleName.toLowerCase().contains(searchText);
      final matchesDate =
          (_fromDate == null || schedule.createdAt.isAfter(_fromDate!)) &&
              (_toDate == null || schedule.createdAt.isBefore(_toDate!));*/
  }

  Widget _buildDateField(
    String labelText,
    bool isStartDate,
    DateTime? initialDate,
    Function(DateTime?) onDateChanged, {
    bool clearable = false,
    VoidCallback? onClear,
    bool isOwner = true,
  }) {
    return GestureDetector(
      onTap: () async {
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

            final TimeOfDay? time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(selectedDate),
            );

            if (time != null) {
              selectedDate = DateTime(
                  date.year, date.month, date.day, time.hour, time.minute);
            } else {
              selectedDate = DateTime(
                  date.year, date.month, date.day, 0, 0); // Default time
            }

            onDateChanged(selectedDate);
          }
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
                      ? DateFormat('yyyy-MM-dd HH:mm').format(initialDate)
                      : labelText,
                  hintStyle: const TextStyle(fontSize: 12),
                  border: const OutlineInputBorder(),
                  suffixIcon:(initialDate == null) ? Icon(Icons.calendar_today) : null,
                ),
              ),
            ),
          ),
          if (clearable && initialDate != null)
            Positioned(
              right: 5,
              top: 3,
              child: GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close, size: 22, color: Colors.grey[600]),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _addSchedule(String scheduleName, DateTime? startDate, DateTime? endDate) async{
    var result = await _scheduleService.CreateSchedule(scheduleName, startDate, endDate);
    if(result){
      fetchData();
    }
  }

  Widget _buildButtonsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            showAddScheduleDialog(context, (scheduleName, startDate, endDate) {

              _addSchedule(scheduleName,startDate,endDate);
            });
          },
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            "Add Schedule",
            style: TextStyle(fontSize: 13.6),
          ),
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
          label: const Text(
            "Suggest Schedule",
            style: TextStyle(fontSize: 14),
          ),
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
