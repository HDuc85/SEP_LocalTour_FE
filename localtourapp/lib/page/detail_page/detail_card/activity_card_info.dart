
import '../../../models/places/placeactivity.dart';
import '../../../models/places/placeactivitymedia.dart';
import '../../../models/places/placeactivitytranslation.dart';

class ActivityCardInfo {
  final int placeActivityId;
  final String activityName;
  final String? photoDisplay;
  final double price;
  final String priceType;
  final double? discount;
  final int displayNumber;
  final String? description;
  final String photoDisplayUrl;

  ActivityCardInfo({
    required this.placeActivityId,
    required this.activityName,
    this.photoDisplay,
    required this.price,
    required this.priceType,
    this.discount,
    required this.displayNumber,
    this.description,
    required this.photoDisplayUrl,
  });
}

List<ActivityCardInfo> getActivityCards(
    int placeId,
    List<PlaceActivity> activities,
    List<PlaceActivityTranslation> placeActivityTranslations,
    List<PlaceActivityMedia> placeActivityMedias,
    ) {
  List<ActivityCardInfo> activityCards = activities
      .where((activity) => activity.placeId == placeId) // Filter by placeId
      .map((activity) {
    // Find the matching translation for the activity
    PlaceActivityTranslation placeActivityTranslation =
    placeActivityTranslations.firstWhere(
          (t) => t.placeActivityId == activity.id,
      orElse: () => PlaceActivityTranslation(
        id: 0, // Default values for missing translation
        placeActivityId: activity.id,
        languageCode: 'en',
        activityName: 'Unknown Activity', // Default name
        price: 0.0,
        description: null,
        priceType: 'USD',
        discount: null,
      ),
    );

    // Find the matching media for the activity
    PlaceActivityMedia placeActivityMedia = placeActivityMedias.firstWhere(
          (media) => media.placeActivityId == activity.id,
      orElse: () => PlaceActivityMedia(
        id: 0, // Default id for missing media
        placeActivityId: activity.id,
        type: 'photo',
        url: 'assets/videos/video_1.mp4', // Default placeholder asset
        createDate: DateTime.now(),
      ),
    );

    return ActivityCardInfo(
      placeActivityId: activity.id,
      description: placeActivityTranslation.description,
      activityName: placeActivityTranslation.activityName,
      photoDisplay: activity.photoDisplay, // Use media URL for the photo
      price: placeActivityTranslation.price,
      priceType: placeActivityTranslation.priceType,
      discount: placeActivityTranslation.discount,
      displayNumber: activity.displayNumber,
      photoDisplayUrl: placeActivityMedia.url,
    );
  }).toList();

  activityCards.sort((a, b) => a.displayNumber.compareTo(b.displayNumber));

  return activityCards.take(5).toList(); // Take only top 5 cards
}
