import 'package:flutter/material.dart';
import '../../../base/scrollable_text_container.dart';
import '../../../models/places/event.dart';

// Event card widget
Future<Widget> buildEventCard(Event event) async {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Card(
      color: Colors.white,
      elevation: 20,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event name and status row
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  event.eventName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                _buildEventStatus(event.eventStatus), // Pass the event status as a string
              ],
            ),
            const SizedBox(height: 10),

            // Scrollable description
            ScrollableTextContainer(content: event.description ?? 'No description available.',),
            const SizedBox(height: 10),

            // Event start and end date row using _formatDate
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Start: ${_formatDate(event.startDate)}'), // Use _formatDate for start date
                Text('End: ${_formatDate(event.endDate)}'),     // Use _formatDate for end date
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

// Event status builder
Widget _buildEventStatus(String status) {
  Color statusColor;
  String statusText;

  switch (status) {
    case 'about to open':
      statusColor = const Color(0xFFFFDB58);
      statusText = 'about to open';
      break;
    case 'is opening':
      statusColor = Colors.green;
      statusText = 'is opening';
      break;
    case 'has closed':
      statusColor = Colors.red;
      statusText = 'has closed';
      break;
    default:
      statusColor = Colors.grey;
      statusText = status;
  }

  return Text(
    statusText,
    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: statusColor),
  );
}

// Date formatter for event start and end dates
String _formatDate(DateTime date) {
  return "${date.day}/${date.month}/${date.year}";
}
