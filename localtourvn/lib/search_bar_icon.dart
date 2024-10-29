import 'package:flutter/material.dart';
import 'models/places/placetranslation.dart';

class SearchBarIcon extends StatefulWidget {
  final List<PlaceTranslation> placeTranslations;

  const SearchBarIcon({super.key, required this.placeTranslations});

  @override
  State<SearchBarIcon> createState() => _SearchBarIconState();
}

class _SearchBarIconState extends State<SearchBarIcon> {
  bool isSearchIsClicked = false;
  final TextEditingController _searchController = TextEditingController();

  String searchText = '';
  List<String> items = []; // Will include all place names
  List<String> filteredItems = [];
  int maxItemsToShow = 10;

  @override
  void initState() {
    super.initState();
    // Populate items with place names from the provided place translations
    items = widget.placeTranslations.map((translation) => translation.placeName).toList();
    filteredItems = List.from(items);
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchText = value;
      _filterItems();
    });
  }

  void _filterItems() {
    if (searchText.isEmpty) {
      filteredItems = List.from(items);
    } else {
      filteredItems = items
          .where((item) => item.toLowerCase().contains(searchText.toLowerCase()))
          .toList();

      filteredItems.insert(0, 'Search for "$searchText"');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
        if (isSearchIsClicked && searchText.isNotEmpty)
          Positioned(
            top: 60,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
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
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: filteredItems.length > maxItemsToShow
                    ? maxItemsToShow
                    : filteredItems.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(filteredItems[index]),
                    onTap: () {
                      if (index == 0 && searchText.isNotEmpty) {
                        print('Searching for: $searchText');
                      } else {
                        print('Selected: ${filteredItems[index]}');
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
}
