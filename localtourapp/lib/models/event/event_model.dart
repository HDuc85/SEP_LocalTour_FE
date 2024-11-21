class EventModel {
  final String eventName;
  final String description;
  final DateTime startDate;
  final DateTime endDate;

  EventModel({
    required this.eventName,
    required this.description,
    required this.startDate,
    required this.endDate,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      eventName: json['eventName'],
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
    );
  }
}

  List<EventModel> mapJsonToEventModels(List<dynamic> jsonData) {
    return jsonData.map((data) => EventModel.fromJson(data)).toList();
  }