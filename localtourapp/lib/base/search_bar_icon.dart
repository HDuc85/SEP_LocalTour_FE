import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:localtourapp/models/event/event_model.dart';
import 'package:localtourapp/page/detail_page/event_detail_page.dart';
import 'package:localtourapp/services/event_service.dart';

import '../constants/getListApi.dart';
import '../models/HomePage/placeCard.dart';
import '../page/detail_page/detail_page.dart';
import '../page/search_page/search_page.dart';
import '../services/place_service.dart';

class SearchBarIcon extends StatefulWidget {
  final Position? position;
  final String? language;
  const SearchBarIcon({Key? key, this.position, this.language}) : super(key: key);

  @override
  State<SearchBarIcon> createState() => _SearchBarIconState();
}

class _SearchBarIconState extends State<SearchBarIcon> {
  bool isSearchIsClicked = false;
  final TextEditingController _searchController = TextEditingController();
  String searchText = '';
  final PlaceService _placeService = PlaceService();
  final EventService _eventService = EventService();
  Position? _currentPosition;

  List<PlaceCardModel> placeTranslations = [];
  List<EventModel> events =[];
  Timer? _debounce;
  @override
  void initState() {
    super.initState();
    _currentPosition = widget.position;
  }

  void _onSearchChanged(String value) {
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


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 50,
                width: isSearchIsClicked
                    ? MediaQuery.of(context).size.width * 0.90
                    : 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isSearchIsClicked ? Icons.close : Icons.search,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          isSearchIsClicked = !isSearchIsClicked;
                          if (!isSearchIsClicked) {
                            _searchController.clear();
                            searchText = '';
                            placeTranslations;
                          }
                        });
                      },
                    ),
                    if (isSearchIsClicked)
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          autofocus: true,
                          decoration:  InputDecoration(
                            hintText: widget.language != 'vi'? "Where do you want to go?" : 'Bạn muốn đi đâu?',
                            border: InputBorder.none,
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
        if (isSearchIsClicked && searchText.isNotEmpty)
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
                        ? Text(widget.language != 'vi'?"Search for $searchText" : 'Tìm kiếm với $searchText') // Display the "Search for..." action
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailPage(
                                placeId: placeItem!.placeId,

                              ),
                            ),
                          );
                        }else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EventDetailPage(
                                eventModel: eventItem!,
                              ),
                            ),
                          );
                        }

                      }
                    },
                  );
                },

              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
