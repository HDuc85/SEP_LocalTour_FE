class DestinationModel {
  int id;
  int scheduleId;
  int placeId;
  DateTime? startDate;
  DateTime? endDate;
  String detail;
  bool isArrived;
  String? placePhotoDisplay;
  String placeName;
  double longitude;
  double latitude;

  DestinationModel({
    required this.id,
    required this.scheduleId,
    required this.placeId,
    this.startDate,
    this.endDate,
    required this.detail,
    required this.isArrived,
    this.placePhotoDisplay,
    required this.placeName,
    required this.longitude,
    required this.latitude
  });

  factory DestinationModel.fromJson(Map<String, dynamic> json) {
    return DestinationModel(
      id: json['id'],
      scheduleId: json['scheduleId'],
      placeId: json['placeId'],
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : null,
      detail: json['detail'] != null ?json['detail'] : '',
      isArrived: json['isArrived'],
      placePhotoDisplay: json['placePhotoDisplay']??'',
      placeName: json['placeName']??'Unknown place name',
      latitude: (json['latitude']).toDouble(),
      longitude: (json['longitude']).toDouble()
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "scheduleId": scheduleId,
      "placeId": placeId,
      "startDate": startDate!.toUtc().toIso8601String(),
      "endDate": endDate!.toUtc().toIso8601String(),
      "detail": detail,
      "isArrived": isArrived,
      "placePhotoDisplay": placePhotoDisplay,
      "placeName": placeName,
    };
  }
}

List<DestinationModel> mapJsonToDestinationModel(List<dynamic> jsonData) {
  return jsonData.map((data) => DestinationModel.fromJson(data)).toList();
}