class EventModel {
  final int placeId;
  final String placeName;
  final double latitude;
  final double longitude;
  final String? eventPhoto;
  final String? placePhoto;
  final String eventName;
  final double distance;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String eventStatus;

  EventModel({
    required this.placeId,
    required this.placeName,
    required this.latitude,
    required this.longitude,
    this.eventPhoto,
    this.placePhoto,
    required this.eventName,
    required this.distance,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.eventStatus,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      placeId: json['placeId'] as int,
      placeName: json['placeName'] ?? "Unknown Place",
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      eventPhoto: json['eventPhoto'] as String?,
      placePhoto: json['placePhoto'] as String?,
      eventName: json['eventName'] as String,
      distance: (json['distance'] as num).toDouble(),
      description: json['description'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      eventStatus: json['eventStatus'] as String,
    );
  }
}

  List<EventModel> mapJsonToEventModels(List<dynamic> jsonData) {
    return jsonData.map((data) => EventModel.fromJson(data)).toList();
  }