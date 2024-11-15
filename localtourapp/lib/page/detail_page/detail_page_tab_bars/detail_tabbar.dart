// lib/page/detail_page/detail_page_tab_bars/detail_tabbar.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import '../../../base/custom_button.dart';
import '../../../base/filter_option.dart';
import '../../../base/weather_icon_button.dart';
import '../../../models/places/event.dart';
import '../../../models/places/placereport.dart';
import '../../../models/places/tag.dart';
import '../../../provider/place_provider.dart';
import '../../search_page/search_page.dart';
import '../detail_card/activity_card.dart';
import '../detail_card/activity_card_info.dart';
import '../detail_card/event_card.dart';
import '../../../models/places/place.dart';
import '../../../models/places/placeactivity.dart';
import '../../../models/places/placeactivitymedia.dart';
import '../../../models/places/placeactivitytranslation.dart';
import '../../../models/places/placetranslation.dart';
import '../../../weather/widgets/weather_widget.dart';
import '../all_product.dart';
import '../place_description.dart';
import 'form/activityformdialog.dart';
import 'form/reportform.dart';
import 'form/schedule_form.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailTabbar extends StatefulWidget {
  final languageCode;
  final String userId;
  final int placeId;
  final List<Tag> tags;
  final VoidCallback onAddPressed;
  final VoidCallback onReportPressed;

  const DetailTabbar({
    Key? key,
    required this.languageCode,
    required this.userId,
    required this.placeId,
    required this.tags,
    required this.onAddPressed,
    required this.onReportPressed,
  }) : super(key: key);

  @override
  State<DetailTabbar> createState() => _DetailTabbarState();
}

class _DetailTabbarState extends State<DetailTabbar> {
  Place? place;
  PlaceTranslation? placeTranslation;
  bool isLoading = true;

  List<ActivityCardInfo> activityCards = [];
  List<Event> placeEvents = [];

  @override
  void initState() {
    super.initState();
    _fetchPlaceDetails();
    _filterEvents();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _navigateToWeatherPage() {
    Navigator.pushNamed(context, '/weather');
  }

  void _fetchPlaceDetails() {
    place = dummyPlaces.firstWhere(
          (p) => p.placeId == widget.placeId,
      orElse: () => dummyPlaces.first,
    );

    placeTranslation = dummyTranslations.firstWhere(
          (t) => t.placeId == widget.placeId,
      orElse: () => dummyTranslations.first,
    );

    _fetchActivities();

    setState(() {
      isLoading = false;
    });
  }

  void _fetchActivities() {
    activityCards = getActivityCards(
        widget.placeId, randomActivities, placeActivityTranslations, mediaActivityList);

    setState(() {});
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

  void _filterEvents() {
    setState(() {
      placeEvents = dummyEvents
          .where((event) => event.placeId == widget.placeId)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      // Optionally, show a loading indicator while fetching data
      return const Center(child: CircularProgressIndicator());
    }

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
                                placeId: widget.placeId, // Pass the required placeId
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
                          final placeProvider = Provider.of<PlaceProvider>(context, listen: false);
                          ReportForm.show(
                            context,
                            'Have a problem with this place? Report it to us!',
                            onSubmit: (reportMessage) {
                              final placeReport = PlaceReport(
                                id: placeProvider.placeReports.length + 1, // Assuming sequential IDs
                                placeId: widget.placeId, // Use the relevant placeId here
                                reportDate: DateTime.now(),
                                status: 'unprocessed',
                              );
                              placeProvider.addPlaceReport(placeReport);
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
                    latitude: place!.latitude,
                    longitude: place!.longitude,
                  ),
                  const SizedBox(height: 10),
                  PlaceDescription(
                    placeId: place!.placeId,
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

    if (place?.timeOpen != null && place?.timeClose != null) {
      final openTime = place!.timeOpen!;
      final closeTime = place!.timeClose!;

      final nowInMinutes = timeNow.hour * 60 + timeNow.minute;
      final openInMinutes = openTime.hour * 60 + openTime.minute;
      final closeInMinutes = closeTime.hour * 60 + closeTime.minute;

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
        Expanded(child: Text(placeTranslation!.address)),
      ],
    );
  }

  Widget _buildMapImage() {
    final double latitude = place!.latitude;
    final double longitude = place!.longitude;
    final String apiKey = dotenv.get('VIETMAP_API_KEY');
    final String mapStyleUrl = dotenv.get('VIETMAP_MAP_STYLE_URL');

    return SizedBox(
      width: double.infinity,
      height: 150,
      child: Image.network(
        'https://maps.vietmap.vn/maps/api/staticmap?center=$latitude,$longitude&zoom=15&size=400x300&key=$apiKey&style=$mapStyleUrl',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Text('Map not available'));
        },
      ),
    );
  }

  Widget _buildContactRow() {
    return Row(
      children: [
        const Icon(Icons.phone, color: Colors.black54),
        const SizedBox(width: 8),
        Text(placeTranslation!.contact ?? 'Contact not available'),
      ],
    );
  }

  Widget _buildPlaceUrl() {
    return Row(
      children: [
        const Icon(Icons.link, color: Colors.black38),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            _launchURL(place!.placeUrl);
          },
          child: Text(
            place!.placeUrl ?? 'Website not available',
            style: const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildTagChips(List<Tag> tags) {
    List<Widget> tagChips = [];

    for (int i = 0; i < tags.length && i < 5; i++) {
      tagChips.add(
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchPage(
                  initialFilter: FilterOption.none,
                  initialTags: [tags[i].tagId], // Pass the selected tag ID
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
                  placeTranslation?.placeName ?? "All Tags",
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
            itemCount: activityCards.length,
            itemBuilder: (context, index) {
              final activityCardInfo = activityCards[index];
              return ActivityCard(
                activityName: activityCardInfo.activityName,
                photoDisplay: activityCardInfo.photoDisplay ??
                    'https://picsum.photos/250?image=9',
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
                        mediaActivityList: mediaActivityList,
                        placeActivityId: activityCardInfo.placeActivityId,
                      );
                    },
                  );
                },
                placeActivityId: activityCardInfo.placeActivityId,
                mediaActivityList: mediaActivityList,
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
                  placeId: widget.placeId,
                  activityCards: activityCards,
                  mediaActivityList: mediaActivityList,
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
    if (placeEvents.isEmpty) {
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
          children: placeEvents
              .where((event) => event.eventStatus.toLowerCase() != 'unapproved')
              .map((event) => EventCardWidget(event: event))
              .toList(),
        ),
      ],
    );
  }
}
