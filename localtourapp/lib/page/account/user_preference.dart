import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/places/tag.dart';
import '../../provider/user_provider.dart';

class UserPreferencePage extends StatefulWidget {
  const UserPreferencePage({Key? key}) : super(key: key);

  @override
  State<UserPreferencePage> createState() => _UserPreferencePageState();
}

class _UserPreferencePageState extends State<UserPreferencePage> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.currentUser.userName;

    return Scaffold(
      appBar: AppBar(
        title: Text("Preferences's $userName"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text("Choose your preferences", style: TextStyle(fontSize: 18)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _buildAllTagChips(userProvider),
            ),
          ),
        ],
      ),
    );
  }

  // Builds a chip for each tag in the listTag
  List<Widget> _buildAllTagChips(UserProvider userProvider) {
    return listTag.map((tag) {
      final isSelected = userProvider.isTagSelected(tag.tagId);

      return GestureDetector(
        onTap: () {
          setState(() {
            // Toggle the tag selection with enforcement of minimum 5 selections
            if (isSelected) {
              // Allow deselection only if more than 5 tags are selected
              if (userProvider.preferredTagIds.length > 5) {
                userProvider.removeTag(tag.tagId);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('You must select at least 5 preferences.'),
                  ),
                );
              }
            } else {
              userProvider.addTag(tag.tagId);
            }
          });
        },
        child: Chip(
          label: Text(
            tag.tagName,
            style: TextStyle(color: isSelected ? Colors.white : Colors.green),
          ),
          shape: const StadiumBorder(
            side: BorderSide(color: Colors.green),
          ),
          backgroundColor: isSelected ? Colors.green : Colors.transparent,
        ),
      );
    }).toList();
  }
}