class Destination {
  int id;
  int scheduleId;
  int placeId;
  DateTime? startDate;
  DateTime? endDate;
  String? detail;
  bool isArrived;

  Destination({
    required this.id,
    required this.scheduleId,
    required this.placeId,
    this.startDate,
    this.endDate,
    this.detail,
    required this.isArrived,
  });

  factory Destination.fromJson(Map<String, dynamic> json) => Destination(
    id: json['Id'] as int,
    scheduleId: json['ScheduleId'] as int,
    placeId: json['PlaceId'] as int,
    startDate: json['StartDate'] != null
        ? DateTime.parse(json['StartDate'] as String)
        : null,
    endDate: json['EndDate'] != null
        ? DateTime.parse(json['EndDate'] as String)
        : null,
    detail: json['Detail'] as String?,
    isArrived: json['IsArrived'] as bool,
  );

  Map<String, dynamic> toJson() => {
    'Id': id,
    'ScheduleId': scheduleId,
    'PlaceId': placeId,
    'StartDate': startDate?.toIso8601String(),
    'EndDate': endDate?.toIso8601String(),
    'Detail': detail,
    'IsArrived': isArrived,
  };
}
