import 'package:flutter/material.dart';
import '../../base/custombutton.dart';
import '../../card/activity_card.dart';
import '../../card/activity_card_info.dart';
import '../../models/event.dart';
import '../../models/places/place.dart';
import '../../models/places/placeactivity.dart';
import '../../models/places/placeactivitymedia.dart';
import '../../models/places/placeactivitytranslation.dart';
import '../../models/places/placetranslation.dart';
import '../../models/tag.dart';
import '../../weather/widgets/weatherwidget.dart';
import '../allproduct.dart';
import '../detailpage/placedescription.dart';
import 'form/activityformdialog.dart';
import 'form/reportform.dart';
import 'form/schedule.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../card/event_card.dart';

class DetailTab extends StatefulWidget {
  final int placeId;
  final List<Tag> tags;
  final VoidCallback onAddPressed;
  final VoidCallback onBookmarkPressed;
  final VoidCallback onReportPressed;

  const DetailTab({
    super.key,
    required this.placeId,
    required this.tags,
    required this.onAddPressed,
    required this.onBookmarkPressed,
    required this.onReportPressed,
  });

  @override
  State<DetailTab> createState() => _DetailTabState();
}

class _DetailTabState extends State<DetailTab> {
  bool isBookmarked = false; // Track bookmark status
  Place? place; // The place object
  PlaceTranslation? placeTranslation; // The place translation object
  bool isLoading = true; // Track loading state

  // List to hold ActivityCardInfo data
  List<ActivityCardInfo> activityCards = [];
  List<Event> placeEvents = [];

  @override
  void initState() {
    super.initState();
    _fetchPlaceDetails();
    _filterEvents();
  }

  // Function to fetch the corresponding place and place translation based on placeId
  void _fetchPlaceDetails() {
    // Find the place from the dummy data using placeId
    place = dummyPlaces.firstWhere(
      (p) => p.placeId == widget.placeId,
      orElse: () => dummyPlaces.first, // Return a default Place if not found
    );

    // Find the place translation from the dummy translations using placeId
    placeTranslation = translations.firstWhere(
      (t) => t.placeId == widget.placeId,
      orElse: () =>
          translations.first, // Return a default PlaceTranslation if not found
    );
    // Now fetch activities
    _fetchActivities();

    setState(() {
      isLoading = false; // Loading complete
    });
  }

  void _fetchActivities() {
    activityCards = getActivityCards(widget.placeId, randomActivities,
        placeActivityTranslations, mediaActivityList);

    setState(() {
      // Trigger a rebuild after fetching the activity data
    });
  }

  // Function to launch the URL in a browser
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
      return const Center(child: CircularProgressIndicator());
    }

    if (place == null || placeTranslation == null) {
      return const Center(child: Text("Place details not available"));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _buildTagChips(widget.tags),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black, // Border color
                      width: 2, // Border width
                    ),
                    borderRadius: BorderRadius.circular(
                        8), // Optional: Make the corners rounded
                  ),
                  child: IconButton(
                    color: const Color(0xFF9DC183),
                    onPressed: () {
                      _showScheduleFormDialog(context);
                    },
                    icon: const Icon(Icons.add_circle, size: 50),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black, // Border color
                      width: 2, // Border width
                    ),
                    borderRadius: BorderRadius.circular(
                        8), // Optional: Make the corners rounded
                  ),
                  child: IconButton(
                    color: isBookmarked ? Colors.yellow : Colors.white,
                    onPressed: () {
                      setState(() {
                        isBookmarked = !isBookmarked;
                      });
                      String message = isBookmarked
                          ? '${placeTranslation!.placeName} has been added to Bookmark Page'
                          : '${placeTranslation!.placeName} has been removed from Bookmark Page';

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.bookmark, size: 40),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black, // Border color
                      width: 2, // Border width
                    ),
                    borderRadius: BorderRadius.circular(
                        8), // Optional: Make the corners rounded
                  ),
                  child: IconButton(
                    color: Colors.red,
                    onPressed: () {
                      _showReportFormDialog(context);
                    },
                    icon: const Icon(Icons.flag, size: 30),
                  ),
                ),
              ],
            ),
          ),
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
                  latitude: place!.latitude, // Pass the place's latitude
                  longitude: place!.longitude,
                ),
                const SizedBox(height: 10),
                PlaceDescription(
                  placeId: place!.placeId,
                ),
              ],
            ),
          ),
          _buildActivitySection(),
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _buildEventSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TimeOpen and TimeClose section
  Widget _buildTimeStatus() {
    final timeNow = TimeOfDay.now();
    String statusText;
    Color iconColor = Colors.grey; // Default icon color

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
          iconColor = Colors.orange; // 1 hour before closing
        } else {
          iconColor = Colors.green; // Open
        }
      } else {
        statusText = "Closed • Opens at ${_formatTimeOfDay(openTime)}";
        if (nowInMinutes >= oneHourBeforeOpen && nowInMinutes < openInMinutes) {
          iconColor = Colors.lightBlue; // 1 hour before opening
        } else {
          iconColor = Colors.red; // Closed
        }
      }
    } else {
      statusText = "Operating hours not available";
      iconColor = Colors.grey; // If time data is not available
    }

    return Row(
      children: [
        Icon(Icons.access_time, color: iconColor),
        const SizedBox(width: 8),
        Text(statusText),
      ],
    );
  }

  // Helper function to format TimeOfDay in AM/PM format
  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final hour = timeOfDay.hourOfPeriod == 0
        ? 12
        : timeOfDay.hourOfPeriod; // Convert 0 to 12 for AM
    final period = timeOfDay.period == DayPeriod.am ? "AM" : "PM";
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    return "$hour:$minute $period";
  }

  // Address section
  Widget _buildAddressRow() {
    return Row(
      children: [
        const Icon(Icons.location_on, color: Colors.black),
        const SizedBox(width: 8),
        Expanded(child: Text(placeTranslation!.address)),
      ],
    );
  }

  // Map Image section (dummy image for now, replace later with API)
  Widget _buildMapImage() {
    final double latitude = place!.latitude;
    final double longitude = place!.longitude;

    return SizedBox(
      width: double.infinity,
      height: 150,
      child: Image.network(
        'https://maps.googleapis.com/maps/api/staticmap?center=$latitude,$longitude&zoom=15&size=400x300&key=YOUR_API_KEY', // Replace with your real API
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Text('Map not available'));
        },
      ),
    );
  }

  // Contact section
  Widget _buildContactRow() {
    return Row(
      children: [
        const Icon(Icons.phone, color: Colors.black54),
        const SizedBox(width: 8),
        Text(placeTranslation!.contact ?? 'Contact not available'),
      ],
    );
  }

  // Place URL section
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

  // Function to show the schedule form dialog
  void _showScheduleFormDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF0E68C),
              borderRadius: BorderRadius.circular(30.0),
              border: Border.all(
                color: Colors.black,
                width: 2.0,
              ),
            ),
            padding: const EdgeInsets.all(20.0),
            child: const ScheduleForm(),
          ),
        );
      },
    );
  }

  // Function to show the report form dialog
  void _showReportFormDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext buildContext, Animation animation,
          Animation secondaryAnimation) {
        return Center(
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.0),
                border: Border.all(
                  color: Colors.black,
                  width: 2.0,
                ),
              ),
              child: const ReportForm(),
            ),
          ),
        );
      },
    );
  }

  // Build the list of tag chips
  List<Widget> _buildTagChips(List<Tag> tags) {
    List<Widget> tagChips = [];

    for (int i = 0; i < tags.length && i < 5; i++) {
      tagChips.add(
        Chip(
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
      );
    }

    if (tags.length > 5) {
      tagChips.add(
        GestureDetector(
          onTap: () {
            print('See more tags clicked');
          },
          child: const Chip(
            label: Text('See more tag'),
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

  // Activity section with ActivityCard
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
          height: 220, // Height for activity cards
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: activityCards.length,
            itemBuilder: (context, index) {
              final activityCardInfo = activityCards[index];
              return ActivityCard(
                activityName: activityCardInfo.activityName,
                photoDisplay: activityCardInfo.photoDisplay,
                price: activityCardInfo.price,
                priceType: activityCardInfo.priceType,
                discount: activityCardInfo.discount,
                onTap: () {
                  // Trigger the dialog on tap
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ActivityFormDialog(
                        activityName: activityCardInfo.activityName,
                        photoDisplayUrl: activityCardInfo.photoDisplayUrl,
                        price: activityCardInfo.price,
                        priceType: activityCardInfo.priceType,
                        discount: activityCardInfo.discount,
                        description: activityCardInfo.description,
                        mediaActivityList: mediaActivityList,
                      );
                    },
                  );
                },
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
                  placeId: widget.placeId, // Pass the current placeId
                  activityCards:
                      activityCards, // Pass the list of activity cards
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 30),
        // Add the Divider line
        const Divider(
          color: Colors.black, // Customize the color as needed
          thickness: 1.5, // Customize the thickness as needed
          indent: 16, // Padding on the left side
          endIndent: 16, // Padding on the right side
        ),
      ],
    );
  }

  // New event section
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
              .where((event) =>
                  event.eventStatus !=
                  'unapproved') // Exclude 'unapproved' events
              .map((event) => buildEventCard(
                  event)) // Use the reusable card from event_card.dart
              .toList(),
        ),
      ],
    );
  }
}
