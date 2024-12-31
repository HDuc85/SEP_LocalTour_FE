import 'package:flutter/material.dart';

import '../../models/places/place_detail_model.dart';

class AddDestinationBottomSheet extends StatefulWidget {
  final PlaceDetailModel placeDetail;
  const AddDestinationBottomSheet({Key? key, required this.placeDetail}) : super(key: key);

  @override
  State<AddDestinationBottomSheet> createState() => _AddDestinationBottomSheetState();
}

class _AddDestinationBottomSheetState extends State<AddDestinationBottomSheet> {
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _detailController = TextEditingController();

  // Controllers for showing the selected date/time
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController   = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Drag handle
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),

            // Place info
            Text(widget.placeDetail.name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                widget.placeDetail.photoDisplay,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Open: ${_formatTime(widget.placeDetail.timeOpen)} - ${_formatTime(widget.placeDetail.timeClose)}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Destination fields
            _buildDateTimePicker(
              label: 'Start Date/Time',
              selectedDate: _startDate,
              controller: _startDateController,
              onDateTimeSelected: (dateTime) {
                setState(() {
                  _startDate = dateTime;
                });
              },
            ),
            const SizedBox(height: 10),

            _buildDateTimePicker(
              label: 'End Date/Time',
              selectedDate: _endDate,
              controller: _endDateController,
              onDateTimeSelected: (dateTime) {
                setState(() {
                  _endDate = dateTime;
                });
              },
            ),
            const SizedBox(height: 10),

            TextFormField(
              controller: _detailController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: "Detail / Notes",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _onSavePressed,
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimePicker({
    required String label,
    required DateTime? selectedDate,
    required TextEditingController controller,
    required ValueChanged<DateTime?> onDateTimeSelected,
  }) {
    // Each build, update the controller’s text
    if (selectedDate != null) {
      controller.text = _formatDateTime(selectedDate);
    } else {
      controller.text = '';
    }

    return GestureDetector(
      onTap: () async {
        final today = DateTime.now();
        // Step 1: pick a date
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? today,
          firstDate: today,
          lastDate: DateTime(2100),
        );
        if (date == null) return;

        // Step 2: pick a time
        final timeOfDay = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (timeOfDay == null) return;

        final newDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          timeOfDay.hour,
          timeOfDay.minute,
        );
        onDateTimeSelected(newDateTime);
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            labelText: label,
            hintText: 'Tap to select',
            border: const OutlineInputBorder(),
          ),
        ),
      ),
    );
  }

  void _onSavePressed() {
    // 1) Check valid
    if (_startDate == null || _endDate == null) {
      _showSnack('Please select both start and end times.');
      return;
    }
    if (_startDate!.isAfter(_endDate!)) {
      _showSnack('Start time cannot be after end time.');
      return;
    }

    // 2) Check open/close times
    if (!_isWithinOpenClose(_startDate!, widget.placeDetail.timeOpen,
        widget.placeDetail.timeClose)) {
      _showSnack(
          '${widget.placeDetail.name} is open between '
              '${_formatTime(widget.placeDetail.timeOpen)} and '
              '${_formatTime(widget.placeDetail.timeClose)}. '
              'Please choose the right time.'
      );
      return;
    }

    if (!_isWithinOpenClose(_endDate!, widget.placeDetail.timeOpen,
        widget.placeDetail.timeClose)) {
      _showSnack(
          '${widget.placeDetail.name} is open between '
              '${_formatTime(widget.placeDetail.timeOpen)} and '
              '${_formatTime(widget.placeDetail.timeClose)}. '
              'Please choose the right time.'
      );
      return;
    }

    // 3) Return a Map with user input
    Navigator.pop(context, {
      'startDate': _startDate,
      'endDate': _endDate,
      'detail': _detailController.text,
    });
  }

  bool _isWithinOpenClose(DateTime dateTime, TimeOfDay? open, TimeOfDay? close) {
    if (open == null || close == null) return true;
    final openDateTime = DateTime(dateTime.year, dateTime.month, dateTime.day, open.hour, open.minute);
    final closeDateTime = DateTime(dateTime.year, dateTime.month, dateTime.day, close.hour, close.minute);
    return dateTime.isAfter(openDateTime) && dateTime.isBefore(closeDateTime);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _formatTime(TimeOfDay? tod) {
    if (tod == null) return '--:--';
    final hour = tod.hour.toString().padLeft(2, '0');
    final min  = tod.minute.toString().padLeft(2, '0');
    return '$hour:$min';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

