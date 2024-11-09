class NotificationModel {
  int id;
  String userId;
  String notificationType;
  String title;
  String message;
  DateTime timeSend;
  DateTime dateCreated;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.notificationType,
    required this.title,
    required this.message,
    required this.timeSend,
    required this.dateCreated,
    required this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json['Id'] as int,
        userId: json['UserId'] as String,
        notificationType: json['NotificationType'] as String,
        title: json['Title'] as String,
        message: json['Message'] as String,
        timeSend: DateTime.parse(json['TimeSend'] as String),
        dateCreated: DateTime.parse(json['DateCreated'] as String),
        isRead: json['IsRead'] as bool,
      );

  Map<String, dynamic> toJson() => {
    'Id': id,
    'UserId': userId,
    'NotificationType': notificationType,
    'Title': title,
    'Message': message,
    'TimeSend': timeSend.toIso8601String(),
    'DateCreated': dateCreated.toIso8601String(),
    'IsRead': isRead,
  };
}
