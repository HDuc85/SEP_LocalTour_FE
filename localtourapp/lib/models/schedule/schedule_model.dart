import 'package:localtourapp/models/schedule/destination_model.dart';

class ScheduleModel {
  int id;
  String userId;
  String? userName;
  String? userProfileImage;
  String scheduleName;
  DateTime? startDate;
  DateTime? endDate;
  DateTime createdDate;
  String status;
  bool isPublic;
  List<DestinationModel> destinations;
  int totalLikes;
  bool isLiked;

  ScheduleModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userProfileImage,
    required this.scheduleName,
     this.startDate,
     this.endDate,
    required this.createdDate,
    required this.status,
    required this.isPublic,
    required this.destinations,
    required this.totalLikes,
    required this.isLiked,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userProfileImage: json['userProfileImage'] ?? '',
      scheduleName: json['scheduleName'] ?? '',
      startDate: json['startDate'] != null ?DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ?DateTime.parse(json['endDate']) : null,
      createdDate: DateTime.parse(json['createdDate']),
      status: json['status']?? '',
      isPublic: json['isPublic'],
      destinations: (json['destinations'] as List)
          .map((e) => DestinationModel.fromJson(e))
          .toList(),
      totalLikes: json['totalLikes'],
      isLiked: json['isLiked'],
    );
  }

}

List<ScheduleModel> mapJsonToScheduleModel(List<dynamic> jsonData) {
  return jsonData.map((data) => ScheduleModel.fromJson(data)).toList();
}