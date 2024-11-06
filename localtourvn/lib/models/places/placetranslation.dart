import 'dart:math';
import 'place.dart';

class PlaceTranslation {
  int placeTranslationId;
  int placeId; // Maps to placeId in Place
  String languageCode; // 'vn', 'en', 'cn'
  String placeName;
  String? description; // Nullable field
  String address;
  String? contact; // Nullable field

  PlaceTranslation({
    required this.placeTranslationId,
    required this.placeId,
    required this.languageCode,
    required this.placeName,
    this.description,
    required this.address,
    this.contact,
  });

  // Factory method to create a PlaceTranslation object from JSON
  factory PlaceTranslation.fromJson(Map<String, dynamic> json) {
    return PlaceTranslation(
      placeTranslationId: json['placeTranslationId'],
      placeId: json['placeId'],
      languageCode: json['languageCode'],
      placeName: json['Name'],
      description: json['description'], // Nullable
      address: json['address'],
      contact: json['contact'], // Nullable
    );
  }

  // Method to convert a PlaceTranslation object to JSON
  Map<String, dynamic> toJson() {
    return {
      'placeTranslationId': placeTranslationId,
      'placeId': placeId,
      'languageCode': languageCode,
      'Name': placeName,
      'description': description, // Nullable
      'address': address,
      'contact': contact, // Nullable
    };
  }
}

// Function to generate random PlaceTranslation data
List<PlaceTranslation> generatePlaceTranslations(List<Place> places) {
  final random = Random();
  List<String> languageCodes = ['vn', 'en', 'cn']; // Supported language codes
  List<PlaceTranslation> translations = [];

  for (int i = 0; i < places.length; i++) {
    int placeTranslationId = i + 1; // Sequential placeTranslationId
    int placeId = places[i].placeId; // Get placeId from the Place list directly

    // Randomly select a language code
    String languageCode = languageCodes[random.nextInt(languageCodes.length)];

    // Generate a random place name
    String placeName = 'Place Name Place NamePlace NamePlace NamePlace NamePlace NamePlace NamePlace Name $placeTranslationId';

    // Optionally generate a description (nullable)
    String? description =
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut '
        'labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco'
        ' laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in vo'
        'luptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non p'
        'roident, sunt in culpa qui officia deserunt mollit anim id est laborum...Lorem ipsum dolor sit amet, '
        'consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim '
        'ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis au'
        'te irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint'
        ' occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum...Lorem ipsum do'
        'lor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut e'
        'nim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in'
        ;

    // Generate a random address
    String address = 'Address $placeTranslationId, City, Country';

    // Optionally generate a contact (nullable)
    String? contact = random.nextBool() ? 'Contact for this place $placeTranslationId' : null;

    PlaceTranslation translation = PlaceTranslation(
      placeTranslationId: placeTranslationId,
      placeId: placeId,
      languageCode: languageCode,
      placeName: placeName,
      description: description,
      address: address,
      contact: contact,
    );

    translations.add(translation);
  }

  return translations;
}


List<PlaceTranslation> translations = generatePlaceTranslations(dummyPlaces);