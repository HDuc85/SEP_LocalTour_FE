
import '../media_model.dart';

class PlaceActivityModel {
  final int id;
  final int displayNumber;
  final String photoDisplay;
  final String activityName;
  final double price;
  final String description;
  final String priceType;
  final double discount;
  final List<MediaModel> placeActivityMedia;

  PlaceActivityModel({
    required this.id,
    required this.displayNumber,
    required this.photoDisplay,
    required this.placeActivityMedia,
    required this.activityName,
    required this.description,
    required this.discount,
    required this.price,
    required this.priceType
  });
  factory PlaceActivityModel.fromJson(Map<String, dynamic> json) {
    return PlaceActivityModel(
      id: json['id'],
      displayNumber: json['displayNumber'],
      photoDisplay: json['photoDisplay'],
      placeActivityMedia: (json['placeActivityMedia'] as List)
          .map((e) => MediaModel.fromJson(e))
          .toList(),
      activityName: json['placeActivityTranslations'][0]['activityName'],
      description: json['placeActivityTranslations'][0]['description'],
      discount: (json['placeActivityTranslations'][0]['discount']).toDouble(),
      price: (json['placeActivityTranslations'][0]['price']).toDouble(),
      priceType: json['placeActivityTranslations'][0]['priceType']
    );
  }


}