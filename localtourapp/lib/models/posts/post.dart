class Post {
  int id;
  String authorId;
  int? placeId;
  int? scheduleId;
  double longitude;
  double latitude;
  String title;
  DateTime createdDate;
  DateTime updateDate;
  String content;
  bool isPublic;

  Post({
    required this.id,
    required this.authorId,
    this.placeId,
    this.scheduleId,
    required this.longitude,
    required this.latitude,
    required this.title,
    required this.createdDate,
    required this.updateDate,
    required this.content,
    required this.isPublic,
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: json['Id'] as int,
    authorId: json['AuthorId'] as String,
    placeId: json['PlaceId'] != null ? json['PlaceId'] as int : null,
    scheduleId:
    json['ScheduleId'] != null ? json['ScheduleId'] as int : null,
    longitude: (json['Longitude'] as num).toDouble(),
    latitude: (json['Latitude'] as num).toDouble(),
    title: json['Title'] as String,
    createdDate: DateTime.parse(json['CreatedDate'] as String),
    updateDate: DateTime.parse(json['UpdateDate'] as String),
    content: json['Content'] as String,
    isPublic: json['Public'] as bool,
  );

  Map<String, dynamic> toJson() => {
    'Id': id,
    'AuthorId': authorId,
    'PlaceId': placeId,
    'ScheduleId': scheduleId,
    'Longitude': longitude,
    'Latitude': latitude,
    'Title': title,
    'CreatedDate': createdDate.toIso8601String(),
    'UpdateDate': updateDate.toIso8601String(),
    'Content': content,
    'Public': isPublic,
  };
}
