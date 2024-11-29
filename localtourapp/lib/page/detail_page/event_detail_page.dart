import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localtourapp/models/event/event_model.dart';

class EventDetailPage extends StatefulWidget {
  final EventModel eventModel;
  const EventDetailPage({
    Key? key,
    required this.eventModel
}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EventDetailPage();

}

class _EventDetailPage extends State<EventDetailPage> {

  String _getEventStatus() {
    final now = DateTime.now();
    if (widget.eventModel.startDate.isAfter(now)) {
      return 'Chưa bắt đầu';
    } else if (widget.eventModel.endDate.isAfter(now)) {
      return 'Đang diễn ra';
    } else {
      return 'Đã kết thúc';
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventStatus = _getEventStatus();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventModel.eventName),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh sự kiện
            widget.eventModel.eventPhoto != null
                ? Image.network(
              widget.eventModel.eventPhoto!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            )
                : Container(
              width: double.infinity,
              height: 200,
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.image, size: 50, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên sự kiện
                  Text(
                    widget.eventModel.eventName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bắt đầu: ${DateFormat('hh:mm a, dd-MM-yyyy').format(widget.eventModel.startDate)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Kết thúc: ${DateFormat('hh:mm a, dd-MM-yyyy').format(widget.eventModel.endDate)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text(
                        'Trạng thái: ',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        eventStatus,
                        style: TextStyle(
                          fontSize: 16,
                          color: eventStatus == 'Đang diễn ra'
                              ? Colors.green
                              : eventStatus == 'Chưa bắt đầu'
                              ? Colors.orange
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Mô tả sự kiện
                  const Text(
                    'Mô tả:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.eventModel.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            // Bản đồ
            SizedBox(
              height: 300,

            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Sự kiện khi nhấn vào bản đồ
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bản đồ đã được nhấn!')),
                  );
                },
                child: const Text('Mở Google Maps'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
