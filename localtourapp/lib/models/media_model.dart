class MediaModel {
  final String type;
  final String url;

  MediaModel({
    required this.type,
    required this.url,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      type: json['type'],
      url: json['url'],
    );
  }
}