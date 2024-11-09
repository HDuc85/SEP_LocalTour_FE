import 'dart:math';
import 'package:localtourvn/models/places/place.dart';

class Event {
  int eventId;
  int placeId;
  String eventName;
  String? description; // Nullable
  DateTime startDate;
  DateTime endDate;
  String eventStatus;
  DateTime createdAt;
  DateTime updatedAt;

  Event({
    required this.eventId,
    required this.placeId,
    required this.eventName,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.eventStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor for creating an Event from JSON
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventId: json['eventId'],
      placeId: json['placeId'],
      eventName: json['eventName'],
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      eventStatus: json['eventStatus'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Method to convert an Event object to JSON
  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'placeId': placeId,
      'eventName': eventName,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'eventStatus': eventStatus,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// Function to generate dummy events with placeId from the Place list
List<Event> generateDummyEvents(int count, List<Place> places) {
  final random = Random();
  List<Event> events = [];

  // Define possible statuses
  List<String> statuses = ['unapproved', 'about to open', 'is opening', 'has closed'];

  for (int i = 0; i < count; i++) {
    int eventId = i + 1;

    // Randomly select a placeId from the list of Place objects (some places may have no events, others multiple)
    int placeId = places[random.nextInt(places.length)].placeId;

    String eventName = 'Event $eventId';

    // Randomly decide whether to include a description
    String description = 'Description for Event Description for Event Description for Event Description for Event '
        'Description for Event Description for Event Description for Event Description for Event Description for Event '
        'Description for Event Description for Event Description for Event Description for Event Description for Event '
        'Description for Event Description for Event Description for Event Description for Event '
        'Description for Event Description for Event Description for Event Description for Event Description for Event '
        'Description for Event Description for Event Description for Event Description for Event Description for Event'
        'Description for Event Description for Event Description for Event Description for Event '
        'Description for Event Description for Event Description for Event Description for Event Description for Event '
        'Description for Event Description for Event Description for Event Description for Event Description for Event'
        'Description for Event Description for Event Description for Event Description for Event '
        'Description for Event Description for Event Description for Event Description for Event Description for Event '
        'Description for Event Description for Event Description for Event Description for Event Description for Event'
        'Description for Event Description for Event Description for Event Description for Event '
        'Description for Event Description for Event Description for Event Description for Event Description for Event '
        'Description for Event Description for Event Description for Event Description for Event Description for Event'
        'Description for Event Description for Event Description for Event Description for Event '
        'Description for Event Description for Event Description for Event Description for Event Description for Event '
        'Description for Event Description for Event Description for Event Description for Event Description for Event $eventId';

    // Generate startDate and endDate
    DateTime now = DateTime.now();
    DateTime startDate = now.add(Duration(days: random.nextInt(30))); // Start within next 30 days
    DateTime endDate = startDate.add(Duration(days: random.nextInt(5) + 1)); // Lasts 1 to 5 days

    // For new events, createdAt and updatedAt are the same
    DateTime createdAt = now.subtract(Duration(days: random.nextInt(10))); // Created within last 10 days
    DateTime updatedAt = createdAt;

    // Randomly select an event status
    String eventStatus = statuses[random.nextInt(statuses.length)];

    Event event = Event(
      eventId: eventId,
      placeId: placeId, // Ensure the placeId comes from the Place object
      eventName: eventName,
      description: description,
      startDate: startDate,
      endDate: endDate,
      eventStatus: eventStatus,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    events.add(event);
  }

  return events;
}

// Sample usage
List<Event> dummyEvents = generateDummyEvents(200, dummyPlaces);
