import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:localtourapp/config/appConfig.dart';
import 'package:localtourapp/config/secure_storage_helper.dart';
import 'package:localtourapp/models/HomePage/placeCard.dart';
import 'package:localtourapp/models/event/event_model.dart';
import 'package:localtourapp/models/places/place_detail_model.dart';
import 'package:localtourapp/models/schedule/destination_model.dart';
import '../../../../../full_media/full_place_media_viewer.dart';
import '../../../../../models/media_model.dart';
import '../../../../detail_page/detail_page.dart';
import '../../../../detail_page/detail_page_tab_bars/form/schedule_form.dart';
import '../../../components/map_action_button.dart';
import '../../../constants/colors.dart';
import '../../../constants/route.dart';
import '../../../domain/entities/vietmap_model.dart';
import '../../../navigation_page.dart';
import '../../routing_screen/models/routing_params_model.dart';
import '../../routing_screen/routing_screen.dart';
import '../bloc/map_bloc.dart';
import '../bloc/map_state.dart';

class BottomSheetInfo extends StatelessWidget {
  final int? scheduleChoosenId;
  final bool? isEvent;
  final EventModel? eventModel;
  final PlaceCardModel? placeCardModel;
  final String? language;
  final PlaceDetailModel? detailModel;
  final ValueChanged<bool> onDraggableChanged;
  final String userId;
  final DestinationModel? destinationModel;
  const BottomSheetInfo({
    super.key,
    this.scheduleChoosenId,
    required this.onClose,
    this.eventModel,
    this.placeCardModel,
    this.isEvent,
    this.language,
    this.detailModel,
    required this.onDraggableChanged,
    required this.userId,
    this.destinationModel,

  });
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    if ((isEvent! && eventModel == null) ||
        (!isEvent! && detailModel == null)) {
      return Container(
        height: 310,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      height: 310,
      width: double.infinity,
      margin: const EdgeInsets.only(left: 15, right: 15),
      padding: const EdgeInsets.only(bottom: 0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: ListView(
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
        children: [
          GestureDetector(
            onLongPress: () {
              onDraggableChanged(true);
            },
            onLongPressUp: () {
              onDraggableChanged(false);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Flexible(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        (isEvent!) ? eventModel!.eventName : detailModel!.name,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 230,
                          child: !isEvent!
                              ? _TimeString()
                              : Text(
                                  language == 'vi'
                                      ? 'Tại ${eventModel!.placeName} '
                                      : 'At ${eventModel!.placeName}',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.deepOrangeAccent),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 225,
                          child: Text(
                            isEvent!
                                ? detailModel!.address
                                : detailModel!.address,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                  onTap: () {
                    // Navigate to DetailPage and pass the filtered data
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailPage(
                          placeId: detailModel!.id,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 100,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
                      image: DecorationImage(
                        image: NetworkImage(isEvent!
                            ? eventModel!.eventPhoto!
                            : detailModel!.photoDisplay),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ))
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              isEvent!
                  ? _EventStatusString()
                  : buildStarRating(detailModel!.rating),
              const SizedBox(
                width: 20,
              ),
              Text(
                  isEvent!
                      ? FormatDistance(eventModel!.distance)
                      : FormatDistance(placeCardModel!.distance),
                  style: const TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              MapActionButton(
                onPressed: () async {
                  try {
                    if (detailModel == null) {
                      throw Exception("Place details are null");
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoutingScreen(
                          vietmapModel: VietmapModel(
                            address: detailModel!.name,
                            lat: detailModel!.latitude,
                            name: detailModel!.name,
                            lng: detailModel!.longitude,
                          ),
                          placeId: detailModel!.id,
                          scheduleChoosenId: scheduleChoosenId,
                          destinationModel: destinationModel,
                        ),
                      ),
                    );
                  } catch (e) {
                    // Log the error
                    print('Navigation Error: $e');
                    // Show an error message to the user
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(language != 'vi'
                              ? "Unable to navigate."
                              : "Không thể chỉ đường.")),
                    );
                  }
                },
                child: Row(
                  children: [
                    const Icon(Icons.directions, color: Colors.blue),
                    const SizedBox(width: 5),
                    Text(language! == 'vi' ? 'Chỉ đường' : 'Directions')
                  ],
                ),
              ),
              const SizedBox(width: 5),
              ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: const WidgetStatePropertyAll(Colors.white),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: const BorderSide(color: vietmapColor),
                      ),
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          child: ScheduleForm(
                            userId: userId, // Pass the required userId
                            placeId: detailModel!.id,
                            language: language!, // Pass the required placeId
                          ),
                        );
                      },
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.add, color: Colors.green),
                      const SizedBox(width: 1),
                      Text(language! == 'vi'
                          ? 'Thêm lịch trình'
                          : 'Add to Schedule')
                    ],
                  )),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Stack(
            children: [
              detailModel!.placeMedias.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FullScreenPlaceMediaViewer(
                              mediaList: detailModel!.placeMedias,
                              initialIndex: 0,
                            ),
                          ),
                        );
                      },
                      child: Image.network(
                        detailModel!.placeMedias[0].url,
                        width: double.infinity,
                        height: 250, // Adjust height as needed
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(child: Text('No media available')),
                      ),
                    )
                  : const Center(child: Text('No media available')),
              // Positioned IconButton
            ],
          ),
          const SizedBox(height: 1),
          // Thumbnails Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: detailModel!.placeMedias.length > 1
                ? detailModel!.placeMedias
                    .skip(1)
                    .take(4)
                    .toList()
                    .asMap()
                    .entries
                    .map((entry) {
                    int index = entry.key;
                    MediaModel media = entry.value;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreenPlaceMediaViewer(
                                mediaList: detailModel!.placeMedias,
                                initialIndex: index + 1,
                              ),
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            Image.network(
                              media.url,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 77.5,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: double.infinity,
                                height: 77.5,
                                color: Colors.grey,
                                child: const Icon(Icons.image,
                                    color: Colors.white),
                              ),
                            ),
                            if (index == 3 &&
                                detailModel!.placeMedias.length > 5)
                              Container(
                                color: Colors.black.withOpacity(0.5),
                                height: 77.5,
                                child: const Center(
                                  child: Text(
                                    'See more',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList()
                : [],
          )
        ],
      ),
    );
  }

  String FormatDistance(double distance) {
    String formattedDistance = '${distance.toStringAsFixed(1)}';
    if (formattedDistance.endsWith('.0')) {
      formattedDistance =
          formattedDistance.substring(0, formattedDistance.length - 2);
    }
    formattedDistance += ' km';
    return formattedDistance;
  }

  Widget buildStarRating(double score) {
    int fullStars = score.floor(); // Full stars
    bool hasHalfStar =
        (score - fullStars) >= 0.5; // Determine if there’s a half-star

    return Row(
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return const Icon(Icons.star, color: Colors.red, size: 16);
        } else if (index == fullStars && hasHalfStar) {
          return const Icon(Icons.star_half, color: Colors.red, size: 16);
        } else {
          return const Icon(Icons.star_border, color: Colors.red, size: 16);
        }
      }),
    );
  }

  Widget _TimeString() {
    DateTime now = DateTime.now();

    DateTime timeOpen = DateTime(now.year, now.month, now.day,
        detailModel!.timeOpen!.hour, detailModel!.timeOpen!.minute);
    DateTime timeClose = DateTime(now.year, now.month, now.day,
        detailModel!.timeClose!.hour, detailModel!.timeClose!.minute);

    if (now.isAfter(timeOpen) && now.isBefore(timeClose)) {
      return RichText(
        text: TextSpan(
          children: [
            const TextSpan(
              text: 'Đang mở cửa',
              style: TextStyle(color: Colors.green, fontSize: 13),
            ),
            TextSpan(
              text: ' - Đóng cửa lúc ${DateFormat('HH:mm').format(timeClose)}',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      );
    } else if (now.isAfter(timeClose)) {
      return RichText(
        text: TextSpan(
          children: [
            const TextSpan(
              text: 'Đã đóng cửa',
              style: TextStyle(color: Colors.red, fontSize: 13),
            ),
            TextSpan(
              text: ' - Mở cửa lúc ${DateFormat('HH:mm').format(timeOpen)}',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      );
    } else if (now.isBefore(timeOpen)) {
      return RichText(
        text: TextSpan(
          children: [
            const TextSpan(
              text: 'Sắp mở cửa',
              style: TextStyle(color: Colors.orange, fontSize: 13),
            ),
            TextSpan(
              text: ' - Mở cửa lúc ${DateFormat('HH:mm').format(timeOpen)}',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return const SizedBox();
  }

  Widget _EventStatusString() {
    DateTime now = DateTime.now();
    DateTime eventStart = eventModel!.startDate;
    DateTime eventEnd = eventModel!.endDate;
    if (now.isAfter(eventStart) && now.isBefore(eventEnd)) {
      int daysLeft = eventEnd.difference(now).inDays;
      return RichText(
        text: TextSpan(
          children: [
            language == 'vi'
                ? TextSpan(
                    text: 'Đang diễn ra',
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  )
                : TextSpan(
                    text: 'Ongoing',
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  ),
            language == 'vi'
                ? TextSpan(
                    text: ' - Kết thúc ${daysLeft} ngày nữa',
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  )
                : TextSpan(
                    text:
                        ' - End in ${daysLeft} ${daysLeft > 1 ? 'day' : 'days'}',
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  ),
          ],
        ),
      );
    } else if (now.isAfter(eventEnd.subtract(Duration(days: 1))) &&
        now.isBefore(eventEnd)) {
      return RichText(
        text: TextSpan(
          children: [
            language == 'vi'
                ? TextSpan(
                    text: 'Sắp kết thúc',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  )
                : TextSpan(
                    text: 'About to end',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
            TextSpan(
              text:
                  ' - End at ${DateFormat('HH:mm dd/MM/yyyy').format(eventEnd)}',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
        ),
      );
    } else if (now.isBefore(eventStart)) {
      return RichText(
        text: TextSpan(
          children: [
            language == 'vi'
                ? TextSpan(
                    text: 'Sắp diễn ra',
                    style: TextStyle(color: Colors.orange, fontSize: 12),
                  )
                : TextSpan(
                    text: 'Coming soon',
                    style: TextStyle(color: Colors.orange, fontSize: 12),
                  ),
            language == 'vi'
                ? TextSpan(
                    text:
                        ' - Diễn ra vào ${DateFormat('HH:mm dd/MM/yyyy').format(eventStart)}',
                    style: TextStyle(color: Colors.orange, fontSize: 12),
                  )
                : TextSpan(
                    text:
                        ' - Start at ${DateFormat('HH:mm dd/MM/yyyy').format(eventStart)}',
                    style: TextStyle(color: Colors.orange, fontSize: 12),
                  ),
          ],
        ),
      );
    } else if (now.isAfter(eventEnd)) {
      return RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: language == 'vi' ? 'Đã kết thúc' : 'Ended',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            TextSpan(
              text:
                  ' - ${language == 'vi' ? 'Kết thúc vào' : 'Ends on'} ${DateFormat('dd/MM/yyyy').format(eventEnd)}',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return SizedBox();
  }
}
