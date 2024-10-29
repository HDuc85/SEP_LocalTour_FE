class Tag {
  int tagId;
  String tagPhotoUrl;
  String tagName;

  Tag({required this.tagId,required this.tagPhotoUrl, required this.tagName});

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      tagId: json['tagId'],
      tagPhotoUrl: json['tagPhotoUrl'],
      tagName: json['tagName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tagId': tagId,
      'tagPhotoUrl': tagPhotoUrl,
      'tagName': tagName,
    };
  }
}

List<Tag> listTag = [
  Tag(tagId: 1, tagPhotoUrl: 'assets/images/Living.png', tagName: 'Living'),
  Tag(tagId: 2, tagPhotoUrl: 'assets/images/Park.png', tagName: 'Park'),
  Tag(tagId: 3, tagPhotoUrl: 'assets/images/Shopping Mall.png', tagName: 'Shopping Mall'),
  Tag(tagId: 4, tagPhotoUrl: 'assets/images/Food & Drink.png', tagName: 'Food & Drink'),
  Tag(tagId: 5, tagPhotoUrl: 'assets/images/Night Entertainment.png', tagName: 'Night Entertainment'),
  Tag(tagId: 6, tagPhotoUrl: 'assets/images/Cinema.png', tagName: 'Cinema'),
  Tag(tagId: 7, tagPhotoUrl: 'assets/icons/Eco-tourism area.png', tagName: 'Eco-tourism area'),
  Tag(tagId: 8, tagPhotoUrl: 'assets/icons/Museum.png', tagName: 'Museum'),
  Tag(tagId: 9, tagPhotoUrl: 'assets/icons/Historical site.png', tagName: 'Historical site'),
  Tag(tagId: 10, tagPhotoUrl: 'assets/icons/Playground.png', tagName: 'Playground'),
  Tag(tagId: 11, tagPhotoUrl: 'assets/icons/Quarter.png', tagName: 'Quarter'),
  Tag(tagId: 12, tagPhotoUrl: 'assets/icons/Market-Supermarket.png', tagName: 'Market-Supermarket'),
];
