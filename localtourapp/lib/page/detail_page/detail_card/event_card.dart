// event_card_widget.dart
import 'package:flutter/material.dart';
import '../../../base/scrollable_text_container.dart';
import '../../../models/places/event.dart';

class EventCardWidget extends StatelessWidget {
  final Event event;

  const EventCardWidget({Key? key, required this.event}) : super(key: key);

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  Widget _buildEventStatus(String status) {
    Color statusColor;
    String statusText;

    switch (status.toLowerCase()) {
      case 'about to open':
        statusColor = const Color(0xFFFFDB58);
        statusText = 'About to Open';
        break;
      case 'is opening':
        statusColor = Colors.green;
        statusText = 'Is Opening';
        break;
      case 'has closed':
        statusColor = Colors.red;
        statusText = 'Has Closed';
        break;
      default:
        statusColor = Colors.grey;
        statusText = status;
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
                  _buildEventStatus(event.eventStatus),
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
