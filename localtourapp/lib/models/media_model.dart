class MediaModel {
  final String type;
  final String url;

  MediaModel({
    required this.type,
    required this.url,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    // Normalize type to lowercase and map common variations to 'photo' or 'video'
    String normalizedType = (json['type'] ?? '').toLowerCase();
    if (['image', 'photo', 'picture'].contains(normalizedType)) {
      normalizedType = 'photo';
    } else if (['video', 'clip', 'movie'].contains(normalizedType)) {
      normalizedType = 'video';
    }

    return MediaModel(
      type: normalizedType,
      url: json['url'] ?? '',
    );
  }
}