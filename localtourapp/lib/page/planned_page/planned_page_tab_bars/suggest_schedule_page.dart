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

  const SuggestSchedulePage({Key? key, required this.userId}) : super(key: key);

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
      child: Column(
        children: [
          // Schedule Name
          Text(
            suggestedScheduleName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          // Start and End Date of Schedule
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Start Date
              Column(
                children: [
                  Text(_languageCode == 'vi' ?'Ngày bắt đầu':"Start Date", style: const TextStyle(fontWeight: FontWeight.bold)),
                  _buildDateField(_languageCode == 'vi' ?'Ngày bắt đầu':"Start Date",
                    false,
                    startTime,
                        (newDate) {
                      _onDateSelected(newDate, true);
                    },
                    clearable: true,
                    onClear: () {
                      _onDateSelected(null, true);
                    },),
                ],
              ),
              // End Date
              Column(
                children: [
                  Text(_languageCode == 'vi' ?'Ngày kết thúc':"End Date", style: const TextStyle(fontWeight: FontWeight.bold)),
                  _buildDateField(_languageCode == 'vi' ?'Ngày kết thúc':"End Date",
                    false,
                    endTime,
                        (newDate) {
                      _onDateSelected(newDate, false);
                    },
                    clearable: true,
                    onClear: () {
                      _onDateSelected(null, false);
                    },),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: hasPlaces
                ? SingleChildScrollView(
              child: Column(
                children: [
                  _buildDestinationList(context, suggestedDestinations),
                  const SizedBox(height: 20),
                ],
              ),
            )
                : Center(
              child: Text(_languageCode == 'vi' ?'Không có điểm đến nào có sẵn theo sở thích của bạn.':"No destinations available based on your preferences."),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: hasPlaces ? _onOtherSchedule : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(_languageCode == 'vi' ?'Khác':"Other"),
              ),
              ElevatedButton(
                onPressed: hasPlaces ? _onChooseSchedule : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(_languageCode == 'vi' ?'Chọn cái này':"Choose this"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(
      String labelText,
      bool isStartDate,
      DateTime? initialDate,
      Function(DateTime?) onDateChanged, {
        bool clearable = false,
        VoidCallback? onClear,
        bool isOwner = true,
      }) {
    return GestureDetector(
      onTap: () async {
        DateTime? selectedDate =
            initialDate; // Temporarily store the initial date
        if (isOwner) {
          // Date picker
          final DateTime? date = await showDatePicker(
            context: context,
            initialDate: selectedDate ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );

          // If date is selected, proceed to time selection
          if (date != null) {
            selectedDate = DateTime(date.year, date.month, date.day,
                selectedDate?.hour ?? 0, selectedDate?.minute ?? 0);
              selectedDate = DateTime(
                  date.year, date.month, date.day, 0, 0); // Default time
            onDateChanged(selectedDate);
          }
        }
      },
      child: Stack(
        children: [
          AbsorbPointer(
            child: SizedBox(
              height: 30,
              width: 120,
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: initialDate != null
                      ? DateFormat('yyyy-MM-dd').format(initialDate)
                      : labelText,
                  hintStyle: const TextStyle(fontSize: 12),
                  border: const OutlineInputBorder(),
                  suffixIcon:(initialDate == null) ? const Icon(Icons.calendar_today) : null,
                ),
              ),
            ),
          ),
          if (clearable && initialDate != null)
            Positioned(
              right: 5,
              top: 3,
              child: GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close, size: 22, color: Colors.grey[600]),
              ),
            ),
        ],
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
                  color: const Color(0xFFD6B588),
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
            const SizedBox(height: 16),
          ],
        ),
      );
    });

    return Column(children: dayWidgets);
  }
}
