import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:localtourapp/models/schedule/destination_model.dart';
import 'package:localtourapp/services/location_Service.dart';
import 'package:localtourapp/services/schedule_service.dart';

import '../../../config/appConfig.dart';
import '../../../config/secure_storage_helper.dart';

class SuggestSchedulePage extends StatefulWidget {
  final String userId;
  final VoidCallback voidCallback;

  const SuggestSchedulePage({Key? key, required this.userId, required this.voidCallback}) : super(key: key);

  @override
  State<SuggestSchedulePage> createState() => _SuggestSchedulePageState();
}

class _SuggestSchedulePageState extends State<SuggestSchedulePage> {
  final ScheduleService _scheduleService = ScheduleService();
  final LocationService _locationService = LocationService();
  String _languageCode = '';
  String suggestedScheduleName = '';
  late DateTime? startTime ;
  late DateTime? endTime;
  late List<DestinationModel> suggestedDestinations;
  late Position _currentPosition;

  late DateTime currentTime;
  Random random = Random();

  // Timeslots definition: morning, afternoon, evening
  final timeslots = const [
    [8, 11],  // Morning: 8:00-11:00
    [14, 17], // Afternoon: 14:00-17:00
    [19, 22], // Evening: 19:00-22:00
  ];

  @override
  void initState() {
    super.initState();
    currentTime = DateTime.now();
    startTime = DateTime.now().add(const Duration(days: 1));
    startTime = DateTime(startTime!.year, startTime!.month, startTime!.day, 9,0,0);
    endTime = startTime!.add(const Duration(days: 2));
    suggestedDestinations =[];
    fetchInit();

  }

  Future<void> fetchInit() async {
    Position? position = await _locationService.getCurrentPosition();
    double long = position != null ? position.longitude : 106.8096761;
    double lat =  position != null ? position.latitude : 10.8411123;
    var languageCode = await SecureStorageHelper().readValue(AppConfig.language);
    if(position != null){
      _currentPosition = position;
    }else{
      _currentPosition = Position(longitude: long, latitude: lat, timestamp: DateTime.timestamp(), accuracy: 1, altitude: 1, altitudeAccuracy: 1, heading: 1, headingAccuracy: 1, speed: 1, speedAccuracy: 1);
    }

    var suggestlistDestination = await _scheduleService.SuggestSchedule(long, lat, startTime!, 3);

    setState(() {
      suggestedDestinations = suggestlistDestination;
      _languageCode = languageCode!;
    });
  }

  void _onChooseSchedule() async {
    // Add the suggested schedule to the schedule list and destinations
    if(suggestedDestinations.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_languageCode == 'vi' ? 'Không có gì để lưu':'Nothing to save'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
   var result = await _scheduleService.SaveSuggestSchedule(startTime!, endTime!, suggestedDestinations);
      // No suggested schedule available
      if(result){
        widget.voidCallback();
      Navigator.pop(context);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_languageCode == 'vi' ? 'Có gì đó không đúng khi lưu':'Some thing wrong while saving'),
        behavior: SnackBarBehavior.floating,
      ),
    );

  }
  void _onDateSelected(DateTime? newDate, bool isFromDate) {
    if (isFromDate) {
      startTime = newDate != null ? newDate.add(const Duration(hours: 9)) : newDate;
    } else {
      endTime = newDate != null ? newDate.add(const Duration(hours: 9)) : newDate;
    }
    setState(() {

    });
  }
  void _onOtherSchedule() async {
    startTime ??= DateTime.now().add(const Duration(days: 1));

    endTime ??= startTime!.add(const Duration(days: 3));
    int different = endTime!.difference(startTime!).inDays +1;

    var suggestlistDestination = await _scheduleService.SuggestSchedule(_currentPosition.longitude, _currentPosition.latitude, startTime!, different);

    setState(() {
      suggestedDestinations = suggestlistDestination;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool hasPlaces = suggestedDestinations.isNotEmpty;

    return Container(
      height: size.height * 0.8,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade100, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            children: [
              Expanded(
                child: Text(
                  suggestedScheduleName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          // Date Selection Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDateFieldCard(
                _languageCode == 'vi' ? 'Ngày bắt đầu' : 'Start Date',
                startTime,
                    (newDate) => _onDateSelected(newDate, true),
              ),
              _buildDateFieldCard(
                _languageCode == 'vi' ? 'Ngày kết thúc' : 'End Date',
                endTime,
                    (newDate) => _onDateSelected(newDate, false),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Destination List or Empty Message
          Expanded(
            child: hasPlaces
                ? SingleChildScrollView(
              child: _buildDestinationList(context, suggestedDestinations),
            )
                : Center(
              child: Text(
                _languageCode == 'vi'
                    ? 'Không có điểm đến nào có sẵn theo sở thích của bạn.'
                    : "No destinations available based on your preferences.",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ),
          // Action Buttons
          const SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildGradientButton(
                text: _languageCode == 'vi' ? 'Khác' : 'Other',
                color1: Colors.orange,
                color2: Colors.deepOrange,
                onPressed: hasPlaces ? _onOtherSchedule : null,
              ),
              _buildGradientButton(
                text: _languageCode == 'vi' ? 'Chọn cái này' : 'Choose this',
                color1: Colors.green,
                color2: Colors.teal,
                onPressed: hasPlaces ? _onChooseSchedule : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

// Date Field Card
  Widget _buildDateFieldCard(String label, DateTime? date, Function(DateTime?) onDateChanged) {
    return GestureDetector(
      onTap: () async {
        DateTime? selectedDate = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (selectedDate != null) {
          onDateChanged(selectedDate);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.blueAccent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              date != null ? DateFormat('yyyy-MM-dd').format(date) : '-',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

// Gradient Button
  Widget _buildGradientButton({
    required String text,
    required Color color1,
    required Color color2,
    required VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color1, color2]),
          borderRadius: BorderRadius.circular(30),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }


  Widget _buildDestinationList(BuildContext context, List<DestinationModel> destinations) {

    // Group destinations by day
    Map<String, List<DestinationModel>> destinationsByDay = {};
    for (var destination in destinations) {
      final dayKey = DateFormat('yyyy-MM-dd').format(destination.startDate ?? DateTime.now());
      destinationsByDay.putIfAbsent(dayKey, () => []);
      destinationsByDay[dayKey]!.add(destination);
    }

    List<Widget> dayWidgets = [];
    destinationsByDay.forEach((day, dayDestinations) {
      dayDestinations.sort((a, b) => a.startDate!.compareTo(b.startDate!));

      dayWidgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_languageCode == 'vi' ? 'Ngày ${DateFormat('MM-dd-yyyy').format(DateTime.parse(day))}':
              "Day ${DateFormat('MM-dd-yyyy').format(DateTime.parse(day))}",
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, decoration: TextDecoration.underline
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children: dayDestinations.map((dest) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: const BorderSide(color: Colors.black, width: 1),
                  ),
                  margin: const EdgeInsets.only(bottom: 10),
                  color: Colors.orange[200],
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(8.0),
                    leading: dest.placePhotoDisplay != null
                        ? Image.network(
                      dest.placePhotoDisplay!,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.photo);
                      },
                    )
                        : const Icon(Icons.photo),
                    title: Text(
                      dest.placeName ,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${DateFormat('HH:mm').format(dest.startDate!)} - ${DateFormat('HH:mm').format(dest.endDate!)}",
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    });
    return Column(children: dayWidgets);
  }
}
