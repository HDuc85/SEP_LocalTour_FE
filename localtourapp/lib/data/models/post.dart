class Post {
  final int id;
  final String authorId;
  final int placeId;
  final double longitude;
  final double latitude;
  final String title;
  final DateTime createdDate;
  final DateTime updateDate;
  final String content;
  final bool isPublic;

  Post({
    required this.id,
    required this.authorId,
    required this.placeId,
    required this.longitude,
    required this.latitude,
    required this.title,
    required this.createdDate,
    required this.updateDate,
    required this.content,
    required this.isPublic,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      authorId: json['authorId'] as String,
      placeId: json['placeId'] as int,
      longitude: json['longitude'] as double,
      latitude: json['latitude'] as double,
      title: json['title'] as String,
      createdDate: DateTime.parse(json['createdDate']),
      updateDate: DateTime.parse(json['updateDate']),
      content: json['content'] as String,
      isPublic: json['isPublic'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'placeId': placeId,
      'longitude': longitude,
      'latitude': latitude,
      'title': title,
      'createdDate': createdDate.toIso8601String(),
      'updateDate': updateDate.toIso8601String(),
      'content': content,
      'isPublic': isPublic,
    };
  }
}
