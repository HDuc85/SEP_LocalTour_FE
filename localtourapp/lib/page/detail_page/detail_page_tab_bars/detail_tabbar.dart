import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:localtourapp/config/appConfig.dart';
import 'package:localtourapp/config/secure_storage_helper.dart';
import 'package:localtourapp/constants/getListApi.dart';
import 'package:localtourapp/models/Tag/tag_model.dart';
import 'package:localtourapp/models/event/event_model.dart';
import 'package:localtourapp/models/places/place_detail_model.dart';
import 'package:localtourapp/page/my_map/domain/entities/vietmap_model.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';
import '../../../base/custom_button.dart';
import '../../../base/weather_icon_button.dart';
import '../../my_map/features/routing_screen/routing_screen.dart';
import '../../search_page/search_page.dart';
import '../../weather/widgets/weather_widget.dart';
import '../detail_card/activity_card.dart';
import '../detail_card/event_card.dart';
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
  const DetailTabbar(
      {Key? key,
      required this.userId,
      required this.placeDetail,
      required this.tags,
      required this.onAddPressed,
      required this.onReportPressed,
      required this.languageCode,
      required this.listEvents})
      : super(key: key);

  @override
  State<DetailTabbar> createState() => _DetailTabbarState();
}

class _DetailTabbarState extends State<DetailTabbar> {
  VietmapController? _mapController;
  bool isLoading = true;
  String _language = 'vi';

  @override
  void initState() {
    super.initState();
    getLanguage();
  }

  Future<void> getLanguage() async {
    var language = await SecureStorageHelper().readValue(AppConfig.language);
    setState(() {
      _language = language!;
    });
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
        if (kDebugMode) {
          print('Could not open the URL: $url');
        }
      }
    } else {
      if (kDebugMode) {
        print('Invalid URL');
      }
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
                                userId:
                                    widget.userId, // Pass the required userId
                                placeId: widget.placeDetail.id,
                                language:
                                    _language, // Pass the required placeId
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
                            _language != 'vi'
                                ? 'Have a problem with this place? Report it to us!'
                                : 'Bạn có vấn đề với địa danh này? Hãy báo cáo với chúng tôi!',
                            null,
                            widget.placeDetail.id,
                            _language,
                            onSubmit: (String message) async {},
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
                  _buildBRCUrl(),
                  const SizedBox(height: 10),
                  WeatherWidget(
                    latitude: widget.placeDetail.latitude,
                    longitude: widget.placeDetail.longitude,
                  ),
                  const SizedBox(height: 10),
                  PlaceDescription(
                    placeDescription: widget.placeDetail.description,
                    language: _language,
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

    if (widget.placeDetail.timeOpen != null &&
        widget.placeDetail.timeClose != null) {
      final openTime = widget.placeDetail.timeOpen;
      final closeTime = widget.placeDetail.timeClose;

      final nowInMinutes = timeNow.hour * 60 + timeNow.minute;
      final openInMinutes = openTime!.hour * 60 + openTime.minute;
      final closeInMinutes = closeTime!.hour * 60 + closeTime.minute;

      final oneHourBeforeOpen = openInMinutes - 60;
      final oneHourBeforeClose = closeInMinutes - 60;

      if (nowInMinutes >= openInMinutes && nowInMinutes < closeInMinutes) {
        statusText =
            "${_language != 'vi' ? 'Open • Closes at' : 'Đang mở cửa • Đóng cửa lúc'} ${_formatTimeOfDay(closeTime)}";
        if (nowInMinutes >= oneHourBeforeClose) {
          iconColor = Colors.orange;
        } else {
          iconColor = Colors.green;
        }
      } else {
        statusText =
            "${_language != 'vi' ? 'Closed • Opens at' : 'Đã đóng cửa • Mở cửa lúc'} ${_formatTimeOfDay(openTime)}";
        if (nowInMinutes >= oneHourBeforeOpen && nowInMinutes < openInMinutes) {
          iconColor = Colors.lightBlue;
        } else {
          iconColor = Colors.red;
        }
      }
    } else {
      statusText = _language != 'vi'
          ? "Operating hours not available"
          : 'Thời gian không xác định';
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
    final String mapStyleUrl = AppConfig.vietMapStyleUrl;

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 200,
      child: Stack(
        children: [
          VietmapGL(
            styleString: mapStyleUrl,
            initialCameraPosition:
                CameraPosition(target: LatLng(latitude, longitude), zoom: 14),
            trackCameraPosition: true,
            onMapCreated: (VietmapController controller) {
              setState(() {
                _mapController = controller;
              });
            },
            onMapClick: (point, coordinates) {
              _openMaps();
            },
          ),
          if (_mapController != null)
            MarkerLayer(
              mapController: _mapController!,
              markers: [
                Marker(
                  latLng: LatLng(latitude, longitude), // Tọa độ marker
                  child: const Icon(Icons.location_on,
                      color: Colors.red, size: 40),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _openMaps() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoutingScreen(
          vietmapModel: VietmapModel(
            address: widget.placeDetail.address,
            lat: widget.placeDetail.latitude,
            name: widget.placeDetail.name,
            lng: widget.placeDetail.longitude,
          ),
          placeId: widget.placeDetail.id,
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
        SizedBox(
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

  Widget _buildBRCUrl() {
    final bool hasBRC = widget.placeDetail.brc.isNotEmpty;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Icon(
          Icons.business
        ),
        const SizedBox(width: 5,),
        Icon(
          hasBRC ? Icons.check_circle : Icons.cancel,
          color: hasBRC ? Colors.green : Colors.red,
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
              _language != 'vi' ? tags[i].tagName : tags[i].tagVi,
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
          child: Chip(
            label: Text(_language != 'vi' ? 'More tags' : 'Xem thêm'),
            shape: const StadiumBorder(
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
        Center(
          child: Text(
            _language != 'vi' ? "PRODUCTS" : 'Sản phẩm',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
              final activityCardInfo =
                  widget.placeDetail.placeActivities[index];
              return ActivityCard(
                activityName: activityCardInfo.activityName,
                photoDisplay: activityCardInfo.photoDisplay,
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
          text: _language != 'vi' ? "SEE ALL" : "Xem tất cả",
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
      return Center(
          child: Text(_language != 'vi'
              ? 'No events available for this place.'
              : 'Không có sự kiện trong địa điểm này.'));
    }
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event, color: Colors.black),
            const SizedBox(width: 8),
            Text(_language != 'vi' ? "EVENT" : 'Sự kiện',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          children: widget.listEvents
              .map((event) => EventCardWidget(
                    event: event,
                    languageCode: widget.languageCode,
                  ))
              .toList(),
        ),
      ],
    );
  }
}
