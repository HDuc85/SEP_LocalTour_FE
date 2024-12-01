import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:localtourapp/models/event/event_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vietmap_flutter_navigation/models/options.dart';
import 'package:vietmap_flutter_navigation/navigation_plugin.dart';

import '../my_map/map_page.dart';

class EventDetailPage extends StatefulWidget {
  final EventModel eventModel;
  const EventDetailPage({
    Key? key,
    required this.eventModel
}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EventDetailPage();
}

class _EventDetailPage extends State<EventDetailPage> with TickerProviderStateMixin{
  bool _isDescriptionExpanded = false;
  late MapOptions _navigationOption;
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
  void initState() {
    super.initState();
    _navigationOption = MapOptions(
      simulateRoute: false,
      apiKey: dotenv.get('VIETMAP_API_KEY'),
      mapStyle: dotenv.get('VIETMAP_MAP_STYLE_URL'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventStatus = _getEventStatus();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventModel.eventName,),
        backgroundColor: Colors.teal,
        elevation: 0,
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
            Card(
              child: Padding(
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
                    Row(
                      children: [
                        const Icon(Icons.date_range, color: Colors.teal),
                        const SizedBox(width: 8),
                        Text(
                          'Bắt đầu: ${DateFormat('hh:mm a, dd-MM-yyyy').format(widget.eventModel.startDate)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.date_range, color: Colors.teal),
                        const SizedBox(width: 8),
                        Text(
                          'Kết thúc: ${DateFormat('hh:mm a, dd-MM-yyyy').format(widget.eventModel.endDate)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text(
                          'Trạng thái: ',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Chip(
                          label: Text(
                            eventStatus,
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: eventStatus == 'Đang diễn ra'
                              ? Colors.green
                              : eventStatus == 'Chưa bắt đầu'
                              ? Colors.orange
                              : Colors.red,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Mô tả sự kiện
                    Row(
                      children: const [
                        Icon(Icons.description, color: Colors.teal),
                        SizedBox(width: 8),
                        Text(
                          'Mô tả',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isDescriptionExpanded = !_isDescriptionExpanded;
                          });
                        },
                        child: _buildExpandableDescription(widget.eventModel.description),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            // Bản đồ
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display placeName
                  Text(
                    widget.eventModel.placeName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // Display placePhoto
                  widget.eventModel.placePhoto != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.eventModel.placePhoto!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Icons.image, size: 50, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Địa điểm',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GestureDetector(
                onTap: _openMaps,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/map_placeholder.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 50,)
          ],
        ),
      ),
    );
  }

  void _openMaps() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPage(
          destinationLatitude: widget.eventModel.latitude,
          destinationLongitude: widget.eventModel.longitude,
        ),
      ),
    );
  }

  Widget _buildExpandableDescription(String description) {
    const int wordLimit = 1000;

    // Split the description into words
    List<String> words = description.split(RegExp(r'\s+'));

    if (_isDescriptionExpanded || words.length <= wordLimit) {
      // If expanded or within the limit, show full text
      return Text(
        description,
        style: const TextStyle(fontSize: 16),
      );
    } else {
      // If collapsed, show limited text with "..."
      String truncatedDescription = words.take(wordLimit).join(' ');
      return Text(
        '$truncatedDescription...',
        style: const TextStyle(fontSize: 16),
      );
    }
  }

}

