import 'dart:math';

import 'package:flutter/material.dart';
import 'package:localtourapp/config/appConfig.dart';
import 'package:localtourapp/config/secure_storage_helper.dart';
import 'package:localtourapp/models/schedule/destination_model.dart';
import 'package:localtourapp/models/schedule/schedule_model.dart';
import 'package:localtourapp/page/detail_page/detail_page.dart';
import 'package:localtourapp/page/planned_page/planned_page_tab_bars/add_schedule_dialog.dart';
import 'package:localtourapp/page/planned_page/planned_page_tab_bars/suggest_schedule_page.dart';
import 'package:localtourapp/page/planned_page/planned_page_tab_bars/update_destination_bottom_sheet.dart';
import 'package:localtourapp/page/search_page/search_page.dart';
import 'package:localtourapp/services/schedule_service.dart';
import 'package:localtourapp/base/back_to_top_button.dart';
import 'package:localtourapp/base/weather_icon_button.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

import '../../../models/HomePage/placeCard.dart';
import '../../../models/places/place_detail_model.dart';
import '../../../services/place_service.dart';
import 'dashed_line.dart';

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
  String _languageCode = 'vi';
  @override
  bool get wantKeepAlive => true;
  final ScheduleService _scheduleService = ScheduleService();
  late List<ScheduleModel> _listSchedule;
  late List<ScheduleModel> _listScheduleInit;
  String _myUserId = '';
  bool isLoading = true;
  String _userId = '';
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;
  final FocusNode _nameFocusNode = FocusNode();
  String bullet = "\u2022 ";
  DateTime? _fromDate;
  DateTime? _toDate;
  final PlaceService _placeService = PlaceService();
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  int? _expandedIndex;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  Map<int, bool> scheduleVisibility = {};
  final Set<int> _editingScheduleIds = {};
  bool isCurrentUser = false;
  bool isDragging = false;
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _nameFocusNode.addListener(_onNameFieldFocusChange);

    fetchInit();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ModalRoute.of(context)?.isCurrent == true) {
        fetchData(); // Refresh your data here
      }
    });
  }

  Future<void> fetchInit() async {
    var languageCode =
        await SecureStorageHelper().readValue(AppConfig.language);
    String? userid = '';
    if (widget.userId == '') {
      userid = await SecureStorageHelper().readValue(AppConfig.userId);
      if (userid == null) {
        setState(() {
          _listSchedule = [];
          isLoading = false;
        });
      } else {
        _myUserId = userid;
      }
    } else {
      userid = widget.userId;
    }

    if (userid != null && userid != '') {
      _userId = userid;
      var listschedule = await _scheduleService.GetScheduleUserId(userid);
      setState(() {
        _listScheduleInit = listschedule;
        _listSchedule = listschedule;
      });
    }
    if (_myUserId == userid) {
      isCurrentUser = true;
    }
    _languageCode = languageCode!;
    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchData() async {
    try {
      var listschedule = await _scheduleService.GetScheduleUserId(_userId);

      if (!mounted) return; // Check if the widget is still mounted

      setState(() {
        _listScheduleInit = listschedule;
        _listSchedule = listschedule;
      });
    } catch (e) {
      // Handle errors here if necessary
      debugPrint("Error fetching data: $e");
    }
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
    setState(() {
      _editingScheduleIds.add(scheduleId);
    });
  }

  void _toggleFavorite(int scheduleId) async {
    var success = await _scheduleService.LikeSchedule(scheduleId);
    if (success) {
      fetchData();
    }
  }

  void _toggleVisibility(ScheduleModel schedule, String scheduleName) async {
    var result = await _scheduleService.UpdateSchedule(
        schedule.id,
        scheduleName != '' ? scheduleName : schedule.scheduleName,
        null,
        null,
        !schedule.isPublic);
    if (result) {
      fetchData();
    }
  }

  Future<void> updatedSchedule(
      ScheduleModel newSchedule, String? scheduleName) async {
    var result = await _scheduleService.UpdateSchedule(
      newSchedule.id,
      scheduleName!.isNotEmpty ? scheduleName : newSchedule.scheduleName,
      newSchedule.startDate, // Can now be null
      newSchedule.endDate, // Can now be null
      newSchedule.isPublic,
    );

    if (result) {
      _editingScheduleIds.clear();
      fetchData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _languageCode == 'vi'
                ? 'Cập nhật lịch trình thành công.'
                : 'Schedule updated successfully.',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _languageCode == 'vi'
                ? 'Cập nhật lịch trình không thành công.'
                : 'Failed to update schedule.',
          ),
        ),
      );
    }
  }

  Future<void> updateScheduleDates(ScheduleModel schedule,
      DateTime? newStartDate, DateTime? newEndDate) async {
    // Update the schedule with the new dates
    var result = await _scheduleService.UpdateSchedule(
      schedule.id,
      schedule.scheduleName,
      newStartDate,
      newEndDate,
      schedule.isPublic,
    );

    if (result) {
      setState(() {
        // Update the schedule in the local list
        schedule.startDate = newStartDate;
        schedule.endDate = newEndDate;
      });
    }
  }

  void _showDetailDialog(
      String initialText, Function(String) onSave, bool isCurrentUser) {
    _detailController.text = initialText;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_languageCode == 'vi'
              ? (isCurrentUser ? 'Sửa chi tiết' : 'Chi tiết')
              : (isCurrentUser ? 'Edit Detail' : 'Detail')),
          content: isCurrentUser
              ? TextFormField(
                  controller: _detailController,
                  maxLines: 10,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText: _languageCode == 'vi'
                        ? " Nhập tối đa 500 từ"
                        : "Enter detail (max 500 words)",
                    border: const OutlineInputBorder(),
                  ),
                )
              : TextFormField(
                  controller: _detailController,
                  readOnly: true,
                  maxLines: 10,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(_languageCode == 'vi' ? 'Đóng' : 'Close'),
            ),
            if (isCurrentUser)
              TextButton(
                onPressed: () {
                  final updatedText = _detailController.text;
                  onSave(
                      updatedText); // Pass empty string if all text is deleted
                  Navigator.of(context).pop();
                },
                child: Text(_languageCode == 'vi' ? 'Lưu' : 'Save'),
              ),
          ],
        );
      },
    );
  }

  void _onDateSelected(DateTime? newDate, bool isFromDate) {
    if (isFromDate) {
      _fromDate = newDate;
      // If endDate is set, ensure it's after the new startDate
      if (_toDate != null && newDate != null && _toDate!.isBefore(newDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _languageCode == 'vi'
                  ? 'Ngày kết thúc phải sau ngày bắt đầu.'
                  : 'End date must be after start date.',
            ),
          ),
        );
      }
    } else {
      _toDate = newDate;
      // If startDate is set, ensure endDate is after startDate
      if (_fromDate != null &&
          newDate != null &&
          newDate.isBefore(_fromDate!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _languageCode == 'vi'
                  ? 'Ngày kết thúc phải sau ngày bắt đầu.'
                  : 'End date must be after start date.',
            ),
          ),
        );
      }
    }
    setState(() {});
  }

  void _swapDestination(DestinationModel old, DestinationModel newD) async {
    var result = await _scheduleService.UpdateDestination(
        old.id,
        old.scheduleId,
        newD.placeId,
        newD.startDate,
        newD.endDate,
        newD.detail,
        newD.isArrived);
    var resuldt = await _scheduleService.UpdateDestination(
        newD.id,
        newD.scheduleId,
        old.placeId,
        old.startDate,
        old.endDate,
        old.detail,
        old.isArrived);
    fetchData();
  }

  void _ChoosePlace(
    PlaceCardModel place,
    int scheduleId,
    DateTime? startDate,
    DateTime? endDate,
    String? detail,
    bool? isArrived,
  ) async {
    var result = await _scheduleService.CreateDestination(
        scheduleId, place.placeId, startDate, endDate, detail, isArrived);
    if (result) {
      fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Stack(
            children: [
              GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  physics: const ClampingScrollPhysics(),
                  children: [
                          _buildFilterSection(),
                          const Divider(
                            color: Colors.grey, // Color of the divider
                            thickness: 1, // Thickness of the divider
                          ),
                          if (isCurrentUser) ...[
                            _buildButtonsSection(),
                          ],
                          _buildScheduleSection(_listSchedule),
                          const SizedBox(height: 100),
                        ],
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
                  bottom: 30,
                  left: MediaQuery.of(context).size.width / 2.3,
                  child: isDragging
                      ? Align(
                          alignment: Alignment.bottomCenter,
                          child: DragTarget<DestinationModel>(
                            builder: (context, candidateData, rejectedData) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: candidateData.isNotEmpty
                                      ? Colors.redAccent
                                      : Colors.grey.shade400,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              );
                            },
                            onWillAcceptWithDetails:
                                (DragTargetDetails<DestinationModel> details) {
                              return true;
                            },
                            onAcceptWithDetails:
                                (DragTargetDetails<DestinationModel>
                                    details) async {
                              final draggedDestination = details.data;
                              setState(() {
                                _showDeleteDestinationConfirmationDialog(
                                    draggedDestination);
                              });
                            },
                          ),
                        )
                      : const SizedBox()),
              Positioned(
                bottom: 12,
                left: 160,
                child: AnimatedOpacity(
                  opacity: _showBackToTopButton ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: _showBackToTopButton
                      ? BackToTopButton(
                          onPressed: _scrollToTop,
                          languageCode: _languageCode,
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Search Field
          TextField(
            controller: searchController,
            focusNode: searchFocusNode,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              labelText:
                  _languageCode == 'vi' ? 'Tìm theo tên' : "Search by name",
              labelStyle: const TextStyle(fontSize: 14),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.grey),
              ),
            ),
            onChanged: (value) {
              setState(() {}); // Trigger filtering as user types
            },
          ),
          const SizedBox(height: 16),
          // Date Fields
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildDateField(
                  _languageCode == 'vi' ? 'Từ ngày' : "From Date",
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
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDateField(
                  _languageCode == 'vi' ? 'Tới ngày' : "To Date",
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
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Search Button
          Center(
            child: GestureDetector(
              onTap: () {
                _filterSchedule(); // Filter based on current inputs
                setState(() {}); // Trigger the UI update with current filters
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.white, Color(0xFFDCA1A1)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black, width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(2, 4),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.filter_alt, color: Colors.black),
                    const SizedBox(width: 8),
                    Text(
                      _languageCode == 'vi' ? 'Tìm kiếm' : "Search",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection(List<ScheduleModel> filteredSchedules) {
    if (filteredSchedules.isEmpty) {
      return Center(
        child: Text(
          _languageCode == 'vi'
              ? 'Không tìm thấy lịch trình'
              : "No schedules found.",
          style: const TextStyle(fontSize: 18),
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
        final bool isOwner = schedule.userId == _myUserId;
        bool isVisible = schedule.isPublic || isOwner;

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
                  side: BorderSide(color: Colors.black.withOpacity(0.5), width: 1.5),
                ),
                margin: const EdgeInsets.only(bottom: 10),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.yellow[200]!,
                        Colors.pink[200]!,
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  if (isOwner) {
                                    _toggleEditing(schedule.id);
                                    _nameController.text = schedule.scheduleName;
                                  }
                                },
                                child: isEditingName
                                    ? TextFormField(
                                  controller: _nameController,
                                  focusNode: _nameFocusNode,
                                  onFieldSubmitted: (newValue) {
                                    _saveScheduleName();
                                  },
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 10),
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
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16, color: Colors.grey[800]),
                            const SizedBox(width: 8),
                            Text(
                              _languageCode == 'vi'
                                  ? 'Ngày tạo: ${DateFormat('yyyy-MM-dd').format(schedule.createdDate)}'
                                  : "Created date: ${DateFormat('yyyy-MM-dd').format(schedule.createdDate)}",
                              style: TextStyle(color: Colors.grey[800]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDateField(
                                _languageCode == 'vi' ? 'Từ ngày' : "From Date",
                                true,
                                schedule.startDate,
                                isOwner
                                    ? (newDate) {
                                  updateScheduleDates(
                                      schedule, newDate, schedule.endDate);
                                }
                                    : (newDate) {},
                                clearable: isOwner,
                                onClear: isOwner
                                    ? () {
                                  updateScheduleDates(
                                      schedule, null, schedule.endDate);
                                }
                                    : () {},
                                isOwner: isOwner,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildDateField(
                                _languageCode == 'vi' ? 'Tới ngày' : "To Date",
                                false,
                                schedule.endDate,
                                isOwner
                                    ? (newDate) {
                                  updateScheduleDates(schedule,
                                      schedule.startDate, newDate);
                                }
                                    : (newDate) {},
                                clearable: isOwner,
                                onClear: isOwner
                                    ? () {
                                  updateScheduleDates(
                                      schedule, schedule.startDate, null);
                                }
                                    : () {},
                                isOwner: isOwner,
                              ),
                            ),
                          ],
                        ),
                        if (isEditingName)
                          Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check_circle, color: Colors.green),
                                  onPressed: () {
                                    updatedSchedule(schedule, _nameController.text);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _editingScheduleIds.remove(schedule.id);
                                    });
                                  },
                                ),
                              ],
                          ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    schedule.isPublic
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: schedule.isPublic
                                        ? Colors.blue
                                        : Colors.red,
                                  ),
                                  onPressed: isOwner
                                      ? () => _toggleVisibility(
                                      schedule, _nameController.text)
                                      : null,
                                ),
                                IconButton(
                                  icon: Icon(
                                    schedule.isLiked
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _toggleFavorite(schedule.id),
                                ),
                                Text(
                                  schedule.totalLikes.toString(),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            if (isOwner)
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.grey),
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
              ),
              if (isExpanded)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.black.withOpacity(0.2), width: 1),
                  ),
                  child: Column(
                    children: [
                      _buildDestinationGrid(schedule.destinations, schedule),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(int scheduleId, String scheduleName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text(_languageCode == 'vi' ? 'Xác nhận xóa' : 'Confirm Delete'),
          content: Text(_languageCode == 'vi'
              ? 'Bạn có muốn xóa "$scheduleName" không?'
              : 'Are you sure you want to delete "$scheduleName"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(_languageCode == 'vi' ? 'Không' : 'No'),
            ),
            TextButton(
              onPressed: () {
                _deleteSchedule(scheduleId);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _languageCode == 'vi'
                          ? 'Lịch trình $scheduleName đã được xóa'
                          : 'Schedule $scheduleName has been deleted',
                    ),
                  ),
                );
              },
              child: Text(_languageCode == 'vi' ? 'Có' : 'Yes'),
            ),
          ],
        );
      },
    );
  }

  void _deleteSchedule(int scheduleId) async {
    var result = await _scheduleService.DeleteSchedule(scheduleId);
    if (result) {
      fetchData();
    }
  }

  Widget _buildDestinationGrid(
      List<DestinationModel> destinations, ScheduleModel schedule) {
    List<Widget> rows = [];
    int index = 0;
    int columns = 3;
    double connectorHeight = 45; // Vertical connector height
    double circleSize = 50; // Diameter of CircleAvatar

    // Add a placeholder for the add button at the end of the destinations list
    List<DestinationModel?> allItems = List.from(destinations);
    if (isCurrentUser) {
      allItems.add(null); // Add a null item to represent the add button
    }

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

        Widget itemWidget;

        int addButtonIndex = index + i;

        if (destination != null) {
          // Existing destination item

          // Wrap the Checkbox with GestureDetector for onLongPress to show delete dialog
          Widget checkboxWidget = Checkbox(
            value: destination.isArrived,
            onChanged: (bool? value) async {
              var result = await _scheduleService.UpdateDestination(
                destination.id,
                destination.scheduleId,
                destination.placeId,
                destination.startDate,
                destination.endDate,
                destination.detail,
                value,
              );
              if (result) {
                fetchData();
              }
            },
            activeColor: const Color(0xFF008080),
            checkColor: Colors.white,
          );

          // Wrap the CircleAvatar with GestureDetector for onTap to show details
          Widget circleAvatar = GestureDetector(
            onTap: () => _showDestinationDetails(destination,),
            child: Column(
              children: [
                CircleAvatar(
                  radius: circleSize / 2,
                  backgroundImage: NetworkImage(
                    destination.placePhotoDisplay ??
                        'assets/images/default.png',
                  ),
                  backgroundColor: Colors.grey,
                ),
                SizedBox(
                  width: 72,
                  child: Text(
                    destination.placeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );

          // Build the imageWidget that contains the Checkbox and CircleAvatar
          Widget imageWidget = Column(
            mainAxisSize: MainAxisSize.min, // Take minimum space
            children: [
              if (isCurrentUser) checkboxWidget,
              circleAvatar,
            ],
          );

          // Wrap the imageWidget with LongPressDraggable
          Widget draggable = LongPressDraggable<DestinationModel>(
            data: destination,
            feedback: Material(
              color: Colors.transparent,
              child:
                  imageWidget, // Drag the whole widget, including Checkbox and CircleAvatar
            ),
            childWhenDragging: Opacity(
              opacity: 0.5,
              child: imageWidget,
            ),
            onDragStarted: () {
              setState(() {
                isDragging = true;
              });
            },
            onDragEnd: (_) {
              setState(() {
                isDragging = false;
              });
            },
            child: DragTarget<DestinationModel>(
              builder: (BuildContext context, List<dynamic> accepted,
                  List<dynamic> rejected) {
                return imageWidget;
              },
              onWillAcceptWithDetails:
                  (DragTargetDetails<DestinationModel> details) {
                // You can use details to get more information if needed
                return true;
              },
              onAcceptWithDetails:
                  (DragTargetDetails<DestinationModel> details) async {
                final draggedDestination = details.data;
                setState(() {
                  // Swap positions of draggedDestination and destination
                  int oldIndex = destinations.indexOf(draggedDestination);
                  int newIndex = destinations.indexOf(destination);

                  if (oldIndex != -1 && newIndex != -1) {
                    _swapDestination(draggedDestination, destination);
                  }
                });
              },
            ),
          );

          itemWidget = draggable;
        } else {
          Widget addButtonContent = GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchPage(
                    forAddingDestination: true,
                    scheduleId: schedule.id,
                    onPlaceSelected: (p0) {
                      _ChoosePlace(
                        p0,
                        schedule.id,
                        destination?.startDate,
                        destination?.endDate,
                        destination!.detail,
                        destination.isArrived,
                      );
                    },
                  ),
                ),
              );

              if (result == true) {
                fetchData();
              }
            },
            child: const Icon(Icons.add_circle, size: 30),
          );

          // Add padding or SizedBox based on the position
          if ((addButtonIndex + 1) % 6 == 4) {
            // Positions: 4, 10, 16, 22, ...
            itemWidget = Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                addButtonContent,
                const SizedBox(width: 21), // Right padding/SizedBox
              ],
            );
          } else if ((addButtonIndex + 1) % 6 == 1) {
            // Positions: 7, 13, 19, 25, ...
            itemWidget = Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 21), // Left padding/SizedBox
                addButtonContent,
              ],
            );
          } else {
            // Default case (no special padding)
            itemWidget = Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                addButtonContent,
              ],
            );
          }
        }


        rowWidgets.add(itemWidget);

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

      // Reverse the row if it's an even row
      if (isEvenRow) {
        rowWidgets = rowWidgets.reversed.toList();
      }

      // Build the row widget
      Widget rowWidget = Container(
        padding: !isEvenRow
            ? const EdgeInsets.only(left: 0)
            : const EdgeInsets.only(right: 0),
        child: Row(
          mainAxisAlignment:
              isEvenRow ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: rowWidgets,
        ),
      );

      rows.add(rowWidget);

      // Add vertical dashed connector under the last item of the previous row
      if (index + columns < allItems.length) {
        rows.add(
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: isEvenRow ? Alignment.centerLeft : Alignment.centerRight,
                  child: Padding(
                    // Add conditional padding for left or right alignment
                    padding: isEvenRow
                        ? const EdgeInsets.only(left: 11.0)   // Padding for left alignment
                        : const EdgeInsets.only(right: 11.0), // Padding for right alignment
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
              ),
            ],
          ),
        );
      }
      index += columns;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: rows,
    );
  }

  Future<PlaceDetailModel> _fetchPlaceDetail(int placeId) async {
    return await _placeService.GetPlaceDetail(placeId);
  }

  // 1) Only accept a DestinationModel
  Future<void> _showDestinationDetails(DestinationModel destination) async {
    // 2) Fetch place detail using destination.placeId
    final fetchedPlaceDetail = await _fetchPlaceDetail(destination.placeId);

    // 3) Show bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return UpdateDestinationBottomSheet(
          placeDetail: fetchedPlaceDetail,
          existingDestination: destination,
        );
      },
    ).then((result) async {
      if (result != null) {
        final DateTime? startDate = result['startDate'];
        final DateTime? endDate   = result['endDate'];
        final String    detail    = result['detail'];
        // 4) Update
        await _scheduleService.UpdateDestination(
          destination.id,
          destination.scheduleId,      // Use destination's scheduleId
          destination.placeId,         // Or fetchedPlaceDetail.id if needed
          startDate,
          endDate,
          detail,
          false,
        );
        fetchData();
      }
    });
  }


  Widget _buildDestinationDetailSheet(
    DestinationModel destination,
    Function(DateTime?) updateStartDate,
    Function(DateTime?) updateEndDate,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar at the top
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            // Destination Name
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailPage(placeId: destination.placeId),
                  ),
                );
              },
              child: Text(
                destination.placeName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Destination Image
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailPage(placeId: destination.placeId),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  destination.placePhotoDisplay ?? 'assets/images/default.png',
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.broken_image,
                            color: Colors.red, size: 50),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Date Fields
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    _languageCode == 'vi' ? 'Từ ngày' : "Start Date",
                    true,
                    destination.startDate,
                    (newDate) => _onDateSelectedForDestination(
                        newDate, true, destination),
                    clearable: isCurrentUser,
                    onClear: () =>
                        _onDateSelectedForDestination(null, true, destination),
                    isOwner: isCurrentUser,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDateField(
                    _languageCode == 'vi' ? 'Tới ngày' : "End Date",
                    false,
                    destination.endDate,
                    (newDate) => _onDateSelectedForDestination(
                        newDate, false, destination),
                    clearable: isCurrentUser,
                    onClear: () =>
                        _onDateSelectedForDestination(null, false, destination),
                    isOwner: isCurrentUser,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Detail Section
            _buildDetailSection(
              destination.detail,
              (newDetail) async {
                if (isCurrentUser) {
                  await _validateAndSaveDetail(destination, newDetail);
                }
              },
              isCurrentUser,
            ),
            const SizedBox(height: 20),
            // Save Button
            if (isCurrentUser)
              SizedBox(
                width: 100,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await _validateAndSaveDetail(
                        destination, destination.detail);
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.save,
                    color: Colors.white,
                  ),
                  label: Text(
                    _languageCode == 'vi' ? 'Lưu' : "Save",
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            const SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }

  Future<void> _validateAndSaveDetail(
      DestinationModel destination, String newDetail) async {
    bool hasStartDate = destination.startDate != null;
    bool hasEndDate = destination.endDate != null;

    if (!hasStartDate && !hasEndDate) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _languageCode == 'vi'
                ? 'Vui lòng chọn ít nhất một ngày bắt đầu hoặc ngày kết thúc.'
                : 'Please select at least a start date or an end date.',
          ),
        ),
      );
      return;
    }

    if (hasStartDate && hasEndDate) {
      if (destination.startDate!.isAfter(destination.endDate!) ||
          destination.startDate!.isAtSameMomentAs(destination.endDate!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _languageCode == 'vi'
                  ? 'Ngày bắt đầu phải trước ngày kết thúc.'
                  : 'Start date must be before end date.',
            ),
          ),
        );
        return;
      }

      if (destination.startDate!.isBefore(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _languageCode == 'vi'
                  ? 'Ngày bắt đầu phải sau thời điểm hiện tại.'
                  : 'Start date must be in the future.',
            ),
          ),
        );
        return;
      }
    }

    if (hasStartDate && !hasEndDate) {
      if (destination.startDate!.isBefore(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _languageCode == 'vi'
                  ? 'Ngày bắt đầu phải sau thời điểm hiện tại.'
                  : 'Start date must be in the future.',
            ),
          ),
        );
        return;
      }
    }

    if (!hasStartDate && hasEndDate) {
      if (destination.endDate!.isBefore(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _languageCode == 'vi'
                  ? 'Ngày kết thúc phải sau thời điểm hiện tại.'
                  : 'End date must be in the future.',
            ),
          ),
        );
        return;
      }
    }
    debugPrint('Before API Call - StartDate: ${destination.startDate}');
    debugPrint('Before API Call - EndDate: ${destination.endDate}');
    // Save destination
    var result = await _scheduleService.UpdateDestination(
      destination.id,
      destination.scheduleId,
      destination.placeId,
      destination.startDate,
      destination.endDate,
      newDetail,
      destination.isArrived,
    );

    if (result) {
      fetchData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _languageCode == 'vi'
                ? 'Cập nhật điểm đến không thành công.'
                : 'Failed to update destination.',
          ),
        ),
      );
    }
    debugPrint('After API Call - StartDate: ${destination.startDate}');
    debugPrint('After API Call - EndDate: ${destination.endDate}');
  }

  void _onDateSelectedForDestination(
      DateTime? newDate, bool isFromDate, DestinationModel destination) {
    if (isFromDate) {
      destination.startDate = newDate;
      // If endDate is set, ensure it's after the new startDate
      if (destination.endDate != null &&
          newDate != null &&
          destination.endDate!.isBefore(newDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _languageCode == 'vi'
                  ? 'Ngày kết thúc phải sau ngày bắt đầu.'
                  : 'End date must be after start date.',
            ),
          ),
        );
        // Optionally, reset endDate
        destination.endDate = null;
      }
    } else {
      destination.endDate = newDate;
      // If startDate is set, ensure endDate is after startDate
      if (destination.startDate != null &&
          newDate != null &&
          newDate.isBefore(destination.startDate!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _languageCode == 'vi'
                  ? 'Ngày kết thúc phải sau ngày bắt đầu.'
                  : 'End date must be after start date.',
            ),
          ),
        );
        // Optionally, reset endDate
        destination.endDate = null;
      }
    }
    setState(() {});
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
            text: detailText.isNotEmpty
                ? detailText
                : _languageCode == 'vi'
                    ? "Nhấn để thêm chi tiết..."
                    : "Tap to add details...", // Show hint text if empty
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
              Text(
                _languageCode == 'vi' ? 'Chi tiết' : "Detail:",
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
                        : _languageCode == 'vi'
                            ? "Nhấn để thêm chi tiết..."
                            : "Tap to add details...", // Hint text if empty
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

  void _showDeleteDestinationConfirmationDialog(DestinationModel destination) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_languageCode == 'vi'
              ? 'Xóa điểm này?'
              : 'Delete this Destination?'),
          content: Text(
              'Are you sure you want to delete "${destination.placeName}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(_languageCode == 'vi' ? 'Thoát' : 'Cancel'),
            ),
            TextButton(
              onPressed: () async {
                var result =
                    await _scheduleService.DeleteDestination(destination.id);
                if (result) {
                  fetchData();
                }
                Navigator.of(context).pop();
              },
              child: Text(_languageCode == 'vi' ? 'Xóa' : 'Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _filterSchedule() async {
    String searchText = searchController.text.toLowerCase();
    List<ScheduleModel> search = _listScheduleInit; // Default to all schedules

    // Apply search text filter if not empty
    if (searchText.isNotEmpty) {
      search = search
          .where((schedule) =>
              schedule.scheduleName.toLowerCase().contains(searchText))
          .toList();
    }

    // Apply date filters if set
    if (_fromDate != null) {
      search = search.where((schedule) {
        if (schedule.startDate != null) {
          return schedule.startDate!.isAfter(_fromDate!);
        }
        return false;
      }).toList();
    }

    if (_toDate != null) {
      search = search.where((schedule) {
        if (schedule.endDate != null) {
          return schedule.endDate!.isBefore(_toDate!);
        }
        return false;
      }).toList();
    }

    setState(() {
      _listSchedule = search;
    });
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
        if (!isOwner) return; // Prevent editing if not the owner

        DateTime? selectedDate = initialDate;

        DateTime firstDate = isStartDate
            ? (DateTime.now()).add(const Duration(minutes: 1))
            : (initialDate != null
                ? initialDate.add(const Duration(minutes: 1))
                : DateTime.now().add(const Duration(minutes: 1)));

        final DateTime? date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? firstDate,
          firstDate: firstDate,
          lastDate: DateTime(2100),
        );

        if (date != null) {
          TimeOfDay initialTime = initialDate != null
              ? TimeOfDay.fromDateTime(initialDate)
              : TimeOfDay.now();

          final TimeOfDay? time = await showTimePicker(
            context: context,
            initialTime: initialTime,
          );

          if (time != null) {
            selectedDate = DateTime(
              date.year,
              date.month,
              date.day,
              time.hour,
              time.minute,
            );

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
                  hintStyle: TextStyle(
                    fontSize: 12,
                    color: initialDate != null ? Colors.black : Colors.grey,
                  ),
                  border: const OutlineInputBorder(),
                  suffixIcon: (initialDate == null && isOwner)
                      ? const Icon(Icons.calendar_today)
                      : null,
                ),
              ),
            ),
          ),
          if (clearable && initialDate != null && isOwner)
            Positioned(
              right: 5,
              top: 3,
              child: GestureDetector(
                onTap: () {
                  onDateChanged(null); // Clear the date
                  onClear?.call();
                },
                child: const Icon(Icons.close, size: 22, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _addSchedule(
      String scheduleName, DateTime? startDate, DateTime? endDate) async {
    var result =
        await _scheduleService.CreateSchedule(scheduleName, startDate, endDate);
    if (result) {
      fetchData();
    }
  }

  Widget _buildButtonsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          onTap: () {
            showAddScheduleDialog(context, (scheduleName, startDate, endDate) {
              _addSchedule(scheduleName, startDate, endDate);
            }, _listScheduleInit);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange[300]!, Colors.red[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(2, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  _languageCode == 'vi' ? 'Thêm lịch trình' : "Add Schedule",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: _showSuggestScheduleBottomSheet,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[300]!, Colors.teal[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(2, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lightbulb, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  _languageCode == 'vi' ? 'Gợi ý' : "Suggestion",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
        return SuggestSchedulePage(
          userId: widget.userId,
          voidCallback: () {
            fetchData();
          },
        );
      },
    );
  }
}
