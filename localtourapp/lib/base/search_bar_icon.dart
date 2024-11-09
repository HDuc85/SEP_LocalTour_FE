import 'package:flutter/material.dart';
import '../models/places/placetranslation.dart';

class SearchBarIcon extends StatefulWidget {
  final List<PlaceTranslation> placeTranslations;

  const SearchBarIcon({Key? key, required this.placeTranslations}) : super(key: key);

  @override
  State<SearchBarIcon> createState() => _SearchBarIconState();
}

class _SearchBarIconState extends State<SearchBarIcon> {
  bool isSearchIsClicked = false;
  final TextEditingController _searchController = TextEditingController();
  String searchText = '';
  List<dynamic> filteredItems = [];

  @override
  void initState() {
    super.initState();
    filteredItems = List<dynamic>.from(widget.placeTranslations);
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchText = value;
      _filterItems();
    });
  }

  void _filterItems() {
    if (searchText.isEmpty) {
      filteredItems = List<dynamic>.from(widget.placeTranslations);
    } else {
      final lowerSearchText = searchText.toLowerCase();

      // Filter based on multiple fields
      filteredItems = List<dynamic>.from(
        widget.placeTranslations.where((item) {
          return item.placeName.toLowerCase().contains(lowerSearchText) ||
              (item.description?.toLowerCase().contains(lowerSearchText) ?? false) ||
              item.address.toLowerCase().contains(lowerSearchText) ||
              (item.contact?.toLowerCase().contains(lowerSearchText) ?? false);
        }).toList(),
      );

      // Insert the placeholder search action at the top
      filteredItems.insert(0, 'Search for "$searchText"');
    }
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
                            filteredItems = List<dynamic>.from(widget.placeTranslations);
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
              child: filteredItems.isNotEmpty
                  ? ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];

                  return ListTile(
                    leading: item is String
                        ? const Icon(Icons.search)
                        : const Icon(Icons.location_on),
                    title: item is String
                        ? Text(item) // Display the "Search for..." action
                        : Text(item.placeName), // Display place name for PlaceTranslation
                    subtitle: item is String
                        ? null
                        : Text(item.address), // Display address if item is PlaceTranslation
                    onTap: () {
                      if (item is String) {
                        // Handle the search action here
                        // Example: Perform a search based on `searchText`
                        print('Search for "$searchText"');
                        // You can navigate to a search results page or perform additional actions
                      } else {
                        // Handle selection of a specific place here
                        // Example: Navigate to a detail page or update the state
                        print('Selected place: ${item.placeName}');
                      }
                      setState(() {
                        isSearchIsClicked = false;
                        _searchController.clear();
                        searchText = '';
                        filteredItems = List<dynamic>.from(widget.placeTranslations);
                      });
                    },
                  );
                },
              )
                  : const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('No results found.'),
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
