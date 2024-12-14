import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localtourapp/config/appConfig.dart';
import 'package:localtourapp/models/event/event_model.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';

import '../my_map/domain/entities/vietmap_model.dart';
import '../my_map/features/routing_screen/routing_screen.dart';
import 'detail_page.dart';

class EventDetailPage extends StatefulWidget {
  final EventModel eventModel;
  const EventDetailPage({Key? key, required this.eventModel}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EventDetailPage();
}

class _EventDetailPage extends State<EventDetailPage>
    with TickerProviderStateMixin {
  bool _isDescriptionExpanded = false;
  VietmapController? _vietmapController;
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
  }

  @override
  Widget build(BuildContext context) {
    final eventStatus = _getEventStatus();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.eventModel.eventName,
        ),
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
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
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
                    const Row(
                      children: [
                        Icon(Icons.description, color: Colors.teal),
                        SizedBox(width: 8),
                        Text(
                          'Mô tả',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
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
                        child: _buildExpandableDescription(
                            widget.eventModel.description),
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
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailPage(
                        placeId: widget.eventModel.placeId,
                      ),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.eventModel.placeName,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
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
                              child: Icon(Icons.image,
                                  size: 50, color: Colors.grey),
                            ),
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Địa điểm',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 200,
                child: Stack(
                  children: [
                    VietmapGL(
                      styleString: AppConfig.vietMapStyleUrl,
                      initialCameraPosition: CameraPosition(
                          target: LatLng(widget.eventModel.latitude,
                              widget.eventModel.longitude),
                          zoom: 14),
                      trackCameraPosition: true,
                      onMapCreated: (VietmapController controller) {
                        setState(() {
                          _vietmapController = controller;
                        });
                      },
                      onMapClick: (point, coordinates) {
                        _openMaps();
                      },
                    ),
                    if (_vietmapController != null)
                      MarkerLayer(
                        mapController: _vietmapController!,
                        markers: [
                          Marker(
                            latLng: LatLng(widget.eventModel.latitude,
                                widget.eventModel.longitude), // Tọa độ marker
                            child: const Icon(Icons.location_on,
                                color: Colors.red, size: 40),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 50,
            )
          ],
        ),
      ),
    );
  }

  void _openMaps() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoutingScreen(
          vietmapModel: VietmapModel(
            address: widget.eventModel.placeName,
            lat: widget.eventModel.latitude,
            name: widget.eventModel.placeName,
            lng: widget.eventModel.longitude,
          ),
          placeId: widget.eventModel.placeId,
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
