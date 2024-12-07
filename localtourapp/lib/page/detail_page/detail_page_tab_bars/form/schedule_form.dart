
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localtourapp/models/schedule/schedule_model.dart';
import 'package:localtourapp/services/schedule_service.dart';
import '../../../planned_page/planned_page_tab_bars/add_schedule_dialog.dart';

class ScheduleForm extends StatefulWidget {
  final String userId;
  final int placeId;
  final String language;
  const ScheduleForm({super.key, required this.userId, required this.placeId, required this.language});

  @override
  State<ScheduleForm> createState() => _ScheduleFormState();
}

class _ScheduleFormState extends State<ScheduleForm> {
  final ScheduleService _scheduleService = ScheduleService();
  List<ScheduleModel> _listSchedule = [];
  int? _selectedScheduleId;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchInit();
  }
  Future<void> fetchInit() async {
    var listschedule = await _scheduleService.GetScheduleCurrentUser();

    if(listschedule.isNotEmpty){
      setState(() {
        _listSchedule = listschedule;
      });
    }
  }

  Future<void> _addSchedule(String scheduleName, DateTime? startDate, DateTime? endDate) async{
    var result = await _scheduleService.CreateSchedule(scheduleName, startDate, endDate);
    if(result){
      fetchInit();
    }
  }


  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 2),
          color: const Color(0xFFF0E68C), // Background color
          borderRadius: BorderRadius.circular(20), // Add rounded corners
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.language != 'vi' ? "ADD PLACE TO SCHEDULE":"Thêm địa điểm vào lịch trình",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(
              thickness: 2,
              color: Colors.black,
            ),
            const SizedBox(height: 15),

            // Add Schedule Button
            ElevatedButton.icon(
              onPressed: () {
                showAddScheduleDialog(context, (scheduleName, startDate, endDate) {

                  _addSchedule(scheduleName,startDate,endDate);

                  setState(() {
                    _selectedScheduleId = null;
                  });
                },
                _listSchedule);
              },
              icon: const Icon(Icons.add),
              label:  Text(widget.language != 'vi' ? "Add Schedule" : 'Thêm lịch trình'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              ),
            ),

            const SizedBox(height: 20),

            // Schedule Dropdown
             Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.language != 'vi' ? "Schedule:" : "Lịch trình",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              height: 40,
              child: DropdownButtonFormField<int>(
                isExpanded: true,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  border: OutlineInputBorder(),
                ),
                value: _selectedScheduleId,
                items: _listSchedule
                    .map((schedule) => DropdownMenuItem<int>(
                  value: schedule.id, // Use unique schedule ID
                  child: Text(schedule.scheduleName, overflow: TextOverflow.ellipsis,),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedScheduleId = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 15),

            // From Date-Time Picker
            _buildDateTimePicker(
              label: widget.language != 'vi' ? "From:" : "Từ",
              selectedDate: _fromDate,
              onDateTimeSelected: (selectedDateTime) {
                setState(() {
                  _fromDate = selectedDateTime;
                });
              },
              onClear: () {
                setState(() {
                  _fromDate = null;
                });
              },
              isFromDate: true,
            ),
            const SizedBox(height: 15),

            // To Date-Time Picker
            _buildDateTimePicker(
              label: widget.language != 'vi' ? "To:" : "Tới",
              selectedDate: _toDate,
              onDateTimeSelected: (selectedDateTime) {
                setState(() {
                  _toDate = selectedDateTime;
                });
              },
              onClear: () {
                setState(() {
                  _toDate = null;
                });
              },
              isFromDate: false,
            ),
            const SizedBox(height: 25),

            // Done Button
            ElevatedButton(
              onPressed: () async {
                if (_selectedScheduleId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(
                      content: Text(widget.language != 'vi' ? 'Please select a schedule.' : "Vui lòng chọn 1 lịch trình"),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } else {
                  if (_fromDate != null &&
                      _toDate != null &&
                      _fromDate!.isAfter(_toDate!)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                        Text(widget.language != 'vi' ?'The "From" date cannot be after the "To" date.' : 'Không được chọn ngày bắt đầu sau ngày kết thúc'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    return;
                  }else{
                    if(_fromDate != null && _fromDate!.isBefore(DateTime.now())){
                      ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(
                          content:
                          Text(widget.language != 'vi' ? 'The "From" date cannot be after Now.': 'Ngày bắt đầu không thể sau bây giờ'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                  var schedule = _listSchedule.firstWhere(
                        (element) => element.id == _selectedScheduleId,
                    orElse: () => ScheduleModel(id: 1, userId: '1', userName: 'userName', userProfileImage: 'userProfileImage', scheduleName: 'scheduleName', createdDate: DateTime.now(), status: 'status', isPublic: true, destinations: List.empty(), totalLikes: 0, isLiked: true),
                  );

                  var result = await _scheduleService.CreateDestination(schedule.id, widget.placeId, _fromDate, _toDate, null);
                  if(result){
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '${widget.language != 'vi'?'Place has been added to Schedule':'Địa danh đã được thêm vào lịch trình'}:${schedule.scheduleName}'),
                      ),
                    );
                  }

                  Navigator.pop(context, true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDCA1A1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Colors.black, width: 1),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 10,
                ),
              ),
              child: Text(widget.language != 'vi' ? "DONE" : "Xong"),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a date-time picker widget with clear functionality.
  Widget _buildDateTimePicker({
    required String label,
    required DateTime? selectedDate,
    required Function(DateTime) onDateTimeSelected,
    required VoidCallback onClear,
    required bool isFromDate,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        SizedBox(
          width: 300,
          height: 40,
          child: TextFormField(
            readOnly: true,
            onTap: () => _selectDateTime(context, isFromDate),
            decoration: InputDecoration(
              hintText: selectedDate != null
                  ? DateFormat('yyyy-MM-dd HH:mm').format(selectedDate)
                  :   (widget.language != 'vi' ?'Choose Date & Time' : 'Chọn ngày & giờ'),
              hintStyle: const TextStyle(
                fontSize: 12,
              ),
              border: const OutlineInputBorder(),
              suffixIcon: selectedDate != null
                  ? IconButton(
                icon: const Icon(
                  Icons.clear,
                  size: 20,
                ),
                onPressed: () {
                  onClear();
                },
              )
                  : const Icon(Icons.calendar_today),
            ),
          ),
        ),
      ],
    );
  }

  /// Handles date and time selection.
  Future<void> _selectDateTime(BuildContext context, bool isFromDate) async {
    DateTime initialDate = isFromDate
        ? (_fromDate ?? DateTime.now())
        : (_toDate ?? DateTime.now());

    // Select Date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      // Select Time
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (pickedTime != null) {
        final combinedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          if (isFromDate) {
            _fromDate = combinedDateTime;
          } else {
            _toDate = combinedDateTime;
          }
        });
      }
    }
  }
}
