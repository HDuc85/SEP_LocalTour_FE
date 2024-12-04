import 'package:flutter/material.dart';

class PlaceDescription extends StatefulWidget {
  final String placeDescription;
  final String language;
  const PlaceDescription({Key? key, required this.placeDescription, required this.language})
      : super(key: key);

  @override
  State<PlaceDescription> createState() => _PlaceDescriptionState();
}

class _PlaceDescriptionState extends State<PlaceDescription> {
  bool isExpanded = false; // To track if the description is expanded

  String? descriptionText;

  @override
  void initState() {
    super.initState();
    descriptionText = widget.placeDescription;
    //_fetchDescription(); // Fetch the description when the widget is built
  }

  void _fetchDescription() {
    // Find the place translation using placeId
  }

  @override
  Widget build(BuildContext context) {
    if (descriptionText == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final int maxDescriptionLength =
        170; // Limit for showing the "More description" link
    final bool isLongDescription =
        descriptionText!.length > maxDescriptionLength;

    return Container(
      padding: const EdgeInsets.all(16.0),
      width: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            widget.language != 'vi'? 'Description': 'Mô tả',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            isExpanded || !isLongDescription
                ? descriptionText!
                : "${descriptionText!.substring(0, maxDescriptionLength)}...",
            style: const TextStyle(fontSize: 14),
          ),
          if (isLongDescription)
            TextButton(
              onPressed: () {
                setState(() {
                  isExpanded = !isExpanded; // Toggle the expanded state
                });
              },
              child: Text(
                isExpanded ? (widget.language != 'vi'? "Less description": 'Thu gọn') : (widget.language != 'vi' ? "More description" : 'Mở rộng'),
                style: const TextStyle(color: Colors.pink),
              ),
            ),
        ],
      ),
    );
  }
}
