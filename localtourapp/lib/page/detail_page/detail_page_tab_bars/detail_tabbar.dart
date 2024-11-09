import 'package:flutter/material.dart';
import 'package:localtourapp/base/back_to_top_button.dart';
import 'package:localtourapp/base/weather_icon_button.dart';
import '../../../base/custom_button.dart';
import '../../../models/places/event.dart';
import '../../../models/places/tag.dart';
import '../detailcard/activity_card.dart';
import '../detailcard/activity_card_info.dart';
import '../detailcard/event_card.dart';
import '../../../models/places/place.dart';
import '../../../models/places/placeactivity.dart';
import '../../../models/places/placeactivitymedia.dart';
import '../../../models/places/placeactivitytranslation.dart';
import '../../../models/places/placetranslation.dart';
import '../../../weather/widgets/weatherwidget.dart';
import '../all_product.dart';
import '../place_description.dart';
import 'form/activityformdialog.dart';
import 'form/reportform.dart';
import 'form/schedule_form.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailTabbar extends StatefulWidget {
  final int placeId;
  final List<Tag> tags;
  final VoidCallback onAddPressed;
  final VoidCallback onReportPressed;

  const DetailTabbar({
    super.key,
    required this.placeId,
    required this.tags,
    required this.onAddPressed,
    required this.onReportPressed,
  });

  @override
  State<DetailTabbar> createState() => _DetailTabbarState();
}

class _DetailTabbarState extends State<DetailTabbar> {
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;
  Place? place; // The place object
  PlaceTranslation? placeTranslation; // The place translation object
  bool isLoading = true; // Track loading state

  // List to hold ActivityCardInfo data
  List<ActivityCardInfo> activityCards = [];
  List<Event> placeEvents = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _fetchPlaceDetails();
    _filterEvents();
  }
  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  // Listener to handle scroll events
  void _scrollListener() {
    if (_scrollController.offset >= 200 && !_showBackToTopButton) {
      setState(() {
        _showBackToTopButton = true;
      });
    } else if (_scrollController.offset < 200 && _showBackToTopButton) {
      setState(() {
        _showBackToTopButton = false;
      });
    }
  }

  // Function to navigate to the Weather page
  void _navigateToWeatherPage() {
    Navigator.pushNamed(context, '/weather');
  }

  // Function to scroll back to the top
  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
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
    if (place == null) {
      return const Center(child: Text('No place selected.'));
    }
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (place == null || placeTranslation == null) {
      return const Center(child: Text("Place details not available"));
    }

    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _buildTagChips(widget.tags),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                        icon: const Icon(Icons.add_circle, size: 40),
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
                      child:
                    IconButton(
                      color: Colors.red,
                      onPressed: () {
                        _showReportFormDialog(context);
                      },
                      icon: const Icon(Icons.flag, size: 20),
                    ),
                    )],
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
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    _buildEventSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          left: 20,
          child: WeatherIconButton(
            onPressed: _navigateToWeatherPage,
            assetPath: 'assets/icons/weather.png',
          ),
        ),

        // Positioned Back to Top Button (Bottom Right) with AnimatedOpacity
        Positioned(
          bottom: 12,
          left: 110,
          child: AnimatedOpacity(
            opacity: _showBackToTopButton ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: _showBackToTopButton
                ? BackToTopButton(
              onPressed: _scrollToTop,
            )
                : const SizedBox.shrink(),
          ),
        ),
      ],
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
        'https://maps.vietmap.vn/maps/api/staticmap?center=$latitude,$longitude&zoom=15&size=400x300&key=9e37b843f972388f80a9e51612cad4c1bc3877c71c107e46', // Replace with your real API
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
              child: const ReportForm(message: 'Have a problem with this place? Report it to us!',),
            ),
          ),
        );
      },
    );
  }

  // Function to build the list of tag chips
  List<Widget> _buildTagChips(List<Tag> tags) {
    List<Widget> tagChips = [];

    // Show a maximum of 5 tags initially
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

    // If there are more than 5 tags, show "See more tags" button
    if (tags.length > 5) {
      tagChips.add(
        GestureDetector(
          onTap: () {
            _showAllTagsDialog(context); // Pass context here instead of tags
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

// Function to show dialog with all tags
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
                // Display the place name
                Text(
                  placeTranslation?.placeName ?? "All Tags",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10), // Add space between place name and tags
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
          height: 200, // Height for activity cards
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: activityCards.length,
            itemBuilder: (context, index) {
              final activityCardInfo = activityCards[index];
              return ActivityCard(
                activityName: activityCardInfo.activityName,
                photoDisplay: activityCardInfo.photoDisplay ?? 'https://picsum.photos/250?image=9',
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
                        price: activityCardInfo.price,
                        priceType: activityCardInfo.priceType,
                        discount: activityCardInfo.discount,
                        description: activityCardInfo.description,
                        mediaActivityList: mediaActivityList, placeActivityId: activityCardInfo.placeActivityId,
                      );
                    },
                  );
                }, placeActivityId: activityCardInfo.placeActivityId,
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
              .where((event) => event.eventStatus != 'unapproved')
              .map((event) => FutureBuilder<Widget>(
            future: buildEventCard(event), // Assuming buildEventCard returns a Future
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(); // Show a loading indicator
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}'); // Show error if any
              } else if (snapshot.hasData) {
                return snapshot.data!; // Display the loaded event card
              } else {
                return const Text('No data available');
              }
            },
          ))
              .toList(),
        ),

      ],
    );
  }
}
