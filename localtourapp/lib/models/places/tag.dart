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
  Tag(tagId: 1, tagPhotoUrl: 'assets/icons/Hotel.png', tagName: 'Living'),
  Tag(tagId: 2, tagPhotoUrl: 'assets/icons/Park.png', tagName: 'Park'),
  Tag(tagId: 3, tagPhotoUrl: 'assets/icons/Shopping mall.png', tagName: 'Shopping Mall'),
  Tag(tagId: 4, tagPhotoUrl: 'assets/icons/Cocktail.png', tagName: 'Food & Drink'),
  Tag(tagId: 5, tagPhotoUrl: 'assets/icons/night club.png', tagName: 'Night Entertainment'),
  Tag(tagId: 6, tagPhotoUrl: 'assets/icons/Cinema.png', tagName: 'Cinema'),
  Tag(tagId: 7, tagPhotoUrl: 'assets/icons/Biodegradable.png', tagName: 'Eco-tourism area'),
  Tag(tagId: 8, tagPhotoUrl: 'assets/icons/Museum.png', tagName: 'Museum'),
  Tag(tagId: 9, tagPhotoUrl: 'assets/icons/Historic site.png', tagName: 'Historical site'),
  Tag(tagId: 10, tagPhotoUrl: 'assets/icons/Playground.png', tagName: 'Playground'),
  Tag(tagId: 11, tagPhotoUrl: 'assets/icons/Village.png', tagName: 'Quarter'),
  Tag(tagId: 12, tagPhotoUrl: 'assets/icons/Grocery cart.png', tagName: 'Market-Supermarket'),
];
