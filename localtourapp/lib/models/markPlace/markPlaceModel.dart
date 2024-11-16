class markPlaceModel {
  int placeId;
  String placeName;
  String photoDisplay;
  bool isVisited;
  DateTime createdDate;

  markPlaceModel({
    required this.placeId,
    required this.placeName,
    required this.photoDisplay,
    required this.isVisited,
    required this.createdDate,
  });

  factory markPlaceModel.fromJson(Map<String, dynamic> json) {
    return markPlaceModel(
      placeId: json['placeId'],
      placeName: json['placeName'],
      photoDisplay: json['photoDisplay'],
      isVisited: json['isVisited'],
      createdDate: DateTime.parse(json['createdDate']),
    );
  }
}
