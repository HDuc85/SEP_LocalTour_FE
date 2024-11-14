import 'dart:math';

import 'placefeedback.dart';

class PlaceFeedbackMedia {
  int id;
  int feedbackId; // Maps to feedbackId in PlaceFeedback
  String type; // Either 'video' or 'photo'
  String url; // URL for the media
  DateTime createDate;

  PlaceFeedbackMedia({
    required this.id,
    required this.feedbackId,
    required this.type,
    required this.url,
    required this.createDate,
  });

  factory PlaceFeedbackMedia.fromJson(Map<String, dynamic> json) => PlaceFeedbackMedia(
    id: json['Id'] as int,
    feedbackId: json['FeedbackId'] as int,
    type: json['Type'] as String,
    url: json['Url'] as String,
    createDate: DateTime.parse(json['CreateDate'] as String),
  );

  Map<String, dynamic> toJson() => {
    'Id': id,
    'FeedbackId': feedbackId,
    'Type': type,
    'Url': url,
    'CreateDate': createDate.toIso8601String(),
  };
  static Future<List<PlaceFeedbackMedia>> loadMediaByFeedbackId(int feedbackId) async {
// Filter media for the specific feedbackId
    return feedbackMediaList.where((media) => media.feedbackId == feedbackId).toList();
  }
}


// Function to generate random PlaceFeedbackMedia data
List<PlaceFeedbackMedia> generatePlaceFeedbackMedias(int count, List<PlaceFeedback> feedbacks) {
  final random = Random();
  List<String> mediaTypes = ['video', 'photo']; // Define the media types list
  List<PlaceFeedbackMedia> mediaList = [];

  for (int i = 0; i < count; i++) {
    int id = i + 1; // Sequential id for PlaceFeedbackMedia
    // Randomly select a feedbackId from the provided PlaceFeedback list
    int feedbackId = feedbacks[random.nextInt(feedbacks.length)].placeFeedbackId;
    // Randomly select a media type ('video' or 'photo')
    String type = mediaTypes[random.nextInt(mediaTypes.length)];

    // Generate a random media URL based on the type
    String url = (type == 'video')
        ? 'assets/videos/video_${random.nextInt(3) + 1}.mp4'
        : 'https://picsum.photos/seed/${random.nextInt(1000)}/600/400'; // Example URL for photo

    // Randomly generate a creation date within the past 30 days
    DateTime createDate = DateTime.now().subtract(Duration(days: random.nextInt(30)));

    PlaceFeedbackMedia media = PlaceFeedbackMedia(
      id: id,
      feedbackId: feedbackId,
      type: type,
      url: url,
      createDate: createDate,
    );

    mediaList.add(media);

  }

  return mediaList;

}

  List<PlaceFeedbackMedia> feedbackMediaList = generatePlaceFeedbackMedias(200, dummyFeedbacks);

