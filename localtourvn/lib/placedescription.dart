import 'package:flutter/material.dart';

import 'models/places/placetranslation.dart';

class PlaceDescription extends StatefulWidget {
  final int placeId;

  const PlaceDescription({Key? key, required this.placeId}) : super(key: key);

  @override
  State<PlaceDescription> createState() => _PlaceDescriptionState();
}

class _PlaceDescriptionState extends State<PlaceDescription> {
  bool isExpanded = false; // To track if the description is expanded

  String? descriptionText;

  @override
  void initState() {
    super.initState();
    _fetchDescription(); // Fetch the description when the widget is built
  }

  void _fetchDescription() {
    // Find the place translation using placeId
    final placeTranslation = translations.firstWhere(
          (t) => t.placeId == widget.placeId,
      orElse: () => translations.first, // Return a default PlaceTranslation if not found
    );

    setState(() {
      descriptionText = placeTranslation.description ?? "No description available.";
    });
  }

  @override
  Widget build(BuildContext context) {
    if (descriptionText == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final int maxDescriptionLength = 500; // Limit for showing the "More description" link
    final bool isLongDescription = descriptionText!.length > maxDescriptionLength;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
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
                isExpanded ? "Less description" : "More description",
                style: const TextStyle(color: Colors.pink),
              ),
            ),
        ],
      ),
    );
  }
}
