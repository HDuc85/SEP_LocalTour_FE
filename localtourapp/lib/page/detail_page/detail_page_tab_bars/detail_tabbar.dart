// lib/page/detail_page/detail_page_tab_bars/detail_tabbar.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:localtourapp/config/appConfig.dart';
import 'package:localtourapp/constants/getListApi.dart';
import 'package:localtourapp/models/Tag/tag_model.dart';
import 'package:localtourapp/models/event/event_model.dart';
import 'package:localtourapp/models/places/place_detail_model.dart';
import 'package:vietmap_flutter_navigation/models/options.dart';
import '../../../base/custom_button.dart';
import '../../../base/weather_icon_button.dart';
import '../../my_map/map_page.dart';
import '../../search_page/search_page.dart';
import '../detail_card/activity_card.dart';
import '../detail_card/activity_card_info.dart';
import '../detail_card/event_card.dart';
import '../../../weather/widgets/weather_widget.dart';
import '../all_product.dart';
import '../place_description.dart';
import 'form/activityformdialog.dart';
import 'form/reportform.dart';
import 'form/schedule_form.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailTabbar extends StatefulWidget {
  final String userId;
  final PlaceDetailModel placeDetail;
  final List<TagModel> tags;
  final String languageCode;
  final VoidCallback onAddPressed;
  final VoidCallback onReportPressed;
  final List<EventModel> listEvents;
  const DetailTabbar({
    Key? key,
    required this.userId,
    required this.placeDetail,
    required this.tags,
    required this.onAddPressed,
    required this.onReportPressed,
    required this.languageCode,
    required this.listEvents
  }) : super(key: key);

  @override
  State<DetailTabbar> createState() => _DetailTabbarState();
}

class _DetailTabbarState extends State<DetailTabbar> {
  late MapOptions _navigationOption;
  bool isLoading = true;
  List<ActivityCardInfo> activityCards = [];


  @override
  void initState() {
    super.initState();
    _navigationOption = MapOptions(
      simulateRoute: false,
      apiKey: dotenv.get('VIETMAP_API_KEY'),
      mapStyle: dotenv.get('VIETMAP_MAP_STYLE_URL'),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _navigateToWeatherPage() {
    Navigator.pushNamed(context, '/weather');
  }

  


  Future<void> _launchURL(String? url) async {
    if (url != null && url.isNotEmpty) {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        print('Could not open the URL: $url');
      }
    } else {
      print('Invalid URL');
    }
  }



  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        ListView(
          padding: EdgeInsets.zero, // Important to prevent additional padding
          children: [
            // Tags Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _buildTagChips(widget.tags),
              ),
            ),
            // Action Buttons Section
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      color: const Color(0xFF9DC183),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              child: ScheduleForm(
                                userId: widget.userId, // Pass the required userId
                                placeId: widget.placeDetail.id, // Pass the required placeId
                              ),
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.add_circle, size: 40),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Transform.scale(
                      scale: 3,
                      child: IconButton(
                        color: Colors.red,
                        onPressed: () {
                          ReportForm.show(
                            context,
                            'Have a problem with this place? Report it to us!',
                            null,
                            widget.placeDetail.id,
                            onSubmit: (reportMessage) {

                            },
                          );
                        },
                        icon: const Icon(Icons.flag, size: 10),
                      ),
                    ),
                  )
                ],
              ),
            ),
            // Place Details Section
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildTimeStatus(),
                  const SizedBox(height: 10),
                  _buildAddressRow(),
                  const SizedBox(height: 10),
                  _buildMapImage(),
                  const SizedBox(height: 10),
                  _buildContactRow(),
                  const SizedBox(height: 10),
                  _buildPlaceUrl(),
                  const SizedBox(height: 10),
                  WeatherWidget(
                    latitude: widget.placeDetail.latitude,
                    longitude: widget.placeDetail.longitude,
                  ),
                  const SizedBox(height: 10),
                  PlaceDescription(
                    placeDescription: widget.placeDetail.description,
                  ),
                ],
              ),
            ),
            // Activity Section
            _buildActivitySection(),
            // Event Section
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: _buildEventSection(),
            ),
            const SizedBox(height: 50),
          ],
        ),
        Positioned(
          bottom: 10,
          left: 40,
          child: WeatherIconButton(
            onPressed: _navigateToWeatherPage,
            assetPath: 'assets/icons/weather.png',
          ),
        ),
      ],
    );
  }

  Widget _buildTimeStatus() {
    final timeNow = TimeOfDay.now();
    String statusText;
    Color iconColor = Colors.grey;

    if (widget.placeDetail.timeOpen != null && widget.placeDetail.timeClose != null) {
      final openTime = widget.placeDetail.timeOpen;
      final closeTime = widget.placeDetail.timeClose;

      final nowInMinutes = timeNow.hour * 60 + timeNow.minute;
      final openInMinutes = openTime!.hour * 60 + openTime.minute;
      final closeInMinutes = closeTime!.hour * 60 + closeTime.minute;

      final oneHourBeforeOpen = openInMinutes - 60;
      final oneHourBeforeClose = closeInMinutes - 60;

      if (nowInMinutes >= openInMinutes && nowInMinutes < closeInMinutes) {
        statusText = "Open • Closes at ${_formatTimeOfDay(closeTime)}";
        if (nowInMinutes >= oneHourBeforeClose) {
          iconColor = Colors.orange;
        } else {
          iconColor = Colors.green;
        }
      } else {
        statusText = "Closed • Opens at ${_formatTimeOfDay(openTime)}";
        if (nowInMinutes >= oneHourBeforeOpen && nowInMinutes < openInMinutes) {
          iconColor = Colors.lightBlue;
        } else {
          iconColor = Colors.red;
        }
      }
    } else {
      statusText = "Operating hours not available";
      iconColor = Colors.grey;
    }

    return Row(
      children: [
        Icon(Icons.access_time, color: iconColor),
        const SizedBox(width: 8),
        Text(statusText),
      ],
    );
  }

  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final hour = timeOfDay.hourOfPeriod == 0 ? 12 : timeOfDay.hourOfPeriod;
    final period = timeOfDay.period == DayPeriod.am ? "AM" : "PM";
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    return "$hour:$minute $period";
  }

  Widget _buildAddressRow() {
    return Row(
      children: [
        const Icon(Icons.location_on, color: Colors.black),
        const SizedBox(width: 8),
        Expanded(child: Text(widget.placeDetail.address)),
      ],
    );
  }

  Widget _buildMapImage() {
    final double latitude = widget.placeDetail.latitude;
    final double longitude = widget.placeDetail.longitude;
    final String apiKey = AppConfig.vietMapApiKey;
    final String mapStyleUrl = AppConfig.vietMapStyleUrl;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GestureDetector(
        onTap: _openMaps,
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/map_placeholder.png',
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        ),
      ),
    );
  }

  void _openMaps() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPage(
          destinationLatitude: widget.placeDetail.latitude,
          destinationLongitude: widget.placeDetail.longitude,
        ),
      ),
    );
  }


  Widget _buildContactRow() {
    return Row(
      children: [
        const Icon(Icons.phone, color: Colors.black54),
        const SizedBox(width: 8),
        Text(widget.placeDetail.contact),
      ],
    );
  }

  Widget _buildPlaceUrl() {
    return Row(
      children: [
        const Icon(Icons.link, color: Colors.black38),
        const SizedBox(width: 8),
        Container(
          width: 250,
          child: GestureDetector(
            onTap: () {
              _launchURL(widget.placeDetail.contactLink);
            },
            child: Text(
              widget.placeDetail.contactLink,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildTagChips(List<TagModel> tags) {
    List<Widget> tagChips = [];

    for (int i = 0; i < tags.length && i < 5; i++) {
      tagChips.add(
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchPage(
                  sortBy: SortBy.distance,
                  initialTags: [tags[i].id], // Pass the selected tag ID
                ),
              ),
            );
          },
          child: Chip(
            label: Text(
              tags[i].tagName,
              style: const TextStyle(
                color: Colors.green,
              ),
            ),
            shape: const StadiumBorder(
              side: BorderSide(color: Colors.green),
            ),
            backgroundColor: Colors.transparent,
          ),
        ),
      );
    }

    if (tags.length > 5) {
      tagChips.add(
        GestureDetector(
          onTap: () {
            _showAllTagsDialog(context);
          },
          child: const Chip(
            label: Text('See more tags'),
            shape: StadiumBorder(
              side: BorderSide(color: Colors.green),
            ),
            backgroundColor: Colors.transparent,
          ),
        ),
      );
    }

    return tagChips;
  }

  void _showAllTagsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEDE8D0),
              borderRadius: BorderRadius.circular(30.0),
              border: Border.all(
                color: Colors.black,
                width: 2.0,
              ),
            ),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.placeDetail.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.tags.map((tag) {
                    return Chip(
                      label: Text(
                        tag.tagName,
                        style: const TextStyle(
                          color: Colors.green,
                        ),
                      ),
                      shape: const StadiumBorder(
                        side: BorderSide(color: Colors.green),
                      ),
                      backgroundColor: Colors.transparent,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            "PRODUCTS",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: widget.placeDetail.placeActivities.length,
            itemBuilder: (context, index) {
              final activityCardInfo = widget.placeDetail.placeActivities[index];
              return ActivityCard(
                activityName: activityCardInfo.activityName,
                photoDisplay: activityCardInfo.photoDisplay
                   ,
                price: activityCardInfo.price,
                priceType: activityCardInfo.priceType,
                discount: activityCardInfo.discount,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ActivityFormDialog(
                        activityName: activityCardInfo.activityName,
                        price: activityCardInfo.price,
                        priceType: activityCardInfo.priceType,
                        discount: activityCardInfo.discount,
                        description: activityCardInfo.description,
                        mediaActivityList: activityCardInfo.placeActivityMedia,
                        placeActivityId: activityCardInfo.id,
                      );
                    },
                  );
                },
                placeActivityId: activityCardInfo.id,
                mediaActivityList: activityCardInfo.placeActivityMedia,
              );
            },
          ),
        ),
        const SizedBox(height: 30),
        CustomSeeAllButton(
          text: "SEE ALL",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AllProductPage(
                  placeId: widget.placeDetail.id,
                  activityCards: widget.placeDetail.placeActivities,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 30),
        const Divider(
          color: Colors.black,
          thickness: 1.5,
          indent: 16,
          endIndent: 16,
        ),
      ],
    );
  }

  Widget _buildEventSection() {
    if (widget.listEvents.isEmpty) {
      return const Center(child: Text('No events available for this place.'));
    }
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event, color: Colors.black),
            SizedBox(width: 8),
            Text("EVENT",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          children: widget.listEvents.map((event) => EventCardWidget(event: event, languageCode: widget.languageCode,)).toList(),
        ),
      ],
    );
  }
}
