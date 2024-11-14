import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:localtourapp/models/places/tag.dart';
import 'package:localtourapp/page/account/user_provider.dart';

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
            // Toggle the tag selection
            if (isSelected) {
              userProvider.removeTag(tag.tagId);
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
