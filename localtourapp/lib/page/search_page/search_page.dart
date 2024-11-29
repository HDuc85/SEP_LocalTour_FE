// lib/page/search_page.dart

import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:localtourapp/models/HomePage/placeCard.dart';
import 'package:localtourapp/models/event/event_model.dart';
import 'package:localtourapp/page/detail_page/detail_page.dart';
import 'package:localtourapp/services/event_service.dart';
import 'package:localtourapp/services/location_Service.dart';
import 'package:localtourapp/services/place_service.dart';
import '../../base/const.dart';
import '../../constants/getListApi.dart';
import '../../models/Tag/tag_model.dart';
import '../../services/tag_service.dart';
import 'second_place_card.dart';
import 'tags_modal.dart'; // Ensure correct path

class SearchPage extends StatefulWidget {
  final SortBy sortBy;
  final List<int> initialTags;
  final String? textSearch;
  final Function(PlaceCardModel)? onPlaceSelected;
  final bool? isEvent;
  const SearchPage({
    Key? key,
    this.sortBy = SortBy.distance,
    this.initialTags = const [],
    this.onPlaceSelected,
    this.textSearch,
    this.isEvent
  }) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  final PlaceService _placeService = PlaceService();
  final TagService _tagService = TagService();
  final EventService _eventService = EventService();
  final LocationService _locationService = LocationService();
  late List<PlaceCardModel> listPlaceInit = [];
  late List<PlaceCardModel> listPlaces =[];
  late List<EventModel> listEventInit = [];
  late List<EventModel> listEvent = [];
  bool isPlace = true;
  String searchText = "";
  List<TagModel> listTagPlaces = [];

  List<int> selectedTags = [];
  Position? _currentPosition;
  SortBy _selectedFilter = SortBy.distance;
  String  _isComing = '';

  int size = 10;
  TextEditingController _controllerSearchInput = TextEditingController();
  FocusNode _focusSearchInput = FocusNode();

  ScrollController _listPlaceScrollController = ScrollController();
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    if(widget.isEvent != null){
      isPlace  = !widget.isEvent!;
    }
    _selectedFilter = widget.sortBy;
    selectedTags = List.from(widget.initialTags);
    _fetchCurrentLocation();

    _listPlaceScrollController.addListener(_onScroll);
  }

  Future<void> _fetchCurrentLocation() async {

    Position? position = await _locationService.getCurrentPosition();
    double long = position != null ? position.longitude : 106.8096761;
    double lat =  position != null ? position.latitude : 10.8411123;
    if(position != null){
      _currentPosition = position;
    }else{
      _currentPosition = new Position(longitude: long, latitude: lat, timestamp: DateTime.timestamp(), accuracy: 1, altitude: 1, altitudeAccuracy: 1, heading: 1, headingAccuracy: 1, speed: 1, speedAccuracy: 1);
    }

    if(widget.isEvent != null){
      isPlace = false;
    }
    final fetchedTags = await _tagService.getTopTagPlace();

   if(isPlace){
     List<PlaceCardModel> fetchedListPlaces =[];

     if(widget.textSearch != "" && widget.textSearch != null ){
       searchText = widget.textSearch!;
       fetchedListPlaces = await _placeService.getListPlace(lat, long, SortBy.distance,SortOrder.asc,selectedTags,searchText);
     }
     else{
       fetchedListPlaces = await _placeService.getListPlace(lat, long, SortBy.distance,SortOrder.asc,selectedTags);
     }
     setState(() {
       listTagPlaces = fetchedTags;
       listPlaces = fetchedListPlaces;
       _controllerSearchInput.text = searchText;
       _isLoading = false;
     });
   }else{
     List<EventModel> fetchedListEvents = [];
     if(widget.textSearch != "" && widget.textSearch != null ){
       searchText = widget.textSearch!;
       fetchedListEvents = await _eventService.GetEventInPlace(null,lat, long,SortOrder.asc,SortBy.distance,searchText);
     }
     else{
       fetchedListEvents = await _eventService.GetEventInPlace(null,lat, long,SortOrder.asc,SortBy.distance);
     }
     setState(() {
       listEvent = fetchedListEvents;
       listEventInit = fetchedListEvents;
       listTagPlaces = fetchedTags;
       _controllerSearchInput.text = searchText;
       _isLoading = false;
     });
   }

  }

  void _generateCardInfoList() async {

    if(isPlace){
      final fetchedListPlaces = await _placeService.getListPlace(_currentPosition!.latitude, _currentPosition!.longitude, SortBy.distance,SortOrder.asc,selectedTags);
      setState(() {
        listPlaces = fetchedListPlaces;
      });

      // Apply initial filter if any
      if (_selectedFilter == SortBy.distance) {
        listPlaces.sort((a, b) => a.distance.compareTo(b.distance));
      } else if (_selectedFilter == SortBy.rating) {
        listPlaces.sort((a, b) => b.rateStar.compareTo(a.rateStar));
      }
    }else{
      final fetchedListEvent = await _eventService.GetEventInPlace(null, _currentPosition!.latitude, _currentPosition!.longitude, SortOrder.asc,SortBy.distance,);
      setState(() {
        listEvent = fetchedListEvent;
        listEventInit = fetchedListEvent;
      });

    }

  }

  void _generateCardWithSearch() async {
    if(isPlace){
      final fetchedListPlaces = await _placeService.getListPlace(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          SortBy.distance,
          SortOrder.asc,
          selectedTags,
          searchText);
      setState(() {
        listPlaces = fetchedListPlaces;
      });
      // Apply initial filter if any
      if (_selectedFilter == SortBy.distance) {
        listPlaces.sort((a, b) => a.distance.compareTo(b.distance));
      } else if (_selectedFilter == SortBy.rating) {
        listPlaces.sort((a, b) => b.rateStar.compareTo(a.rateStar));
      }
    }else{
      final fetchedListEvent = await _eventService.GetEventInPlace(null, _currentPosition!.latitude, _currentPosition!.longitude, SortOrder.asc,SortBy.distance,searchText);
      setState(() {
        listEvent = fetchedListEvent;
        listEventInit = fetchedListEvent;
      });
    }
  }
  void _onScroll() {
    if (_listPlaceScrollController.position.pixels ==
        _listPlaceScrollController.position.maxScrollExtent &&
        !_isLoading) {

      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    setState(() {
      _isLoading = true;
    });
    size += 10;
    await Future.delayed(const Duration(seconds: 5));
    final fetchedListPlaces = await _placeService.getListPlace(_currentPosition!.latitude, _currentPosition!.longitude, SortBy.distance,SortOrder.asc,selectedTags,searchText);
    setState(() {
      listPlaces = fetchedListPlaces;
      _isLoading = false;
    });
    // Apply initial filter if any
    if (_selectedFilter == SortBy.distance) {
      listPlaces.sort((a, b) => a.distance.compareTo(b.distance));
    } else if (_selectedFilter == SortBy.rating) {
      listPlaces.sort((a, b) => b.rateStar.compareTo(a.rateStar));
    }

  }

  @override
  void dispose() {
    _focusSearchInput.dispose();
    _listPlaceScrollController.dispose();
    super.dispose();
  }

  // New method to build filter buttons
  Widget _buildFilterButton(
      String text, Color color, SortBy sortBy ,[String? isComing]) {
    bool isSelected = false;
    if(sortBy == SortBy.created_by){
      if(isComing == _isComing){
        isSelected = true;
      }
      else{
        isSelected = false;
      }
    }else{
      isSelected = _selectedFilter == sortBy;
    }
    return ElevatedButton(
      onPressed: () {
        setState(() {
         if(isPlace){
           if (isSelected) {
             _selectedFilter = SortBy.none;
             if(sortBy == SortBy.distance){
               listPlaces.sort((a, b) => b.distance.compareTo(a.distance));
             }else{
               listPlaces.sort((a, b) => a.rateStar.compareTo(b.rateStar));
             }
           } else {
             _selectedFilter = sortBy;
             if(sortBy == SortBy.distance){
               listPlaces.sort((a, b) => a.distance.compareTo(b.distance));
             }else{
               listPlaces.sort((a, b) => b.rateStar.compareTo(a.rateStar));
             }
           }
         }else{
           if(isSelected){
             _selectedFilter = SortBy.none;
             if(sortBy == SortBy.distance){
               listEvent.sort((a,b) => b.distance.compareTo(a.distance));
             }else{
               _isComing = '';
               DateTime now = DateTime.now();
               if(isComing == 'isComing'){
                var list = listEventInit;

                list.sort((a, b) => b.startDate.compareTo(a.startDate),);
                listEvent = list;
               }else if(isComing == 'onGoing') {
                 var list = listEventInit;
                 listEvent = list;

               }
             }
           }else {
             _selectedFilter = sortBy;
             if(sortBy == SortBy.distance){
               listEvent.sort((a,b) => a.distance.compareTo(b.distance));
             }else{
               _isComing = isComing!;
               DateTime now = DateTime.now();
               if(isComing == 'isComing'){
                 var list = listEventInit.where((element) {
                   Duration difference = now.difference(element.startDate);
                   if(difference.inDays < 0){
                     return true;
                   }
                   return false;
                 },).toList();

                 list.sort((a, b) => a.startDate.compareTo(b.startDate),);
                 listEvent = list;
               }else if(isComing == 'onGoing') {
                 var list = listEventInit.where((element) {
                   Duration differenceStart = now.difference(element.startDate);
                   Duration differenceEnd = now.difference(element.endDate);

                   if(differenceStart.inHours > 0 && differenceEnd.inHours < 0 ){
                     return true;
                   }
                   return false;
                 },).toList();

                 list.sort((a, b) => a.startDate.compareTo(b.startDate),);
                 listEvent = list;

               }
             }
           }
         }
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? Constants.selectedState
            : Constants.defaultState, // Highlight if selected
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 28),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected
              ? Colors.white
              : Colors.black, // Text color based on selection
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {


    // Optionally, show a loading indicator while fetching the location
    if (_currentPosition == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF2EAD3),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          title: Row(// Error: Expanded cannot be a direct child of AppBar
              children: [
            Expanded(
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                  });
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Colors.black),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ]),
        ),
        body: const Center(child: CircularProgressIndicator(
        )),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2EAD3),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                  Navigator.pop(context);
              },
            ),
            Expanded(
              child: TextField(
                controller: _controllerSearchInput,
                focusNode: _focusSearchInput,
                onSubmitted: (value) {
                  _generateCardWithSearch();
                },
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                    // Optionally, you can debounce the search input
                  });
                },
                decoration: InputDecoration(
                  prefixIcon: IconButton(icon: const Icon(Icons.search, color: Colors.black)
                    ,onPressed: () {
                    if(searchText == ""){
                    FocusScope.of(context).requestFocus(_focusSearchInput);
                  }else{
                    _focusSearchInput.unfocus();
                    _generateCardWithSearch();
                  }
                  },),
                  suffixIcon: searchText != ""
                      ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.black),
                    onPressed: () {
                      setState(() {
                        _controllerSearchInput.clear();
                        searchText = "";
                        _generateCardInfoList();
                      });
                    },
                  )
                      :
                  (isPlace ?
                  IconButton(
                    icon: Icon(Icons.place_rounded, color: Colors.blue, ),
                    onPressed: () {
                    setState(() {
                      isPlace = false;
                      _generateCardInfoList();
                    });
                  },)
                  :IconButton(
                      icon: Icon(Icons.event_available_rounded, color: Colors.greenAccent),
                  onPressed: () {
                    setState(() {
                      isPlace = true;
                      _generateCardInfoList();
                    });
                  },) ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10)
                  ,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row of buttons (Nearest, Featured, Tags)
          Container(
            margin: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
            child: Row(
              children: [
                _buildFilterButton(
                    "Nearest", const Color(0xFF99C896), SortBy.distance),
                const SizedBox(width: 5),
                isPlace ?
                _buildFilterButton(
                    "Featured", const Color(0xFFAAFF00), SortBy.rating)
                :_buildFilterButton(
                    "Coming soon", const Color(0xFFFFB200), SortBy.created_by, 'isComing'),
                const SizedBox(width: 5),
                if(!isPlace) _buildFilterButton(
                    "On Going", const Color(0xFF99C896), SortBy.created_by, 'onGoing'),
                if(isPlace) const SizedBox(width: 5) ,
                if(isPlace)
                Flexible(
                  child: OutlinedButton(
                    onPressed: () {
                      showTagsModal(
                        context: context,
                        selectedTags: selectedTags,
                        listTags: listTagPlaces,
                        onSelectedTagsChanged: (updatedTags) {
                          setState(() {
                            selectedTags = updatedTags;
                            _generateCardInfoList(); // Update list based on new tags
                          });
                        },
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD6B588)),
                      backgroundColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Tags",
                          style: TextStyle(color: Colors.black),
                        ),
                        Icon(Icons.arrow_forward, color: Colors.black),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Display selected tags as horizontally scrollable list
          if (selectedTags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: selectedTags.map((tagId) {
                    final tag = listTagPlaces.firstWhere(
                      (t) => t.id == tagId,
                      orElse: () => TagModel(
                        id: tagId,
                        tagPhotoUrl: 'assets/icons/default.png',
                        tagName: 'Unknown',
                      ),
                    );
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Chip(
                        label: Text(tag.tagName),
                        deleteIcon: const Icon(Icons.close),
                        onDeleted: () {
                          setState(() {
                            selectedTags.remove(tagId);
                            _generateCardInfoList(); // Update list after removing tag
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          // List of place cards with dividers
          Expanded(
            child:

                (listPlaces.isNotEmpty && isPlace) || (listEvent.isNotEmpty && !isPlace)
                ? Column(
                  children: [
                    Expanded(
                      child: isPlace?
                        ListView.separated(
                            controller: _listPlaceScrollController,
                            physics: const BouncingScrollPhysics(),
                            itemCount: listPlaces.length+1,
                            separatorBuilder: (context, index) => const Divider(
                              height: 5,
                            ),
                            itemBuilder: (context, index) {
                              final cardInfo =  listPlaces[index % listPlaces.length];
                              return (index == listPlaces.length)? SizedBox(height: 42,) :
                                GestureDetector(
                                onTap: () {
                                  _navigateToDetail(cardInfo.placeId);
                                },
                                child: SecondPlaceCard(
                                  placeCardId: cardInfo.placeId,
                                  placeName: cardInfo.placeName,
                                  wardName: cardInfo.wardName,
                                  photoDisplay: cardInfo.photoDisplayUrl,
                                  score: cardInfo.rateStar,
                                  distance: cardInfo.distance,
                                ),
                              );
                            },

                          ) :
                      ListView.separated(
                        controller: _listPlaceScrollController,
                        physics: const BouncingScrollPhysics(),
                        itemCount: listEvent.length + 1,
                        separatorBuilder: (context, index) => const Divider(
                          height: 5,
                        ),
                        itemBuilder: (context, index) {
                          final eventInfo =  listEvent[index % listEvent.length];
                          return (index == listEvent.length)? SizedBox(height: 42,) :
                          GestureDetector(
                            onTap: () {
                              //_navigateToDetail(cardInfo.placeId);
                            },
                            child: SecondPlaceCard(
                              placeCardId: eventInfo.placeId,
                              placeName: eventInfo.eventName,
                              wardName: eventInfo.placeName,
                              photoDisplay: eventInfo.eventPhoto!,
                              score: 5,
                              distance: eventInfo.distance,
                              isEvent: true,
                              event: eventInfo,
                            ),
                          );
                        },

                      )
                      ,

                    ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _isLoading
                    ? const SizedBox(child: CircularProgressIndicator())
                    : const SizedBox(),
                  )
                  ],
                )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off,
                            size: 80, color: Colors.grey),
                        Text(
                          "No places match your selected categories.",
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey[700]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(int placeId) {
    PlaceCardModel? selectedPlace = listPlaces.firstWhereOrNull((place) => place.placeId == placeId);

    if (selectedPlace != null) {
      if (widget.onPlaceSelected != null) {
        widget.onPlaceSelected!(selectedPlace);
        Navigator.pop(context);
      } else {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailPage(
              placeId: selectedPlace.placeId,
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Place not found')),
      );
    }
  }
}
