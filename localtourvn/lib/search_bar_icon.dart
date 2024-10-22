import 'package:flutter/material.dart';

class SearchBarIcon extends StatefulWidget {
  const SearchBarIcon({super.key});

  @override
  State<SearchBarIcon> createState() => _SearchBarIconState();
}

class _SearchBarIconState extends State<SearchBarIcon> {
  bool isSearchIsClicked = false;
  final TextEditingController _searchController = TextEditingController();

  String searchText = '';
  List<String> items = [
    "Bitexco",
    "Cu Chi",
    "Hoc Mon",
    "War Remnants Museum",
    "Independence Palace",
    "Snow Town Sai Gon",
    "Bui Vien walking street",
    "Ben Thanh Market",
  ];

  List<String> filteredItems = [];
  int maxItemsToShow = 10;

  @override
  void initState() {
    super.initState();
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
          .where((item) =>
          item.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      isSearchIsClicked = !isSearchIsClicked;
                      if (!isSearchIsClicked) {
                        _searchController.clear();
                      }
                    });
                  },
                  icon: Icon(isSearchIsClicked ? Icons.close : Icons.search),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 20),
                  child: isSearchIsClicked
                      ? Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 40),
                        fillColor: Colors.grey[200],
                        hintText: "Where do you want to go?",
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        border: InputBorder.none,
                      ),
                    ),
                  )
                      : const Text(""),
                ),
              ),
            ],
          ),
        ),
        if (isSearchIsClicked && searchText.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filteredItems.length > maxItemsToShow
                  ? maxItemsToShow
                  : filteredItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filteredItems[index]),
                  onTap: () {
                    // Handle item click
                    print('Selected: ${filteredItems[index]}');
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
