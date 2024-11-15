import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localtourapp/provider/schedule_provider.dart';
import 'package:localtourapp/models/schedule/destination.dart';
import 'package:localtourapp/models/schedule/schedule.dart';
import 'package:provider/provider.dart';

// Import local classes and providers
import 'package:localtourapp/provider/user_provider.dart';
import 'package:localtourapp/models/places/place.dart';

class SuggestSchedulePage extends StatefulWidget {
  final String userId;

  const SuggestSchedulePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<SuggestSchedulePage> createState() => _SuggestSchedulePageState();
}

class _SuggestSchedulePageState extends State<SuggestSchedulePage> {
  late ScheduleProvider scheduleProvider;
  late UserProvider userProvider;
  late Schedule suggestedSchedule;
  late List<Destination> suggestedDestinations;
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
    scheduleProvider = Provider.of<ScheduleProvider>(context, listen: false);
    userProvider = Provider.of<UserProvider>(context, listen: false);
    currentTime = DateTime.now();

    // Generate the suggested schedule and destinations upon initialization
    _generateSuggestedSchedule();
  }

  void _generateSuggestedSchedule() {
    final userPreferredTags = userProvider.getUserPreferredTags();
    final userPreferredPlaces = scheduleProvider.getPlacesForUserPreferences(userPreferredTags);

    // If user has no preferred tags or no places match preferences, handle gracefully
    if (userPreferredPlaces.isEmpty) {
      suggestedSchedule = _createEmptySchedule();
      suggestedDestinations = [];
      return;
    }

    // Calculate a unique schedule ID based on existing schedules
    final int newScheduleId = (scheduleProvider.schedules.isEmpty)
        ? 1
        : scheduleProvider.schedules.map((s) => s.id).reduce(max) + 1;

    // Start date is based on current date/time
    final DateTime startDate = _calculateStartDate(currentTime, timeslots);
    final DateTime endDate = startDate.add(const Duration(days: 3)); // A 3-day schedule

    suggestedSchedule = Schedule(
      id: newScheduleId,
      userId: widget.userId,
      scheduleName: "Schedule at ${DateFormat('yyyy-MM-dd HH:mm').format(currentTime)}",
      startDate: startDate,
      endDate: endDate,
      createdAt: DateTime.now(),
      isPublic: false,
    );

    // Generate destinations for 3 days, each day having 3 timeslots
    suggestedDestinations = _generateDestinations(userPreferredPlaces, startDate);

    // Sort destinations by their startDate for clarity
    suggestedDestinations.sort((a, b) => a.startDate!.compareTo(b.startDate!));
  }

  Schedule _createEmptySchedule() {
    return Schedule(
      id: 0,
      userId: widget.userId,
      scheduleName: "No schedule available",
      startDate: DateTime.now(),
      endDate: DateTime.now(),
      createdAt: DateTime.now(),
      isPublic: false,
    );
  }

  DateTime _calculateStartDate(DateTime now, List<List<int>> timeslots) {
    // Determine the first available timeslot today or next day
    final int currentHour = now.hour;
    for (var slot in timeslots) {
      final startHour = slot[0];
      if (currentHour < startHour || (currentHour == startHour && now.minute < 59)) {
        // We can start at this timeslot today
        return DateTime(now.year, now.month, now.day, startHour, 0);
      }
    }
    // If all timeslots for today are past, start the schedule from tomorrow morning at 8:00
    return DateTime(now.year, now.month, now.day + 1, 8, 0);
  }

  List<Destination> _generateDestinations(List<Place> userPreferredPlaces, DateTime scheduleStartDate) {
    // We have 3 days, each day with 3 timeslots = 9 destinations
    List<Destination> destinations = [];
    DateTime currentDate = scheduleStartDate;

    for (int day = 0; day < 3; day++) {
      for (int slotIndex = 0; slotIndex < timeslots.length; slotIndex++) {
        final slot = timeslots[slotIndex];
        DateTime slotStart = DateTime(currentDate.year, currentDate.month, currentDate.day, slot[0], 0);
        DateTime slotEnd = DateTime(currentDate.year, currentDate.month, currentDate.day, slot[1], 0);

        // If this is the first day, adjust if the day is partially past
        if (day == 0 && slotIndex == 0 && currentDate.isAfter(slotStart)) {
          // Adjust the slot start time if we've passed the start hour
          slotStart = _adjustSlotStart(currentDate, slotStart);
          if (slotStart.isAfter(slotEnd)) {
            // If the timeslot end is passed, skip to the next slot
            continue;
          }
        }

        // Pick a random place from user preferred places
        if (userPreferredPlaces.isNotEmpty) {
          final place = userPreferredPlaces[random.nextInt(userPreferredPlaces.length)];
          final destinationId = (scheduleProvider.destinations.isEmpty)
              ? 1
              : scheduleProvider.destinations.map((d) => d.id).reduce(max) + 1;

          // Create a destination
          Destination destination = Destination(
            id: destinationId,
            scheduleId: suggestedSchedule.id,
            placeId: place.placeId,
            startDate: slotStart,
            endDate: slotEnd,
            detail: "Suggested by preferences",
          );
          destinations.add(destination);
        }

        currentDate = DateTime(currentDate.year, currentDate.month, currentDate.day).add(Duration(days: day));
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return destinations;
  }

  DateTime _adjustSlotStart(DateTime now, DateTime slotStart) {
    // If current time is after the start of this timeslot,
    // start from the next available hour or partial timeslot if desired
    if (now.isAfter(slotStart)) {
      return now.add(const Duration(hours: 1));
    }
    return slotStart;
  }

  void _onChooseSchedule() {
    // Add the suggested schedule to the schedule list and destinations
    if (suggestedSchedule.id == 0) {
      // No suggested schedule available
      Navigator.pop(context);
      return;
    }

    final scheduleProvider = Provider.of<ScheduleProvider>(context, listen: false);
    scheduleProvider.addSchedule(suggestedSchedule);
    for (var dest in suggestedDestinations) {
      scheduleProvider.addDestination(dest);
    }

    Navigator.pop(context);
  }

  void _onOtherSchedule() {
    // Generate another suggested schedule
    setState(() {
      _generateSuggestedSchedule();
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
            suggestedSchedule.scheduleName,
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
                  const Text("Start Date", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(DateFormat('yyyy-MM-dd hh:mm').format(suggestedSchedule.startDate ?? DateTime.now())),
                ],
              ),
              // End Date
              Column(
                children: [
                  const Text("End Date", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(DateFormat('yyyy-MM-dd hh:mm').format(suggestedSchedule.endDate ?? DateTime.now())),
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
                : const Center(
              child: Text("No destinations available based on your preferences."),
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
                child: const Text("Other"),
              ),
              ElevatedButton(
                onPressed: hasPlaces ? _onChooseSchedule : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text("Choose this"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationList(BuildContext context, List<Destination> destinations) {
    final scheduleProvider = Provider.of<ScheduleProvider>(context, listen: false);

    // Group destinations by day
    Map<String, List<Destination>> destinationsByDay = {};
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
            Text(
              "Day ${DateFormat('MM-dd-yyyy').format(DateTime.parse(day))}",
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, decoration: TextDecoration.underline
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children: dayDestinations.map((dest) {
                final place = scheduleProvider.getPlaceById(dest.placeId);
                // Fetch the place translation for placeName
                final placeTranslation = scheduleProvider.getTranslationByPlaceIdAndLanguage(
                    place?.placeId ?? 0,
                    'en' // assuming the language code is 'en'
                );
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: const BorderSide(color: Colors.black, width: 1),
                  ),
                  margin: const EdgeInsets.only(bottom: 10),
                  color: const Color(0xFFD6B588),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(8.0),
                    leading: place?.photoDisplay != null
                        ? Image.network(
                      place!.photoDisplay,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.photo);
                      },
                    )
                        : const Icon(Icons.photo),
                    title: Text(
                      placeTranslation?.placeName ?? "Unknown Place",
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
