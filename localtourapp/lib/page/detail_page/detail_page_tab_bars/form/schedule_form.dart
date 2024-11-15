// lib/widgets/schedule_form.dart

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import '../../../../models/schedule/destination.dart';
import '../../../../models/schedule/schedule.dart';
import '../../../../provider/schedule_provider.dart';
import '../../../planned_page/planned_page_tab_bars/add_schedule_dialog.dart';

class ScheduleForm extends StatefulWidget {
  final String userId;
  final int placeId;

  const ScheduleForm({super.key, required this.userId, required this.placeId});

  @override
  State<ScheduleForm> createState() => _ScheduleFormState();
}

class _ScheduleFormState extends State<ScheduleForm> {
  String? _selectedSchedule;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = Provider.of<ScheduleProvider>(context);
    final List<Schedule> userSchedules = scheduleProvider.schedules
        .where((s) => s.userId == widget.userId)
        .toList();

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
            const Text(
              "ADD PLACE TO SCHEDULE",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                  int newId = scheduleProvider.schedules.isNotEmpty
                      ? scheduleProvider.schedules.map((s) => s.id).reduce(max) + 1
                      : 1;

                  Schedule newSchedule = Schedule(
                    id: newId,
                    userId: widget.userId,
                    scheduleName: scheduleName,
                    startDate: startDate,
                    endDate: endDate,
                    createdAt: DateTime.now(),
                    isPublic: false,
                  );

                  scheduleProvider.addSchedule(newSchedule);

                  setState(() {
                    _selectedSchedule = newSchedule.scheduleName;
                  });
                });
              },
              icon: const Icon(Icons.add),
              label: const Text("Add Schedule"),
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
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Schedule:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              height: 40,
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  border: OutlineInputBorder(),
                ),
                value: _selectedSchedule,
                items: userSchedules
                    .map((schedule) => DropdownMenuItem(
                  value: schedule.scheduleName,
                  child: Text(schedule.scheduleName),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSchedule = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 15),

            // From Date-Time Picker
            _buildDateTimePicker(
              label: "From:",
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
              label: "To:",
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
              onPressed: () {
                if (_selectedSchedule == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a schedule.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  if (_fromDate != null &&
                      _toDate != null &&
                      _fromDate!.isAfter(_toDate!)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                        Text('The "From" date cannot be after the "To" date.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }

                  final scheduleProvider =
                  Provider.of<ScheduleProvider>(context, listen: false);
                  final destinationProvider =
                  Provider.of<ScheduleProvider>(context, listen: false);

                  final selectedSchedule =
                  scheduleProvider.schedules.firstWhereOrNull(
                        (s) => s.scheduleName == _selectedSchedule,
                  );

                  if (selectedSchedule == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Selected schedule not found.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }

                  Destination newDestination = Destination(
                    id: destinationProvider.destinations.isNotEmpty
                        ? destinationProvider.destinations
                        .map((d) => d.id)
                        .reduce(max) +
                        1
                        : 1,
                    scheduleId: selectedSchedule.id,
                    placeId: widget.placeId,
                    detail: 'Destination Detail',
                    startDate: _fromDate,
                    endDate: _toDate,
                  );

                  destinationProvider.addDestination(newDestination);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Place has been added to Schedule: $_selectedSchedule'),
                    ),
                  );

                  Navigator.pop(context);
                }
              },
              child: const Text("DONE"),
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
                  : 'Choose Date & Time',
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
