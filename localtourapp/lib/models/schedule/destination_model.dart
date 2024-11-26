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
    );
  }

}

List<DestinationModel> mapJsonToScheduleModel(List<dynamic> jsonData) {
  return jsonData.map((data) => DestinationModel.fromJson(data)).toList();
}