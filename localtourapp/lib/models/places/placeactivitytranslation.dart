import 'dart:math';

import 'placeactivity.dart';

class PlaceActivityTranslation {
  final int id;
  final int placeActivityId;
  final String languageCode; // 'en', 'vn', 'cn'
  final String activityName;
  final double price;
  final String? description; // Nullable field
  final String priceType; // 'VND'
  final double? discount; // Nullable field, discount in %

  PlaceActivityTranslation({
    required this.id,
    required this.placeActivityId,
    required this.languageCode,
    required this.activityName,
    required this.price,
    this.description, // Nullable
    required this.priceType,
    this.discount, // Nullable
  });

  // Factory constructor for creating a PlaceActivityTranslation from JSON
  factory PlaceActivityTranslation.fromJson(Map<String, dynamic> json) {
    return PlaceActivityTranslation(
      id: json['id'],
      placeActivityId: json['placeActivityId'],
      languageCode: json['languageCode'],
      activityName: json['activityName'],
      price: json['price'].toDouble(), // Ensure price is double
      description: json['description'], // Nullable field
      priceType: json['priceType'],
      discount: json['discount']?.toDouble(), // Nullable field
    );
  }

  // Method to convert a PlaceActivityTranslation instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'placeActivityId': placeActivityId,
      'languageCode': languageCode,
      'activityName': activityName,
      'price': price,
      'description': description, // Nullable field
      'priceType': priceType,
      'discount': discount, // Nullable field
    };
  }
}

// Function to generate PlaceActivityTranslation data, where each PlaceActivity has only 1 translation
List<PlaceActivityTranslation> generatePlaceActivityTranslations(List<PlaceActivity> placeActivities) {
  final random = Random();
  List<String> languageCodes = ['en', 'vn', 'cn']; // Supported language codes
  List<String> priceTypes = ['VND']; // Supported price types
  List<PlaceActivityTranslation> placeActivityTranslations = [];

  // Ensure each PlaceActivity has exactly one translation
  for (PlaceActivity placeActivity in placeActivities) {
    // Randomly select a language code
    String languageCode = languageCodes[random.nextInt(languageCodes.length)];
    // Generate a random activity name
    String activityName = 'Activity Name ${placeActivity.id}';
    // Generate a random price between 10 and 500 (example price range)
    double price = random.nextDouble() * 490 + 10;
    // Optionally generate a description (nullable)
    String? description = random.nextBool() ? 'Description for Activity Description for Activity'
        'Description for ActivityDescription for ActivityDescription for ActivityDescription for Activity'
        'Description for ActivityDescription for ActivityDescription for ActivityDescription for Activity${placeActivity.id}' : null;
    // Randomly select a price type ('VND' or 'Dollar')
    String priceType = priceTypes[random.nextInt(priceTypes.length)];
    // Optionally generate a discount as a percentage (nullable)
    double? discount = random.nextBool() ? random.nextDouble() * 100 : null;

    // Create the PlaceActivityTranslation for this PlaceActivity
    PlaceActivityTranslation placeActivityTranslation = PlaceActivityTranslation(
      id: placeActivity.id, // Use the same id as the PlaceActivity
      placeActivityId: placeActivity.id, // Link to the corresponding PlaceActivity
      languageCode: languageCode,
      activityName: activityName,
      price: price,
      description: description,
      priceType: priceType,
      discount: discount,
    );

    placeActivityTranslations.add(placeActivityTranslation);
  }

  return placeActivityTranslations;
}

// Usage: Ensure 1-to-1 relationship between PlaceActivity and PlaceActivityTranslation
List<PlaceActivityTranslation> placeActivityTranslations = generatePlaceActivityTranslations(randomActivities);

