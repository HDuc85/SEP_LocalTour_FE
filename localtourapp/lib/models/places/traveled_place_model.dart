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
    final placeJson = json['place'] ?? {};
    return TraveledPlaceModel(
      placeName: placeJson['placeName'] ?? 'Unknown placeName',
      placePhotoDisplay: placeJson['placePhotoDisplay'] ?? '',
      wardName: placeJson['wardName'] ?? 'Unknown Ward',
      firstVisitDate: placeJson['firstVisitDate'] != null
          ? DateTime.parse(placeJson['firstVisitDate']).toUtc()
          : DateTime.fromMillisecondsSinceEpoch(0).toUtc(), // Default to Unix epoch if null
      lastVisitDate: placeJson['lastVisitDate'] != null
          ? DateTime.parse(placeJson['lastVisitDate']).toUtc()
          : DateTime.fromMillisecondsSinceEpoch(0).toUtc(),
      traveledTimes: json['traveledTimes'] ?? 0,
    );
  }
}
