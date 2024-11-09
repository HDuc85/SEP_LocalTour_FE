class UserReport {
  int id;
  String userId;
  DateTime reportDate;
  String status;

  UserReport({
    required this.id,
    required this.userId,
    required this.reportDate,
    required this.status,
  });

  factory UserReport.fromJson(Map<String, dynamic> json) => UserReport(
    id: json['Id'] as int,
    userId: json['UserId'] as String,
    reportDate: DateTime.parse(json['ReportDate'] as String),
    status: json['Status'] as String,
  );

  Map<String, dynamic> toJson() => {
    'Id': id,
    'UserId': userId,
    'ReportDate': reportDate.toIso8601String(),
    'Status': status,
  };
}
