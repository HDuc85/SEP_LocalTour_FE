import 'package:flutter/material.dart';
class SearchBarHome extends StatefulWidget {
  const SearchBarHome({super.key});

  @override
  State<SearchBarHome> createState() => _SearchBarHomeState();
}

class _SearchBarHomeState extends State<SearchBarHome> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.black, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Icon(Icons.search, color: Colors.grey),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              decoration: const InputDecoration(
                hintText: "Where do you want to go?",
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
