import 'dart:math';
import 'placeactivity.dart'; // Assuming you have a PlaceActivity class defined

class PlaceActivityMedia {
  int id;
  int placeActivityId;
  String type;
  String url;
  DateTime createDate;

  PlaceActivityMedia({
    required this.id,
    required this.placeActivityId,
    required this.type,
    required this.url,
    required this.createDate,
  });

  factory PlaceActivityMedia.fromJson(Map<String, dynamic> json) =>
      PlaceActivityMedia(
        id: json['Id'] as int,
        placeActivityId: json['PlaceActivityId'] as int,
        type: json['Type'] as String,
        url: json['Url'] as String,
        createDate: DateTime.parse(json['CreateDate'] as String),
      );

  Map<String, dynamic> toJson() => {
    'Id': id,
    'PlaceActivityId': placeActivityId,
    'Type': type,
    'Url': url,
    'CreateDate': createDate.toIso8601String(),
  };
}

// Function to generate random PlaceActivityMedia data
List<PlaceActivityMedia> generatePlaceActivityMedias(int count, List<PlaceActivity> placeActivities) {
  final random = Random();
  List<String> mediaTypes = ['video', 'photo']; // Define the media types list

  List<PlaceActivityMedia> placeActivityMedias = [];

  for (int i = 0; i < count; i++) {
    int id = i + 1; // Sequential id for PlaceActivityMedia
    // Randomly select a placeActivityId from the provided PlaceActivity list
    int placeActivityId = placeActivities[random.nextInt(placeActivities.length)].id;
    // Randomly select a media type ('video' or 'photo')
    String type = mediaTypes[random.nextInt(mediaTypes.length)];
    // Generate a random media URL based on the type (either 'video' or 'photo')
    String url = (type == 'video')
        ? 'assets/videos/video_${random.nextInt(3) + 1}.mp4'
        : 'https://picsum.photos/seed/${random.nextInt(1000)}/600/400';
    // Randomly generate a creation date within the past 30 days
    DateTime createDate = DateTime.now().subtract(Duration(days: random.nextInt(30)));

    PlaceActivityMedia placeActivityMedia = PlaceActivityMedia(
      id: id,
      placeActivityId: placeActivityId,
      type: type,
      url: url,
      createDate: createDate,
    );

    placeActivityMedias.add(placeActivityMedia);
  }

  return placeActivityMedias;
}

List<PlaceActivityMedia> mediaActivityList = generatePlaceActivityMedias(2000, randomActivities);
