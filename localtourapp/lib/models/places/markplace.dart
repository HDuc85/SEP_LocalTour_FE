class MarkPlace {
  int markPlaceId;
  String userId;
  int placeId;
  DateTime createdDate;
  bool isVisited;

  MarkPlace({
    required this.markPlaceId,
    required this.userId,
    required this.placeId,
    required this.createdDate,
    required this.isVisited,
  });

  factory MarkPlace.fromJson(Map<String, dynamic> json) {
    return MarkPlace(
      markPlaceId: json['markPlaceId'],
      userId: json['userId'],
      placeId: json['placeId'],
      createdDate: DateTime.parse(json['createdDate']),
      isVisited: json['isVisited'],
    );
  }

  Map<String, dynamic> toJson() => {
    'markPlaceId': markPlaceId,
    'userId': userId,
    'placeId': placeId,
    'createdDate': createdDate.toIso8601String(),
    'isVisited': isVisited,
  };
}
