// lib/widgets/schedule_form.dart

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localtourapp/base/destination_provider.dart';
import 'package:localtourapp/base/schedule_provider.dart';
import 'package:localtourapp/models/schedule/destination.dart';
import 'package:localtourapp/models/schedule/schedule.dart';
import 'package:localtourapp/page/planned_page/planned_page_tab_bars/add_schedule_dialog.dart';
import 'package:provider/provider.dart';
import 'dart:math';

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
          const SizedBox(height: 5),
      
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
                  createdDate: DateTime.now(),
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
      
          const SizedBox(height: 10),
      
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Schedule:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            height: 30,
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
          const SizedBox(height: 5),
      
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "From:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 5),
          GestureDetector(
            onTap: () => _selectDate(context, true),
            child: AbsorbPointer(
              child: SizedBox(
                height: 30,
                width: 300,
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: _fromDate != null
                        ? DateFormat('yyyy-MM-dd').format(_fromDate!)
                        : 'Choose Date',
                    hintStyle: const TextStyle(
                      fontSize: 12,
                    ),
                    border: const OutlineInputBorder(),
                    suffixIcon: _fromDate != null
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _fromDate = null;
                        });
                      },
                    )
                        : null,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
      
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "To:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 5),
          GestureDetector(
            onTap: () => _selectDate(context, false),
            child: AbsorbPointer(
              child: SizedBox(
                width: 300,
                height: 30,
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: _toDate != null
                        ? DateFormat('yyyy-MM-dd').format(_toDate!)
                        : 'Choose Date',
                    hintStyle: const TextStyle(
                      fontSize: 12,
                    ),
                    border: const OutlineInputBorder(),
                    suffixIcon: _toDate != null
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _toDate = null;
                        });
                      },
                    )
                        : null,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
      
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
                Provider.of<DestinationProvider>(context, listen: false);
      
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
                side: const BorderSide(color: Colors.black, width: 2),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 50,
                vertical: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate
          ? (_fromDate ?? DateTime.now())
          : (_toDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }
}
