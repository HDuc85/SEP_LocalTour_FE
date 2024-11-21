class TagModel {
  final int id;
  final String tagName;
  final String tagPhotoUrl;

  TagModel({
    required this.id,
    required this.tagName,
    required this.tagPhotoUrl,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['id'],
      tagName: json['tagName'],
      tagPhotoUrl: json['tagPhotoUrl'],
    );
  }
 }
List<TagModel> mapJsonToTags(List<dynamic> jsonData) {
  return jsonData.map((data) => TagModel.fromJson(data)).toList();
}