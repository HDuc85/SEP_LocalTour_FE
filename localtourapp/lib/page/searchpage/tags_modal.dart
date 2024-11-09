import 'package:flutter/material.dart';

import '../../models/places/tag.dart';

void showTagsModal({
  required BuildContext context,
  required List<int> selectedTags,
  required Function(List<int>) onSelectedTagsChanged,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (BuildContext context) {
      // Create a copy of selectedTags to manage within the modal
      List<int> currentSelectedTags = List.from(selectedTags);

      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.8,
        builder: (context, scrollController) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Categories",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: listTag.length,
                        itemBuilder: (context, index) {
                          final tag = listTag[index];
                          final isSelected = currentSelectedTags.contains(tag.tagId);

                          return CheckboxListTile(
                            value: isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  currentSelectedTags.add(tag.tagId);
                                } else {
                                  currentSelectedTags.remove(tag.tagId);
                                }
                              });
                              onSelectedTagsChanged(currentSelectedTags);
                            },
                            title: Row(
                              children: [
                                Image.asset(
                                  tag.tagPhotoUrl,
                                  width: 24,
                                  height: 24,
                                  fit: BoxFit.cover,
                                  semanticLabel: '${tag.tagName} icon',
                                ),
                                const SizedBox(width: 12),
                                Text(tag.tagName),
                              ],
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close the modal
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEAA8A8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: const BorderSide(color: Colors.black),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        ),
                        child: const Text("Done", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}