class UserBan {
  int id;
  String userId;
  DateTime endDate;

  UserBan({
    required this.id,
    required this.userId,
    required this.endDate,
  });

  factory UserBan.fromJson(Map<String, dynamic> json) => UserBan(
    id: json['Id'] as int,
    userId: json['UserId'] as String,
    endDate: DateTime.parse(json['EndDate'] as String),
  );

  Map<String, dynamic> toJson() => {
    'Id': id,
    'UserId': userId,
    'EndDate': endDate.toIso8601String(),
  };
}
