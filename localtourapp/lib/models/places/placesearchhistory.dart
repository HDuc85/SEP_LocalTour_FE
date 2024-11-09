class PlaceSearchHistory {
  int id;
  String userId;
  int placeId;
  DateTime lastSearch;

  PlaceSearchHistory({
    required this.id,
    required this.userId,
    required this.placeId,
    required this.lastSearch,
  });

  factory PlaceSearchHistory.fromJson(Map<String, dynamic> json) =>
      PlaceSearchHistory(
        id: json['Id'] as int,
        userId: json['UserId'] as String,
        placeId: json['PlaceId'] as int,
        lastSearch: DateTime.parse(json['LastSearch'] as String),
      );

  Map<String, dynamic> toJson() => {
    'Id': id,
    'UserId': userId,
    'PlaceId': placeId,
    'LastSearch': lastSearch.toIso8601String(),
  };
}
