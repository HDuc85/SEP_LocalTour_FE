import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../constants/getListApi.dart';
import '../models/HomePage/placeCard.dart';
import '../page/detail_page/detail_page.dart';
import '../page/search_page/search_page.dart';
import '../services/place_service.dart';

class SearchBarIcon extends StatefulWidget {
  final Position? position;

  const SearchBarIcon({Key? key, this.position}) : super(key: key);

  @override
  State<SearchBarIcon> createState() => _SearchBarIconState();
}

class _SearchBarIconState extends State<SearchBarIcon> {
  bool isSearchIsClicked = false;
  final TextEditingController _searchController = TextEditingController();
  String searchText = '';
  late PlaceService _placeService = PlaceService();
  Position? _currentPosition;

  List<PlaceCardModel> placeTranslations = [];
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
                          decoration: const InputDecoration(
                            hintText: "Where do you want to go?",
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
                itemCount: placeTranslations.length + 1,
                itemBuilder: (context, index) {

                  final item = placeTranslations.isEmpty || index == placeTranslations.length? null : placeTranslations[index];

                  return ListTile(
                    leading: item == null
                        ? const Icon(Icons.search)
                        : const Icon(Icons.location_on),
                    title: item == null
                        ? Text("Search for $searchText") // Display the "Search for..." action
                        : Text(item.placeName), // Display place name for PlaceTranslation
                    subtitle: item == null
                        ? null
                        : Text(item.address), // Display address if item is PlaceTranslation
                    onTap: () {
                      if (item == null) {
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

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailPage(
                              placeId: item.placeId,
                            ),
                          ),
                        );
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
