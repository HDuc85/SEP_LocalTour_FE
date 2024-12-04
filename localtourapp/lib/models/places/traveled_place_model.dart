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
      placeName: json['placeName']??'Unknown place name',
      placePhotoDisplay: json['placePhotoDisplay'],
      wardName: json['wardName'] ?? 'Unknown Ward',
      firstVisitDate: json['firstVisitDate'] != null
          ? DateTime.parse(json['firstVisitDate']).toUtc()
          : DateTime.fromMillisecondsSinceEpoch(0).toUtc(), // Default to Unix epoch if null
      lastVisitDate: json['lastVisitDate'] != null
          ? DateTime.parse(json['lastVisitDate']).toUtc()
          : DateTime.fromMillisecondsSinceEpoch(0).toUtc(),
      traveledTimes: json['traveledTimes'] ?? 0,
    );
  }
}
