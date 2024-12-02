import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:localtourapp/config/appConfig.dart';
import 'package:localtourapp/config/secure_storage_helper.dart';
import 'package:localtourapp/models/places/place_detail_model.dart';
import 'package:localtourapp/services/location_Service.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';
import 'package:talker/talker.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';
import '../../../../constants/getListApi.dart';
import '../../../../models/HomePage/placeCard.dart';
import '../../../../models/event/event_model.dart';
import '../../../../services/event_service.dart';
import '../../../../services/place_service.dart';
import '../../../search_page/search_page.dart';
import '../../constants/colors.dart';

import '../../di/app_context.dart';
import 'bloc/map_bloc.dart';
import 'bloc/map_event.dart';
import 'components/bottom_info.dart';
import 'components/select_map_tiles_modal.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LocationService _locationService = LocationService();
  final PlaceService _placeService = PlaceService();
  final EventService _eventService = EventService();
  List<PlaceCardModel> placeTranslations = [];
  List<EventModel> events =[];
  VietmapController? _controller;
  final TextEditingController _searchController = TextEditingController();
  String searchText = '';
  Timer? _debounce;
  List<StaticMarker> _markers = [];
  List<Marker> _nearbyMarker = [];
  double panelPosition = 0.0;
  bool isShowMarker = true;
  final PanelController _panelController = PanelController();
  MyLocationTrackingMode myLocationTrackingMode =
      MyLocationTrackingMode.Tracking;
  MyLocationRenderMode myLocationRenderMode = MyLocationRenderMode.COMPASS;
  final talker = Talker();
  String tileMap = AppContext.getVietmapMapStyleUrl() ?? "";
  late Position _currentPosition;
  EventModel? selectEvent;
  PlaceCardModel? selectPlace;
  PlaceDetailModel? detailSelect;
  bool isLoading = true;
  bool isSelected = false;
  bool isEvent = false;
  bool OnSearch = false;
  String? language;
  final FocusNode _searchFocus = FocusNode();
  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() {
      if(_searchFocus.hasFocus){
        setState(() {
          OnSearch = true;
        });
      }
    },);
    talker.enable();
    getCurrentPosition();
    getLanguage();
  }

  Future<void> getLanguage() async {
    language = await SecureStorageHelper().readValue(AppConfig.language);
  }

  Future<void> getCurrentPosition() async{
    Position? position = await _locationService.getCurrentPosition();
    double long = position != null ? position.longitude : 106.8096761;
    double lat =  position != null ? position.latitude : 10.8411123;
    if(position != null){
      setState(() {
        _currentPosition = position;
        isLoading = false;
      });
    }else{
      setState(() {
        _currentPosition = new Position(longitude: long, latitude: lat, timestamp: DateTime.timestamp(), accuracy: 1, altitude: 1, altitudeAccuracy: 1, heading: 1, headingAccuracy: 1, speed: 1, speedAccuracy: 1);
        isLoading = false;
      });
    }
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
    return
      isLoading ?
      const Center(child: CircularProgressIndicator())
      :Stack(
            children: [
              SlidingUpPanel(
                  isDraggable: true,
                  controller: _panelController,
                  maxHeight: 235,
                  minHeight: 0,
                  parallaxEnabled: true,
                  parallaxOffset: .1,
                  backdropEnabled: false,
                  onPanelSlide: (position) {
                    setState(() {
                      panelPosition = position;
                    });
                  },
               panelBuilder: () {
                 return GestureDetector(
                   onVerticalDragStart: (details) {
                   },
                   child: BottomSheetInfo(
                     placeCardModel: selectPlace,
                     isEvent: isEvent,
                     eventModel: selectEvent,
                     language: language,
                     detailModel: detailSelect,
                     onClose: () {
                     _panelController.hide();
                   },),
                 );
               },
              body: Stack(
                children: [
                  VietmapGL(
                    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                      Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
                      Factory<PanGestureRecognizer>(() => PanGestureRecognizer()),
                      Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
                      Factory<VerticalDragGestureRecognizer>(() => VerticalDragGestureRecognizer()),
                    },
                    zoomGesturesEnabled: true,  // Ensure this is true
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
                        target: LatLng(_currentPosition.latitude, _currentPosition.longitude), zoom: 13),
                    onMapCreated: (controller) {
                      setState(() {
                        _controller = controller;
                      });
                    },
                    onMapClick: (point, coordinates) async {
                    },
                    onMapLongClick: (point, coordinates) {
                      setState(() {
                        _nearbyMarker = [];
                      });
                      context
                          .read<MapBloc>()
                          .add(MapEventOnUserLongTapOnMap(coordinates));
                    },
                  ),
                  if (_controller != null)
                  StaticMarkerLayer(
                    ignorePointer: true,
                    mapController: _controller!,
                    markers: _markers,
                  )
                ],
              ),),
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
              _controller == null
                  ? const SizedBox.shrink()
                  : MarkerLayer(
                      mapController: _controller!,
                      markers: _nearbyMarker,
                    ),
              Align(
                  key: const Key('searchBarKey'),
                  alignment: Alignment.topCenter,
                  child:  Column(
              children: [
              // Search Bar
              Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.07, left: MediaQuery.of(context).size.width*0.05),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 50,
                  width: MediaQuery.of(context).size.width * 0.90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 0.5),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.search,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            FocusScope.of(context).unfocus();
                          });
                        },
                      ),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            focusNode: _searchFocus,
                            autofocus: false,
                            decoration:  InputDecoration(
                              hintText: "Where do you want to go?",
                              border: InputBorder.none,
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                 setState(() {
                                   searchText= '';
                                   setState(() {
                                     FocusScope.of(context).unfocus();
                                   });
                                   OnSearch = false;
                                 });
                                },
                              )
                                  : null
                            ),

                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
            ),
        // Dropdown List
        if (searchText.isNotEmpty && OnSearch)

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              constraints: const BoxConstraints(
                maxHeight: 400,
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
                itemCount: placeTranslations.length + events.length + 1,
                itemBuilder: (context, index) {
                  bool isPlace = true;
                  if(index >= placeTranslations.length){
                    isPlace = false;
                  }
                  bool lastItem = index == placeTranslations.length + events.length;
                  final placeItem =  !lastItem ?  (isPlace ? placeTranslations[index] : null) : null;
                  final eventItem = !lastItem ?  (!isPlace ? events[index - placeTranslations.length] : null) : null;
                  return ListTile(
                    leading: lastItem
                        ? const Icon(Icons.search)
                        : (isPlace ? Icon(Icons.location_on) : Icon(Icons.event_available_rounded)),
                    title: lastItem
                        ? Text("Search for $searchText") // Display the "Search for..." action
                        : (isPlace ? Text(placeItem!.placeName) : Text(eventItem!.eventName) ), // Display place name for PlaceTranslation
                    subtitle: lastItem
                        ? null
                        : (isPlace ? Text(placeItem!.address) : Text(eventItem!.placeName)), // Display address if item is PlaceTranslation
                    onTap: () {
                      if (lastItem) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SearchPage(
                        sortBy: SortBy.distance,
                        initialTags: [], //
                        textSearch: searchText,
                      ),
                    ));
              } else {
                if(isPlace){
                  _markers.clear();
                  setState(() {
                    _markers.add(StaticMarker(
                      latLng: LatLng(placeItem!.latitude, placeItem.longitude), // Tọa độ marker
                      child: Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.red, size: 40),
                          Container(
                            height: 100,
                            width: 100,
                            child: Text(
                              placeItem.placeName,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(color: Colors.red),),
                          )
                        ],), bearing: 0
                    ));
                    selectPlace = placeItem;
                    isEvent = false;
                  });
                  _controller?.animateCamera(
                    CameraUpdate.newLatLngZoom(

                      LatLng(placeItem!.latitude, placeItem.longitude),
                      16,
                    ),
                  );
                  FocusScope.of(context).unfocus();
                  OnSearch = false;
                    _showPanel();
                }else {
                  setState(() {
                    _markers.clear();
                    _markers.add(StaticMarker(
                      bearing: 0,
                      latLng: LatLng(eventItem!.latitude, eventItem.longitude),
                      child: Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.red, size: 40),
                          Container(
                            height: 100,
                            width: 100,
                            child: Text(
                              eventItem.eventName,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(color: Colors.red),),
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
                        target: LatLng(eventItem!.latitude, eventItem!.longitude),
                        zoom: 15,
                        tilt: 45,
                      ),
                    ),
                  );
                  FocusScope.of(context).unfocus();
                  OnSearch = false;
                  _showPanel();
                }

              }
            },
          );
        },

      ),
            ),
        ),
        ],
        )),
              Positioned(
                  right: 10,
                  top: MediaQuery.sizeOf(context).height * 0.2,
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
                  right: 20,
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
                                LatLng(_currentPosition.latitude, _currentPosition.longitude),
                                15,
                              ),
                            );
                        },
                        child: Icon(
                          myLocationTrackingMode == MyLocationTrackingMode.TrackingCompass
                              ? Icons.compass_calibration_sharp
                              : Icons.gps_fixed,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
            ],
          );
  }

  void _onSearchChanged(String value) {
    OnSearch = true;
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(seconds: 2), () async {
      setState(() {
        searchText = value;
      });
      final fetchedSearchList = await _placeService.getListPlace(_currentPosition!.latitude, _currentPosition!.longitude, SortBy.distance,SortOrder.asc,[],searchText);
      setState(() {
        placeTranslations = fetchedSearchList;
      });
      final fetchedEventList = await _eventService.GetEventInPlace(null, _currentPosition!.latitude, _currentPosition!.longitude, SortOrder.asc,SortBy.distance,searchText);
      setState(() {
        events = fetchedEventList;
      });
    });
  }

  Future<void> _showPanel() async {
    PlaceDetailModel detailModel = await _placeService.GetPlaceDetail(isEvent?selectEvent!.placeId:selectPlace!.placeId);
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


}
