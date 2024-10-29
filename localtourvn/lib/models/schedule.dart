class Schedule {
  int id;
  String userId;
  String scheduleName;
  DateTime? startDate;
  DateTime? endDate;
  DateTime createdDate;
  String status;
  bool isPublic;

  Schedule({
    required this.id,
    required this.userId,
    required this.scheduleName,
    this.startDate,
    this.endDate,
    required this.createdDate,
    required this.status,
    required this.isPublic,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
    id: json['Id'] as int,
    userId: json['UserId'] as String,
    scheduleName: json['ScheduleName'] as String,
    startDate: json['StartDate'] != null
        ? DateTime.parse(json['StartDate'] as String)
        : null,
    endDate: json['EndDate'] != null
        ? DateTime.parse(json['EndDate'] as String)
        : null,
    createdDate: DateTime.parse(json['CreatedDate'] as String),
    status: json['Status'] as String,
    isPublic: json['IsPublic'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'Id': id,
    'UserId': userId,
    'ScheduleName': scheduleName,
    'StartDate': startDate?.toIso8601String(),
    'EndDate': endDate?.toIso8601String(),
    'CreatedDate': createdDate.toIso8601String(),
    'Status': status,
    'IsPublic': isPublic,
  };
}
