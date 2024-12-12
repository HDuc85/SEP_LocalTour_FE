import 'dart:math';

import 'package:flutter/material.dart';
import 'package:localtourapp/config/appConfig.dart';
import 'package:localtourapp/config/secure_storage_helper.dart';
import 'package:localtourapp/models/HomePage/placeCard.dart';
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
      //  fetchData(); // Refresh your data here
      }
    });
  }

  Future<void> fetchInit() async {
    var languageCode = await SecureStorageHelper().readValue(AppConfig.language);
    String? userid = '';
    if (widget.userId == '') {
      userid = await SecureStorageHelper().readValue(AppConfig.userId);
      if (userid == null) {
        setState(() {
          _listSchedule = [];
          isLoading = false;
        });
      }else{
        _myUserId = userid;
      }
    } else {
      userid = widget.userId;
    }

    if(userid != null && userid != ''){
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
    var listschedule = await _scheduleService.GetScheduleUserId(_userId);

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

  void _editPlaceName(ScheduleModel schedule, String scheduleName) async {
    // var result = await _scheduleService.UpdateSchedule(
    //     schedule.id,
    //     scheduleName != '' ? scheduleName : schedule.scheduleName,
    //     schedule.startDate,
    //     schedule.endDate,
    //     schedule.isPublic);
    // if (result) {
    //   fetchData();
    // }
  }

  void updatedSchedule(ScheduleModel newSchedule,String scheduleName) async {
    var result = await _scheduleService.UpdateSchedule(
        newSchedule.id,
        scheduleName != '' ? scheduleName : newSchedule.scheduleName,
        newSchedule.startDate,
        newSchedule.endDate,
        newSchedule.isPublic);
    if (result) {
      _editingScheduleIds.clear();
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
          title: Text(_languageCode == 'vi' ? (isCurrentUser ? 'Sửa chi tiết' : 'Chi tiết'):(isCurrentUser ? 'Edit Detail' : 'Detail')),
          content: isCurrentUser
              ? TextFormField(
            controller: _detailController,
            maxLines: 10,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: _languageCode == 'vi' ? " Nhập tối đa 500 từ":"Enter detail (max 500 words)",
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
              child: Text(_languageCode == 'vi' ? 'Đóng':'Close'),
            ),
            if (isCurrentUser)
              TextButton(
                onPressed: () {
                  final updatedText = _detailController.text;
                  onSave(updatedText); // Pass empty string if all text is deleted
                  Navigator.of(context).pop();
                },
                child: Text(_languageCode == 'vi' ? 'Lưu':'Save'),
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
    setState(() {});
  }

  void _swapDestination(DestinationModel old, DestinationModel newD) async {
    var result = await _scheduleService.UpdateDestination(old.id, old.scheduleId, newD.placeId, newD.startDate, newD.endDate, newD.detail, newD.isArrived);
    var resuldt = await _scheduleService.UpdateDestination(newD.id, newD.scheduleId, old.placeId, old.startDate, old.endDate, old.detail, old.isArrived);
    fetchData();
  }

  void _ChoosePlace(PlaceCardModel place, int scheduleId) async {
    var result = await _scheduleService.CreateDestination(scheduleId, place.placeId,null,null,null);
    if(result){
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
            bottom: 30,
            left: MediaQuery.of(context).size.width/2.3,
            child: isDragging ? Align(
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
            onWillAcceptWithDetails: (DragTargetDetails<DestinationModel> details) {
              return true;
            },
            onAcceptWithDetails: (DragTargetDetails<DestinationModel> details) async {
              final draggedDestination = details.data;
              setState(() {
                _showDeleteDestinationConfirmationDialog(draggedDestination);
              });
            },
          ),
        ) : const SizedBox()),
        Positioned(
          bottom: 12,
          left: 110,
          child: AnimatedOpacity(
            opacity: _showBackToTopButton ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: _showBackToTopButton
                ? BackToTopButton(
              onPressed: _scrollToTop, languageCode: _languageCode,
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
            decoration: InputDecoration(
              labelText: _languageCode == 'vi' ? 'Tìm theo tên':"Search by name",
              border: const OutlineInputBorder(),
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
            _buildDateField(_languageCode == 'vi' ? 'Từ ngày':
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
            _buildDateField(_languageCode == 'vi' ? 'Tới ngày':
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
          child: Text(_languageCode == 'vi' ? 'Tìm kiếm':
            "Search",
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleSection(List<ScheduleModel> filteredSchedules) {
    if (filteredSchedules.isEmpty) {
      return Center(
        child: Text(_languageCode == 'vi' ?'Không tìm thấy lịch trình':
        "No schedules found.",
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
                  side: const BorderSide(color: Colors.black, width: 1),
                ),
                margin: const EdgeInsets.only(bottom: 10),
                color: const Color(0xFFD6B588),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {_toggleEditing(schedule.id);
                        _nameController.text = schedule.scheduleName;
                        },
                        child: isEditingName
                            ? TextFormField(
                          controller: _nameController,
                          focusNode: _nameFocusNode,
                          onFieldSubmitted: (newValue) {
                            _saveScheduleName();
                            _editPlaceName(schedule, newValue);
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
                          Text(_languageCode == 'vi' ? 'Ngày tạo: ${DateFormat('yyyy-MM-dd').format(schedule.createdDate)}':
                              "Created date: ${DateFormat('yyyy-MM-dd').format(schedule.createdDate)}"),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateField(_languageCode == 'vi' ? 'Từ ngày':
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
                                  schedule.startDate = null;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildDateField(_languageCode == 'vi' ? 'Tới ngày':
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
                                  schedule.endDate = null;
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
                                color:
                                schedule.isPublic ? Colors.blue : Colors.red,
                              ),
                              onPressed: isOwner
                                  ? () =>
                                  _toggleVisibility(schedule, _nameController.text)
                                  : null,
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
                          Row(
                            children: [
                              if(isCurrentUser)
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
                          const Spacer(),
                         if(isEditingName) ElevatedButton.icon(
                            onPressed: () {
                              updatedSchedule(schedule, _nameController.text);
                            },
                            label: Text(_languageCode == 'vi' ?'Sửa':
                            "Update",
                              style: const TextStyle(fontSize: 13, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Colors.black, width: 1), // Black border
                              ),
                            ),
                          ),
                          const SizedBox(width: 10,)
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
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.9,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: Column(
                    children: [
                      _buildDestinationGrid(schedule.destinations, schedule),
                      // Only show the add button here if there are no destinations
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
          title: Text(_languageCode == 'vi' ? 'Xác nhận xóa':'Confirm Delete'),
          content: Text(_languageCode == 'vi' ? 'Bạn có muốn xóa "$scheduleName" không?':'Are you sure you want to delete "$scheduleName"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(_languageCode == 'vi' ?'Không':'No'),
            ),
            TextButton(
              onPressed: () {
                _deleteSchedule(scheduleId);
                Navigator.of(context).pop();
              },
              child: Text(_languageCode == 'vi' ? 'Có':'Yes'),
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

  Widget _buildDestinationGrid(List<DestinationModel> destinations, ScheduleModel schedule) {
    List<Widget> rows = [];
    int index = 0;
    int columns = 3;
    double connectorHeight = 40; // Vertical connector height
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
          Widget checkboxWidget = GestureDetector(
            onLongPress: () => _showDeleteDestinationConfirmationDialog(destination),
            child: Checkbox(
              value: destination.isArrived,
              onChanged: (bool? value) async {
                var result = await _scheduleService.UpdateDestination(
                  destination.id,
                  destination.scheduleId,
                  destination.placeId,
                  null,
                  null,
                  destination.detail,
                  value,
                );
                if (result) {
                  fetchData();
                }
              },
              activeColor: Color(0xFF008080),
              checkColor: Colors.white,
            ),
          );

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
                  width: 65,
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
              if (isCurrentUser)
                checkboxWidget,
              circleAvatar,
            ],
          );

          // Wrap the imageWidget with LongPressDraggable
          Widget draggable = LongPressDraggable<DestinationModel>(
            data: destination,
            feedback: Material(
              color: Colors.transparent,
              child: imageWidget, // Drag the whole widget, including Checkbox and CircleAvatar
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
              builder: (BuildContext context, List<dynamic> accepted, List<dynamic> rejected) {
                return imageWidget;
              },
              onWillAcceptWithDetails: (DragTargetDetails<DestinationModel> details) {
                // You can use details to get more information if needed
                return true;
              },
              onAcceptWithDetails: (DragTargetDetails<DestinationModel> details) async {
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
                    onPlaceSelected: (p0) {
                      _ChoosePlace(p0,schedule.id);
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

          // Positions where we need to use Row (positions 4, 7, 10, ...)
          if ((addButtonIndex + 1) % 6 == 4) {
            // Positions: 4, 10, 16, 22, ...
            itemWidget = Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                addButtonContent,
                const SizedBox(width: 10),
              ],
            );
          } else if ((addButtonIndex + 1) % 6 == 1) {
            // Positions: 7, 13, 19, 25, ...
            itemWidget = Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 10),
                addButtonContent,
              ],
            );
          } else {
            // Use Column
            itemWidget = Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30,),
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
        padding: !isEvenRow ? const EdgeInsets.only(left: 0) : const EdgeInsets.only(right: 0),
        child: Row(
          mainAxisAlignment: isEvenRow ? MainAxisAlignment.end : MainAxisAlignment.start,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: rows,
    );
  }

  void _showDestinationDetails(DestinationModel destination) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            void updateStartDate(DateTime? newDate) {
              setState(() {
                destination.startDate = newDate;
              });
              this.setState(() {}); // Notify the parent widget of changes
            }

            void updateEndDate(DateTime? newDate) {
              setState(() {
                destination.endDate = newDate;
              });
              this.setState(() {}); // Notify the parent widget of changes
            }

            return _buildDestinationDetailSheet(destination, updateStartDate, updateEndDate);
          },
        );
      },
    );
  }

  Widget _buildDestinationDetailSheet(
      DestinationModel destination,
      Function(DateTime?) updateStartDate,
      Function(DateTime?) updateEndDate,
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
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              _buildDateField(_languageCode == 'vi' ? 'Từ ngày':
              "Start Date",
                true,
                destination.startDate,
                updateStartDate,
                clearable: isCurrentUser,
                onClear: () => updateStartDate(null),
                isOwner: isCurrentUser,
              ),
              const SizedBox(height: 6),
              _buildDateField(_languageCode == 'vi' ? 'Tới ngày':
                "End Date",
                false,
                destination.endDate,
                updateEndDate,
                clearable: isCurrentUser,
                onClear: () => updateEndDate(null),
                isOwner: isCurrentUser,
              ),
              const SizedBox(height: 10),
              _buildDetailSection(
                destination.detail,
                    (newDetail) async {
                  if (isCurrentUser) {
                    setState(() {
                      destination.detail = newDetail;
                    });
                    await _scheduleService.UpdateDestination(
                      destination.id,
                      destination.scheduleId,
                      destination.placeId,
                      destination.startDate,
                      destination.endDate,
                      destination.detail,
                      destination.isArrived,
                    );
                  }
                },
                isCurrentUser,
              ),
            ],
          ),
        ),
      ),
    );
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
              fontStyle: detailText.isEmpty ? FontStyle.italic : FontStyle.normal,
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
              Text( _languageCode == 'vi' ? 'Chi tiết':
                "Detail:",
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
                        : "Tap to add details...",  // Hint text if empty
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
          title: Text(_languageCode == 'vi' ?'Xóa điểm này?':'Delete this Destination?'),
          content:
          Text('Are you sure you want to delete "${destination.placeName}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(_languageCode == 'vi' ? 'Thoát':'Cancel'),
            ),
            TextButton(
              onPressed: () async {
                var result = await _scheduleService.DeleteDestination(destination.id);
                if (result) {
                  fetchData();
                }
                Navigator.of(context).pop();
              },
              child: Text(_languageCode == 'vi' ? 'Xóa':'Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _filterSchedule() async {
    String searchText = searchController.text.toLowerCase();
    var search = _listScheduleInit;
    if (searchText != '') {
      search = search
          .where(
            (element) => element.scheduleName.toLowerCase().contains(searchText),
      )
          .toList();
    }
    if (_fromDate != null) {
      search = search.where((element) {
        if (element.startDate != null) {
          return element.startDate!.isAfter(_fromDate!);
        }
        return false;
      }).toList();
    }

    if (_toDate != null) {
      search = search.where((element) {
        if (element.endDate != null) {
          return element.endDate!.isBefore(_toDate!);
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
                  suffixIcon:(initialDate == null) ? const Icon(Icons.calendar_today) : null,
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
        ElevatedButton.icon(
          onPressed: () {
            showAddScheduleDialog(
                context, (scheduleName, startDate, endDate) {
              _addSchedule(scheduleName, startDate, endDate);
            }, _listScheduleInit);
          },
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(_languageCode == 'vi' ?'Thêm lịch trình':
          "Add Schedule",
            style: const TextStyle(fontSize: 13.6, color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Colors.black, width: 2), // Black border
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _showSuggestScheduleBottomSheet,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(_languageCode == 'vi' ?'Gợi ý':
            "Suggestion",
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Colors.black, width: 2), // Black border
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


