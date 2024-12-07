// event_card_widget.dart
import 'package:flutter/material.dart';
import 'package:localtourapp/config/appConfig.dart';
import 'package:localtourapp/config/secure_storage_helper.dart';
import 'package:localtourapp/models/event/event_model.dart';
import '../../../base/scrollable_text_container.dart';

class EventCardWidget extends StatelessWidget {
  final EventModel event;
  final String languageCode;

  const EventCardWidget({Key? key, required this.event, required this.languageCode}) : super(key: key);


  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }


  Widget _buildEventStatus() {
    Color statusColor;
    String statusText;
    DateTime currentDate = DateTime.now();
    int check = 0;

    if (currentDate.isBefore(event.startDate)) {
      check = 1;
    } else if (currentDate.isAfter(event.endDate)) {
      check = 3;
    } else {
      check = 2;
    }

    switch (check) {
      case 1:
        statusColor = const Color(0xFFFFDB58);
        statusText = languageCode == 'vi'? 'Sắp diễn ra' : 'About to Open';
        break;
      case 2:
        statusColor = Colors.green;
        statusText = languageCode == 'vi'?'Đang diễn ra':'Is Opening';
        break;
      case 3:
        statusColor = Colors.red;
        statusText = languageCode == 'vi'?'Đã kết thúc':'Has Closed';
        break;
      default:
        statusColor = Colors.grey;
        statusText = languageCode == 'vi'?'Không rõ':'Unknown';
    }

    return Text(
      statusText,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: statusColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final event = this.event;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        color: Colors.white,
        elevation: 5, // Adjust elevation as needed
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event name and status
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.eventName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  _buildEventStatus(),
                ],
              ),
              const SizedBox(height: 10),
              // Scrollable description with custom text size
              ScrollableTextContainer(
                content: event.description ?? 'No description available.',
                textSize: 14.0, // Adjust text size as needed
              ),
              const SizedBox(height: 10),
              // Event dates
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Start: ${_formatDate(event.startDate)}'),
                  Text('End: ${_formatDate(event.endDate)}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
