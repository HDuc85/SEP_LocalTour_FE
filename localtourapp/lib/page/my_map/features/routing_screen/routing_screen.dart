// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:localtourapp/config/appConfig.dart';
import 'package:localtourapp/page/my_map/extension/latlng_extension.dart';
import 'package:localtourapp/services/location_Service.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';
import 'package:talker/talker.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';
import 'package:vietmap_flutter_navigation/embedded/controller.dart';
import 'package:vietmap_flutter_navigation/models/direction_route.dart';
import 'package:vietmap_flutter_navigation/models/options.dart';
import 'package:vietmap_flutter_navigation/models/route_progress_event.dart';
import 'package:vietmap_flutter_navigation/navigation_plugin.dart';
import 'package:vietmap_flutter_navigation/views/navigation_view.dart';
import '../../../../config/secure_storage_helper.dart';
import '../../../../services/traveled_place_service.dart';
import '../../constants/colors.dart';
import '../../domain/entities/vietmap_model.dart';
import '../map_screen/bloc/map_bloc.dart';
import '../map_screen/bloc/map_state.dart';
import 'bloc/bloc.dart';
import 'components/routing_bottom_panel.dart';
import 'components/routing_header.dart';
import 'components/vietmap_banner_instruction_view.dart';
import 'components/vietmap_bottom_view.dart';
import 'models/routing_params_model.dart';

class RoutingScreen extends StatefulWidget {

  final VietmapModel vietmapModel;
  final int placeId;
  const RoutingScreen({
    Key? key,
    required this.placeId,
    required this.vietmapModel
  }) : super(key: key);

  @override
  State<RoutingScreen> createState() => _RoutingScreenState();
}

class _RoutingScreenState extends State<RoutingScreen> {
  String _languageCode = 'vi';
  final TraveledPlaceService _placeService = TraveledPlaceService();
  final LocationService _locationService = LocationService();
  final talker = Talker();
  bool isFromOrigin = true;
  final PanelController _panelController = PanelController();
  double panelPosition = 0.0;
  LatLng? _destinationLocation;
  MapNavigationViewController? _navigationController;
  late MapOptions _navigationOption;
  final _vietmapPlugin = VietMapNavigationPlugin();


  String guideDirection = "";
  Widget recenterButton = const SizedBox.shrink();
  RouteProgressEvent? routeProgressEvent;
  FocusNode focusNode = FocusNode();
  bool _isRunning = false;

  Future<void> initialize() async {

    _navigationOption = _vietmapPlugin.getDefaultOptions();
    _navigationOption.simulateRoute = false;
    _navigationOption.isCustomizeUI = true;
    _navigationOption.apiKey = AppConfig.vietMapApiKey;
    _navigationOption.mapStyle = 'https://maps.vietmap.vn/api/maps/light/styles.json?apikey=${AppConfig.vietMapApiKey}';
    _navigationOption.padding = const EdgeInsets.all(100);
    _navigationOption.language = 'vi';
    _vietmapPlugin.setDefaultOptions(_navigationOption);
  }

  RoutingBloc get routingBloc => BlocProvider.of<RoutingBloc>(context);
  MapOptions? options;
  @override
  void initState() {
    super.initState();
    initialize();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      Future.delayed(const Duration(milliseconds: 200))
          .then((value) => _panelController.hide());
      var args = widget.vietmapModel;
      routingBloc.add(RoutingEventUpdateRouteParams(
          destinationDescription:  _languageCode == 'vi' ?(args.address ?? 'Vị trí đã chọn'):(args.address ?? 'Selected location'),
          destinationPoint: LatLng(args.lat ?? 0, args.lng ?? 0)));
      Position? position = await _locationService.getCurrentPosition();
      double long = position != null ? position.longitude : 106.8096761;
      double lat = position != null ? position.latitude : 10.8411123;
      if (!mounted) return;
      routingBloc.add(RoutingEventUpdateRouteParams(
          originDescription: _languageCode == 'vi' ? "Vị trí của bạn":'Your location',
          originPoint: LatLng(lat, long)));
    });
  }

  Future<void> fetchLanguageCode() async {
    var languageCode = await SecureStorageHelper().readValue(AppConfig.language);
    setState(() {
      _languageCode = languageCode!;
    });
  }

  void _buildRouteToDestination() async {
    try {
      // Get the current location
      var currentPosition = await Geolocator.getCurrentPosition();

      if (_navigationController == null ||
          widget.vietmapModel.lat == null ||
          widget.vietmapModel.lng == null) {
        return;
      }

      // Convert the current position to LatLng
      var currentLocation = LatLng(currentPosition.latitude, currentPosition.longitude);

      _destinationLocation = LatLng(widget.vietmapModel.lat!, widget.vietmapModel.lng!);

      // Build the route
      await _navigationController?.buildRoute(
        waypoints: [
          currentLocation,
          _destinationLocation!,
        ],
        profile: DrivingProfile.motorcycle,
      );

      // Start navigation
     // await _navigationController?.startNavigation();
    } catch (e) {
      if (kDebugMode) {
        print('Error building route: $e');
      }
      // Handle any errors (e.g., show a message to the user)
    }
  }


  @override
  Widget build(BuildContext context) {
    return BlocListener<RoutingBloc, RoutingState>(
      bloc: routingBloc,
      listener: (context, state) {
        if (state is RoutingStateNativeRouteBuilt && !_isRunning) {
          _panelController.show();
        }
      },
      child: BlocListener<MapBloc, MapState>(
        listener: (context, state) {
          try{
            if (state is MapStateGetPlaceDetailSuccess) {
              if (isFromOrigin) {
                routingBloc.add(RoutingEventUpdateRouteParams(
                    originDescription: _languageCode == 'vi' ?
                    (state.response.getFullAddress() ?? 'Vị trí của bạn'):(state.response.getFullAddress() ?? 'Your location'),
                    originPoint: LatLng(
                        state.response.lat ?? 0, state.response.lng ?? 0)));
              } else {
                routingBloc.add(RoutingEventUpdateRouteParams(
                    destinationDescription: _languageCode == 'vi' ?
                    (state.response.getFullAddress() ?? 'Vị trí đã chọn'):(state.response.getFullAddress() ?? 'Selected location'),
                    destinationPoint: LatLng(
                        state.response.lat ?? 0, state.response.lng ?? 0)));
              }
            }
          }catch(e){
            if (kDebugMode) {
              print(e);
            }
          }
        },
        child: WillPopScope(
          onWillPop: () {
            if (_isRunning) {
              showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                        title: Text(_languageCode == 'vi' ? 'Thông báo': 'Notification'),
                        content:
                        Text(_languageCode == 'vi' ? 'Bạn có muốn dừng hướng dẫn đi đường?': 'Do you want to stop the directions?'),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(_languageCode == 'vi' ?'Không':'No')),
                          TextButton(
                              onPressed: () {
                                _navigationController?.finishNavigation();
                                _onStopNavigation();
                                Navigator.pop(context);
                              },
                              child: Text(_languageCode == 'vi' ?'Có':'Yes'))
                        ],
                      ));
              return Future.value(false);
            }
            routingBloc.add(RoutingEventClearDirection());
            return Future.value(true);
          },
          child: Scaffold(
            body: Column(children: [
              _isRunning
                  ? const SizedBox.shrink(
                      key: Key("hide"),
                    )
                  : RoutingHeader(
                      key: const Key("routingHeader"),
                      onOriginTapCallback: () {
                        setState(() {
                          isFromOrigin = true;
                        });
                      },
                      onDestinationTapCallback: () => setState(() {
                        isFromOrigin = false;
                      }),
                    ),
              Expanded(
                child: Stack(
                  children: [
                    NavigationView(
                      mapOptions: _navigationOption,
                      onNewRouteSelected: (DirectionRoute p0) {
                        routingBloc.add(
                            RoutingEventNativeRouteBuilt(directionRoute: p0));
                      },
                      onMapRendered: () async {
                        EasyLoading.show();
                        if (ModalRoute.of(context)!.settings.arguments !=
                            null) {
                          var args = ModalRoute.of(context)!.settings.arguments
                              as RoutingParamsModel;
                          var listWaypoint = <LatLng>[];
                          var res = await Geolocator.getCurrentPosition();
                          listWaypoint.add(LatLng(res.toLatLng().latitude,
                              res.toLatLng().longitude));

                          listWaypoint
                              .add(LatLng(args.lat ?? 0, args.lng ?? 0));
                          if (args.isStartNavigation) {
                            _navigationController
                                ?.buildAndStartNavigation(
                                    waypoints: listWaypoint,
                                    profile: DrivingProfile.drivingTraffic)
                                .then((value) {
                              setState(() {
                                EasyLoading.dismiss();
                                _isRunning = true;
                              });
                            });
                          } else {
                            _navigationController?.buildRoute(
                                waypoints: listWaypoint,
                                profile: DrivingProfile.drivingTraffic);
                          }
                        }
                        EasyLoading.dismiss();
                        _buildRouteToDestination();
                      },
                      onMapCreated: (p0) async {
                        _navigationController = p0;
                        routingBloc.add(RoutingEventUpdateRouteParams(
                            navigationController: _navigationController));
                      },
                      onRouteBuilt: (DirectionRoute p0) {
                        routingBloc.add(
                            RoutingEventNativeRouteBuilt(directionRoute: p0));
                        setState(() {
                          EasyLoading.dismiss();
                        });
                      },
                      onMapMove: () => _showRecenterButton(),
                      onRouteProgressChange:
                          (RouteProgressEvent routeProgressEvent) {
                        if (!mounted) return;
                        setState(() {
                          this.routeProgressEvent = routeProgressEvent;
                        });
                      },
                        onArrival: () async {
                          // Capture the current navigator and context-dependent functionality
                          final navigator = Navigator.of(context);

                          try {
                            await _placeService.addTraveledPlace(widget.placeId);

                            // Check if the widget is still mounted
                            if (!mounted) return;

                            // Show the dialog
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text(_languageCode == 'vi' ? 'Thông báo' : 'Notification'),
                                content: Text(
                                  _languageCode == 'vi' ? 'Bạn đã đến nơi' : 'You have arrived',
                                  style: const TextStyle(),
                                  textAlign: TextAlign.center,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      navigator.pop(); // Close the dialog
                                      navigator.pop(); // Go back to the previous screen
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          } catch (e) {
                            debugPrint("Error in onArrival: $e");
                          }
                        }
                    ),
                    _isRunning
                        ? Positioned(
                            top: MediaQuery.of(context).viewPadding.top,
                            child: VietmapBannerInstructionView(
                              routeProgressEvent: routeProgressEvent,
                            ),
                          )
                        : const SizedBox.shrink(),
                    _isRunning
                        ? Positioned(
                            bottom: 0,
                            child: VietmapBottomActionView(
                                controller: _navigationController,
                                onStopNavigationCallback: () {
                                  setState(() {
                                    _isRunning = false;
                                  });
                                },
                                routeProgressEvent: routeProgressEvent,
                                onOverviewCallback: _showRecenterButton,
                                recenterButton: recenterButton),
                          )
                        : SlidingUpPanel(
                            parallaxEnabled: true,
                            parallaxOffset: .6,
                            controller: _panelController,
                            minHeight: MediaQuery.of(context).size.height * 0.2,
                            maxHeight: MediaQuery.of(context).size.height * 0.7,
                            onPanelSlide: (position) {
                              setState(() {
                                panelPosition = position;
                              });
                            },
                            panelBuilder: () => RoutingBottomPanel(
                                  onViewListStep: () {
                                    if (_panelController.panelPosition <= 0.5) {
                                      _panelController
                                          .animatePanelToPosition(1.0);
                                    } else {
                                      _panelController
                                          .animatePanelToPosition(0.0);
                                    }
                                  },
                                  panelPosition: panelPosition,
                                  onStartNavigation: () {
                                    _navigationController?.startNavigation();
                                    setState(() {
                                      _isRunning = true;
                                    });
                                  },
                                  routingBloc: routingBloc,
                                ))
                    ,
                    Positioned(
                      right: 10,
                      bottom: 150,
                      child: Column(
                        children: [
                          FloatingActionButton(
                            heroTag: 'route',
                            mini: true,
                            child: const Icon(Icons.alt_route),
                            onPressed: () {
                              _navigationController?.overview();
                            },),
                          FloatingActionButton(
                            heroTag: 'center',
                            mini: true,
                            child: const Icon(Icons.gps_fixed),
                            onPressed: () {
                              _navigationController?.recenter();
                            },),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }

  _showRecenterButton() {
    recenterButton = TextButton(
        style: ButtonStyle(overlayColor:
            MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
          return Colors.transparent;
        })),
        onPressed: () {
          _navigationController?.recenter();
          recenterButton = const SizedBox.shrink();
        },
        child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.white,
                border: Border.all(color: Colors.black45, width: 1)),
            child: Row(
              children: [
                const Icon(
                  Icons.keyboard_double_arrow_up_sharp,
                  size: 35,
                  color: vietmapColor,
                ),
                Text(_languageCode == 'vi' ?
                  'Về giữa':'Go to middle',
                  style: const TextStyle(fontSize: 18, color: vietmapColor),
                )
              ],
            )));
    setState(() {});
  }

  _onStopNavigation() {
    Navigator.pop(context);
    setState(() {
      routeProgressEvent = null;
      _isRunning = false;
    });
  }

  @override
  void dispose() {
    _navigationController?.onDispose();
    super.dispose();
  }
}
