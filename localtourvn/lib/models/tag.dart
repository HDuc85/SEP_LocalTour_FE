class Tag{
  late String thumpnail;
  late String nameTag;

Tag({
  required this.thumpnail,
  required this.nameTag,
});
}

List<Tag> tagList = [
  Tag(
    thumpnail: 'assets/living.png',
    nameTag: 'Living'
  ),
  Tag(
      thumpnail: 'assets/park.png',
      nameTag: 'Park'
  ),
  Tag(
      thumpnail: 'assets/shopping_mall.png',
      nameTag: 'Shopping mall'
  ),
  Tag(
      thumpnail: 'assets/food_drink.png',
      nameTag: 'Food & Drink'
  ),
  Tag(
      thumpnail: 'assets/night_entertainment.png',
      nameTag: 'Night Entertainment'
  ),
  Tag(
      thumpnail: 'assets/schedule_featured.png',
      nameTag: 'Schedule Featured'
  ),
];