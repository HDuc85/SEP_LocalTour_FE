import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:localtourapp/config/appConfig.dart';
import 'package:localtourapp/config/secure_storage_helper.dart';
import 'package:localtourapp/models/places/place_detail_model.dart';
import 'package:localtourapp/models/schedule/destination_model.dart';
import 'package:localtourapp/services/location_Service.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';
import '../../../../constants/getListApi.dart';
import '../../../../models/HomePage/placeCard.dart';
import '../../../../models/event/event_model.dart';
import '../../../../models/schedule/schedule_model.dart';
import '../../../../services/event_service.dart';
import '../../../../services/place_service.dart';
import '../../../../services/schedule_service.dart';
import '../../../search_page/search_page.dart';
import '../../constants/colors.dart';
import '../../di/app_context.dart';
import 'components/bottom_info.dart';
import 'components/select_map_tiles_modal.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LocationService _locationService = LocationService();
  final PlaceService _placeService = PlaceService();
  final EventService _eventService = EventService();
  final ScheduleService _scheduleService = ScheduleService();

  List<PlaceCardModel> placeTranslations = [];
  List<EventModel> events = [];
  List<ScheduleModel> _listSchedule = [];
  VietmapController? _controller;
  final TextEditingController _searchController = TextEditingController();
  String searchText = '';
  Timer? _debounce;
  List<Marker> _markers = [];
  double panelPosition = 0.0;
  final PanelController _panelController = PanelController();
  MyLocationTrackingMode myLocationTrackingMode =
      MyLocationTrackingMode.Tracking;
  MyLocationRenderMode myLocationRenderMode = MyLocationRenderMode.COMPASS;
  String tileMap = AppContext.getVietmapMapStyleUrl() ?? "";
  late Position _currentPosition;
  EventModel? selectEvent;
  PlaceCardModel? selectPlace;
  PlaceDetailModel? detailSelect;
  String? _selectedSchedule;
  bool _isPanelDraggable = false;
  bool isLoading = true;
  bool isSelected = false;
  bool isEvent = false;
  bool isSearchMode = true;
  bool onSearch = false;
  String? language;
  final FocusNode _searchFocus = FocusNode();
  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() {
      if (_searchFocus.hasFocus != onSearch) {
        setState(() {
          onSearch = _searchFocus.hasFocus;
        });
      }
    });
    getCurrentPosition();
    getLanguage();
  }

  Future<void> getLanguage() async {
    language = await SecureStorageHelper().readValue(AppConfig.language);
  }

  Future<void> getCurrentPosition() async {
    Position? position = await _locationService.getCurrentPosition();
    double long = position != null ? position.longitude : 106.8096761;
    double lat = position != null ? position.latitude : 10.8411123;
    if (position != null) {
      setState(() {
        _currentPosition = position;
        isLoading = false;
      });
    } else {
      setState(() {
        _currentPosition = Position(
            longitude: long,
            latitude: lat,
            timestamp: DateTime.timestamp(),
            accuracy: 1,
            altitude: 1,
            altitudeAccuracy: 1,
            heading: 1,
            headingAccuracy: 1,
            speed: 1,
            speedAccuracy: 1);
        isLoading = false;
      });
    }
    String? userId = await SecureStorageHelper().readValue(AppConfig.userId);

    var listSchedule = await _scheduleService.getListSchedule(userId);
    setState(() {
      _listSchedule = listSchedule;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _panelController.close();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SlidingUpPanel(
                  isDraggable: _isPanelDraggable,
                  backdropEnabled: true,
                  backdropTapClosesPanel: true,
                  controller: _panelController,
                  maxHeight: 330,
                  minHeight: 0,
                  parallaxEnabled:false,
                  onPanelSlide: (position) {
                    setState(() {
                      panelPosition = position;
                    });
                  },
                  panelBuilder: () {
                    return BottomSheetInfo(
                      placeCardModel: selectPlace,
                      isEvent: isEvent,
                      eventModel: selectEvent,
                      language: language,
                      detailModel: detailSelect,
                      onClose: () {
                        _panelController.hide();
                      },
                      onDraggableChanged: (value) {
                        _isPanelDraggable = value;
                      },
                    );
                  },
                  body: Stack(
                    children: [
                      VietmapGL(
                        gestureRecognizers: <Factory<
                            OneSequenceGestureRecognizer>>{
                          Factory<ScaleGestureRecognizer>(
                              () => ScaleGestureRecognizer()),
                          Factory<PanGestureRecognizer>(
                              () => PanGestureRecognizer()),
                          Factory<TapGestureRecognizer>(
                              () => TapGestureRecognizer()),
                          Factory<VerticalDragGestureRecognizer>(
                              () => VerticalDragGestureRecognizer()),
                        },
                        zoomGesturesEnabled: true,
                        scrollGesturesEnabled: true,
                        rotateGesturesEnabled: true,
                        myLocationEnabled: true,
                        myLocationTrackingMode:
                            MyLocationTrackingMode.TrackingCompass,
                        myLocationRenderMode: myLocationRenderMode,
                        trackCameraPosition: true,
                        compassViewMargins:
                            Point(10, MediaQuery.sizeOf(context).height * 0.27),
                        minMaxZoomPreference: const MinMaxZoomPreference(0, 18),
                        styleString: tileMap,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(_currentPosition.latitude,
                              _currentPosition.longitude),
                          zoom: 13,
                        ),
                        onMapCreated: (controller) {
                          setState(() {
                            _controller = controller;
                          });
                        },
                        onMapClick: (point, coordinates) async {},
                      ),
                      if (_controller != null)
                        MarkerLayer(
                          ignorePointer: false,
                          mapController: _controller!,
                          markers: _markers,
                        ),
                    ],
                  ),
                ),
                _controller == null
                    ? const SizedBox.shrink()
                    : UserLocationLayer(
                        mapController: _controller!,
                        locationIcon: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: vietmapColor),
                          child: const Icon(
                            Icons.circle,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        bearingIcon: Container(
                            width: 50,
                            height: 50,
                            alignment: Alignment.topCenter,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.transparent),
                            child: Image.asset(
                              'assets/images/heading.png',
                              width: 15,
                              height: 15,
                            )),
                        ignorePointer: true,
                      ),
                Align(
                    key: const Key('searchBarKey'),
                    alignment: Alignment.topCenter,
                    child: Column(
                      children: [
                        // Search Bar
                        Padding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.07,
                              left: MediaQuery.of(context).size.width * 0.05),
                          child: Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                height: 50,
                                width: MediaQuery.of(context).size.width * 0.90,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      color: Colors.black, width: 0.5),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: isSearchMode
                                          ? const Icon(
                                              Icons.search,
                                              color: Colors.black,
                                            )
                                          : const Icon(Icons.travel_explore),
                                      onPressed: () {
                                        setState(() {
                                          isSearchMode = !isSearchMode;
                                          _markers.clear();
                                          FocusScope.of(context).unfocus();
                                          if(!isSearchMode){
                                            _ScheduleSelect();
                                          }
                                        });
                                      },
                                    ),
                                    Expanded(
                                      child: isSearchMode
                                          ? TextField(
                                              controller: _searchController,
                                              onChanged: _onSearchChanged,
                                              focusNode: _searchFocus,
                                              autofocus: false,
                                              decoration: InputDecoration(
                                                  hintText:
                                                  language != 'vi' ? "Where do you want to go?" : "Bạn muốn đi đâu?",
                                                  border: InputBorder.none,
                                                  suffixIcon: _searchController
                                                          .text.isNotEmpty
                                                      ? IconButton(
                                                          icon: const Icon(
                                                              Icons.clear),
                                                          onPressed: () {
                                                            _searchController
                                                                .clear();
                                                            setState(() {
                                                              searchText = '';
                                                              setState(() {
                                                                FocusScope.of(
                                                                        context)
                                                                    .unfocus();
                                                              });
                                                              onSearch = false;
                                                            });
                                                          },
                                                        )
                                                      : null),
                                            )
                                          : DropdownButton<String>(
                                              value: _selectedSchedule,
                                              hint:  Text(
                                                  language != 'vi' ? "Select your schedule" : "Chọn lịch trình của bạn"),
                                              isDense: true,
                                              isExpanded: false,
                                              icon: const Icon(
                                                  Icons.arrow_drop_down),
                                              underline: Container(),
                                              items: _listSchedule
                                                  .map((schedule) =>
                                                      DropdownMenuItem(
                                                        value: '${schedule.scheduleName}_${schedule .id}',
                                                        child: SizedBox(
                                                          width: 250,
                                                          child: Text(
                                                            schedule
                                                                .scheduleName,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ))
                                                  .toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  _selectedSchedule = value;
                                                });
                                                _ScheduleSelect();
                                              },
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Dropdown List
                        if (searchText.isNotEmpty && onSearch)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child:
                                LayoutBuilder(builder: (context, constraints) {
                              return Container(
                                constraints: const BoxConstraints(
                                  maxHeight: 350,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 5,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: placeTranslations.length +
                                      events.length +
                                      1,
                                  itemBuilder: (context, index) {
                                    bool isPlace = true;
                                    if (index >= placeTranslations.length) {
                                      isPlace = false;
                                    }
                                    bool lastItem = index ==
                                        placeTranslations.length +
                                            events.length;
                                    final placeItem = !lastItem
                                        ? (isPlace
                                            ? placeTranslations[index]
                                            : null)
                                        : null;
                                    final eventItem = !lastItem
                                        ? (!isPlace
                                            ? events[index -
                                                placeTranslations.length]
                                            : null)
                                        : null;
                                    return ListTile(
                                      leading: lastItem
                                          ? const Icon(Icons.search)
                                          : (isPlace
                                              ? const Icon(Icons.location_on)
                                              : const Icon(Icons
                                                  .event_available_rounded)),
                                      title: lastItem
                                          ? Text(
                                              "Search for $searchText") // Display the "Search for..." action
                                          : (isPlace
                                              ? Text(placeItem!.placeName)
                                              : Text(eventItem!
                                                  .eventName)), // Display place name for PlaceTranslation
                                      subtitle: lastItem
                                          ? null
                                          : (isPlace
                                              ? Text(placeItem!.address)
                                              : Text(eventItem!
                                                  .placeName)), // Display address if item is PlaceTranslation
                                      onTap: () {
                                        if (lastItem) {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => SearchPage(
                                                  sortBy: SortBy.distance,
                                                  initialTags: const [], //
                                                  textSearch: searchText,
                                                ),
                                              ));
                                        } else {
                                          if (isPlace) {
                                            _markers.clear();
                                            setState(() {
                                              _markers.add(StaticMarker(
                                                  latLng: LatLng(
                                                      placeItem!.latitude,
                                                      placeItem
                                                          .longitude), // Tọa độ marker
                                                  child: Row(
                                                    children: [
                                                      const Icon(
                                                          Icons.location_on,
                                                          color: Colors.red,
                                                          size: 40),
                                                      SizedBox(
                                                        height: 100,
                                                        width: 100,
                                                        child: Text(
                                                          placeItem.placeName,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 2,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .red),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  bearing: 0));
                                              selectPlace = placeItem;
                                              isEvent = false;
                                            });
                                            _controller?.animateCamera(
                                              CameraUpdate.newLatLngZoom(
                                                LatLng(placeItem!.latitude,
                                                    placeItem.longitude),
                                                16,
                                              ),
                                            );
                                            FocusScope.of(context).unfocus();
                                            onSearch = false;
                                            _showPanel();
                                          } else {
                                            setState(() {
                                              _markers.clear();
                                              _markers.add(StaticMarker(
                                                bearing: 0,
                                                latLng: LatLng(
                                                    eventItem!.latitude,
                                                    eventItem.longitude),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                        Icons.location_on,
                                                        color: Colors.red,
                                                        size: 40),
                                                    SizedBox(
                                                      height: 100,
                                                      width: 100,
                                                      child: Text(
                                                        eventItem.eventName,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 2,
                                                        style: const TextStyle(
                                                            color: Colors.red),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ));
                                              selectEvent = eventItem;
                                              isEvent = true;
                                            });

                                            _controller?.animateCamera(
                                              CameraUpdate.newCameraPosition(
                                                CameraPosition(
                                                  target: LatLng(
                                                      eventItem!.latitude,
                                                      eventItem.longitude),
                                                  zoom: 15,
                                                  tilt: 45,
                                                ),
                                              ),
                                            );
                                            FocusScope.of(context).unfocus();
                                            onSearch = false;
                                            _showPanel();
                                          }
                                        }
                                      },
                                    );
                                  },
                                ),
                              );
                            }),
                          ),
                      ],
                    )),
                Positioned(
                    right: 10,
                    top: MediaQuery.sizeOf(context).height * 0.3,
                    child: InkWell(
                      child: Container(
                          width: 45,
                          height: 45,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 7,
                              offset: const Offset(
                                  0, 3), // changes position of shadow
                            ),
                          ], shape: BoxShape.circle, color: Colors.white),
                          child: Icon(
                            Icons.layers_rounded,
                            size: 25,
                            color: Colors.grey[800],
                          )),
                      onTap: () {
                        _showSelectMapTilesModal();
                      },
                    )),
                if (panelPosition == 0.0)
                  Positioned(
                    bottom: 20,
                    right: 10,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FloatingActionButton(
                          heroTag: "myLocation",
                          backgroundColor: Colors.white,
                          onPressed: () async {
                            await getCurrentPosition();
                            _controller?.animateCamera(
                              CameraUpdate.newLatLngZoom(
                                LatLng(_currentPosition.latitude,
                                    _currentPosition.longitude),
                                15,
                              ),
                            );
                          },
                          child: Icon(
                            myLocationTrackingMode ==
                                    MyLocationTrackingMode.TrackingCompass
                                ? Icons.compass_calibration_sharp
                                : Icons.gps_fixed,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 10),

                      ],
                    ),
                  ),
                if(!isSearchMode)
                  Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 110),
                        child: _scheduleRoute(),
                      ))
              ],
            ),
    );
  }

  void _onSearchChanged(String value) {
    onSearch = true;
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(seconds: 2), () async {
      setState(() {
        searchText = value;
      });
      final fetchedSearchList = await _placeService.getListPlace(
          _currentPosition.latitude,
          _currentPosition.longitude,
          SortBy.distance,
          SortOrder.asc,
          [],
          searchText);
      setState(() {
        placeTranslations = fetchedSearchList;
      });
      final fetchedEventList = await _eventService.GetEventInPlace(
          null,
          _currentPosition.latitude,
          _currentPosition.longitude,
          SortOrder.asc,
          SortBy.distance,
          searchText);
      setState(() {
        events = fetchedEventList;
      });
    });
  }

  Widget _scheduleRoute() {
    if (_selectedSchedule == null) {
      return SizedBox();
    }

    String idPart = _selectedSchedule!.split('_')[1];
    int scheduleId = int.parse(idPart);

    var selectSchedule = _listSchedule.firstWhere(
      (element) => element.id == scheduleId,
    );
    int index = -1;
    return Container(
      padding: EdgeInsets.only(top: 0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          gradient: LinearGradient(
            colors: [
              Colors.yellowAccent.withOpacity(0.5),
              Colors.blueAccent.withOpacity(0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )),
      width: 300,
      height: 80,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: selectSchedule.destinations.map((entry) {
            index++;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        _controller?.animateCamera(CameraUpdate.newLatLngZoom(
                          LatLng(entry!.latitude, entry.longitude),
                          16,
                        ));
                        _selectDestination(entry);
                      },
                      icon: Icon(entry.isArrived
                          ? Icons.circle_rounded
                          : Icons.circle_outlined),
                    ),
                    Container(
                      width: 45,
                      child: Text(
                        entry.placeName,
                        maxLines: 2,
                        style: TextStyle(fontSize: 9),
                      ),
                    )
                  ],
                ),
                if (index < selectSchedule.destinations.length - 1)
                  Container(
                      padding: EdgeInsets.only(top: 10),
                      child: const Icon(Icons.arrow_forward, size: 25)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _showPanel() async {
    PlaceDetailModel detailModel = await _placeService.GetPlaceDetail(
        isEvent ? selectEvent!.placeId : selectPlace!.placeId);
    setState(() {
      detailSelect = detailModel;
    });

    Future.delayed(const Duration(milliseconds: 150))
        .then((value) => _panelController.animatePanelToPosition(1.0));
  }

  _showSelectMapTilesModal() {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => const SelectMapTilesModal());
  }

  void _ScheduleSelect() {
    if (_selectedSchedule!.isEmpty) {
      return;
    }

    _markers.clear();
    List<Marker> list = [];
    String idPart = _selectedSchedule!.split('_')[1];
    int scheduleId = int.parse(idPart);

    var selectSchedule = _listSchedule.firstWhere(
      (element) => element.id == scheduleId,
    );

    double minLat = selectSchedule.destinations.first.latitude;
    double maxLat = selectSchedule.destinations.first.latitude;
    double minLng = selectSchedule.destinations.first.longitude;
    double maxLng = selectSchedule.destinations.first.longitude;

    for (var position in selectSchedule!.destinations) {
      if (position.latitude < minLat) minLat = position.latitude;
      if (position.latitude > maxLat) maxLat = position.latitude;
      if (position.longitude < minLng) minLng = position.longitude;
      if (position.longitude > maxLng) maxLng = position.longitude;
    }

    for (var item in selectSchedule.destinations) {
      list.add(Marker(
        latLng: LatLng(item.latitude, item.longitude),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                _controller?.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    LatLng(item!.latitude, item.longitude),
                    16,
                  ),
                );
                _selectDestination(item);
              },
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.blue,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.placePhotoDisplay!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 100,
              width: 100,
              child: Text(
                item.placeName,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: const TextStyle(color: Colors.red),
              ),
            )
          ],
        ),
      ));
    }
    setState(() {
      _markers = list;
    });

    var bound = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
    _controller?.animateCamera(CameraUpdate.newLatLngBounds(bound));
  }

  void _selectDestination(DestinationModel item) {
    double distance = calculateDistance(item.latitude, item.longitude,
        _currentPosition.latitude, _currentPosition.longitude);
    var temp = new PlaceCardModel(
        placeId: item.placeId,
        placeName: item.placeName,
        latitude: item.latitude,
        longitude: item.longitude,
        address: '',
        countFeedback: 0,
        distance: distance,
        photoDisplayUrl: item.placePhotoDisplay!,
        rateStar: 0,
        wardName: 'x');
    setState(() {
      isEvent = false;
      selectPlace = temp;
    });
    _showPanel();
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371;
    double phi1 = lat1 * pi / 180;
    double phi2 = lat2 * pi / 180;
    double deltaPhi = (lat2 - lat1) * pi / 180;
    double deltaLambda = (lon2 - lon1) * pi / 180;
    double a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
        cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distance = R * c;
    return distance;
  }
}
