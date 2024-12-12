class TraveledPlaceModel {
  final String placeName;
  final String placePhotoDisplay;
  final String wardName;
  final DateTime firstVisitDate;
  final DateTime lastVisitDate;
  final int traveledTimes;

  TraveledPlaceModel({
    required this.placeName,
    required this.placePhotoDisplay,
    required this.wardName,
    required this.firstVisitDate,
    required this.lastVisitDate,
    required this.traveledTimes,
  });
  factory TraveledPlaceModel.fromJson(Map<String, dynamic> json) {
    return TraveledPlaceModel(
      placeName: json['place']['placeName']??'Unknown place name',
      placePhotoDisplay: json['place']['placePhotoDisplay'] ?? '',
      wardName: json['place']['wardName'] ?? 'Unknown Ward',
      firstVisitDate: json['place']['firstVisitDate'] != null
          ? DateTime.parse(json['place']['firstVisitDate']).toUtc()
          : DateTime.fromMillisecondsSinceEpoch(0).toUtc(), // Default to Unix epoch if null
      lastVisitDate: json['place']['lastVisitDate'] != null
          ? DateTime.parse(json['place']['lastVisitDate']).toUtc()
          : DateTime.fromMillisecondsSinceEpoch(0).toUtc(),
      traveledTimes: json['traveledTimes'] ?? 0,
    );
  }
}
