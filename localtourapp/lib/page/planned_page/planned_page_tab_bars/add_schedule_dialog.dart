// lib/page/planned_page/planned_page_tab_bars/add_schedule_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

typedef ScheduleCallback = void Function(String scheduleName, DateTime? startDate, DateTime? endDate);

void showAddScheduleDialog(BuildContext context, ScheduleCallback onCreate) {
  final TextEditingController _scheduleNameController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: GestureDetector(
            onTap: () {},
            child: StatefulBuilder(
              builder: (context, setState) {
                return SingleChildScrollView(
                  child: AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: const Center(child: Text("CREATE NEW SCHEDULE")),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("Schedule's name:"),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _scheduleNameController,
                          decoration: const InputDecoration(
                            hintText: 'Enter schedule name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() {
                                _startDate = picked;
                              });
                            }
                          },
                          child: Stack(
                            children: [AbsorbPointer(
                              child: TextField(
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.calendar_today),
                                  hintText: _startDate != null
                                      ? DateFormat('yyyy-MM-dd').format(_startDate!)
                                      : 'Start Date',
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                              _startDate != null
                              ?
                              Positioned(
                                top: 5,
                                right: 0,
                                child: IconButton(
                                icon:  Icon(Icons.clear),
                                onPressed: () {
                                setState(() {
                                _startDate = null;
                                });}),
                              ): SizedBox(),
                            ]
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() {
                                _endDate = picked;
                              });
                            }
                          },
                          child: Stack(
                            children: [
                              AbsorbPointer(
                                child: TextFormField(
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.calendar_today),
                                      hintText: _endDate != null
                                          ? DateFormat('yyyy-MM-dd').format(_endDate!)
                                          : 'End Date',
                                      border: const OutlineInputBorder(),
                                      suffixIcon: _endDate != null
                                          ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          setState(() {
                                            _endDate = null;
                                          });
                                        },
                                      )
                                          : null,
                                    ),
                                  ),
                              ),
                              _endDate != null
                                  ?
                              Positioned(
                                top: 5,
                                right: 0,
                                child: IconButton(
                                    icon:  Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        _endDate = null;
                                      });}),
                              ): SizedBox()
                            ],
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_scheduleNameController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please input schedule name'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            } else {
                              onCreate(
                                _scheduleNameController.text,
                                _startDate,
                                _endDate,
                              );
                              Navigator.of(context).pop();
                              // Show success notification
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('New schedule has been created'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pinkAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(color: Colors.black, width: 2),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 10,
                            ),
                          ),
                          child: const Text(
                            "Create",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
    },
  );
}
