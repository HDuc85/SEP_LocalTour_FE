import 'package:flutter/material.dart';

class ScheduleForm extends StatefulWidget {
  const ScheduleForm({super.key});

  @override
  State<ScheduleForm> createState() => _ScheduleFormState();
}

class _ScheduleFormState extends State<ScheduleForm> {
  String? _selectedSchedule;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Adjusts based on content size
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

        // Schedule Label and Dropdown
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
            items: ["Morning", "Afternoon", "Evening"]
                .map((schedule) => DropdownMenuItem(
              value: schedule,
              child: Text(schedule),
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

        // From Date Label and Picker
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
                      ? _fromDate.toString().split(' ')[0]
                      : 'Choose Date',
                  hintStyle: const TextStyle(
                    fontSize: 12, // Set the font size for the hint text
                  ),
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),

        // To Date Label and Picker
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
            child:
            SizedBox(
              width: 300,
              height: 30,
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: _toDate != null
                      ? _toDate.toString().split(' ')[0]
                      : 'Choose Date',
                  hintStyle: const TextStyle(
                    fontSize: 12, // Set the font size for the hint text
                  ),
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Done Button
        ElevatedButton(
          onPressed: () {
            if (_selectedSchedule == null) {
              // Show a message if schedule is not selected
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please select a schedule.'),
                ),
              );
            } else if (_fromDate == null) {
              // Show a message if the 'from date' is not selected
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please choose a "From" date.'),
                ),
              );
            } else if (_toDate == null) {
              // Show a message if the 'to date' is not selected
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please choose a "To" date.'),
                ),
              );
            } else if (_fromDate!.isAfter(_toDate!)) {
              // Show a message if the 'from date' is after the 'to date'
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('The "From" date cannot be after the "To" date.'),
                ),
              );
            } else {
              // All fields are valid, proceed
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Place has been added to Schedule: $_selectedSchedule'),
                ),
              );
              Navigator.pop(context); // Close the form
            }
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
            "DONE",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),


      ],
    );
  }

  // Date picker function
  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
