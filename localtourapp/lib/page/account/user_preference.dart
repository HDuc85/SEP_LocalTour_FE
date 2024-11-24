import 'package:flutter/material.dart';
import 'package:localtourapp/models/Tag/tag_model.dart';
import 'package:localtourapp/models/users/userProfile.dart';
import 'package:localtourapp/services/tag_service.dart';
import 'package:provider/provider.dart';

import '../../models/places/tag.dart';
import '../../provider/user_provider.dart';

class UserPreferencePage extends StatefulWidget {
  final Userprofile userprofile;
  const UserPreferencePage({Key? key, required this.userprofile}) : super(key: key);

  @override
  State<UserPreferencePage> createState() => _UserPreferencePageState();
}

class _UserPreferencePageState extends State<UserPreferencePage> {
  final TagService _tagService = TagService();
  late List<TagModel> listUserTag;
  late List<TagModel> listTag;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Getdata();

  }

  Future<void> Getdata()async{
    var fetchListTag = await _tagService.getAllTag(1,30);
    var fetchUserTag = await _tagService.getUserTag();
    
    setState(() {
      listUserTag = fetchUserTag;
      listTag = fetchListTag;
      isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.currentUser.userName;

    return Scaffold(
      appBar: AppBar(
        title: Text("Preferences's ${widget.userprofile.userName}"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            List<int> listTagSelected = listUserTag.map((e) => e.id,).toList();
            var result = await _tagService.addTagsPreferencs(listTagSelected);
            if(result){
              Navigator.pop(context);
            }
          },
        ),
      ),
      body:
      isLoading?  Center(child: CircularProgressIndicator()) :Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text("Choose your preferences", style: TextStyle(fontSize: 18)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children:  _buildAllTagChips(userProvider),
            ),
          ),
        ],
      ),
    );
  }

  // Builds a chip for each tag in the listTag
  List<Widget> _buildAllTagChips(UserProvider userProvider) {


    return listTag.map((tag) {
      final isSelected = listUserTag.any((element) => element.id == tag.id,);

      return
        GestureDetector(
        onTap: () {
          setState(() {
            // Toggle the tag selection with enforcement of minimum 5 selections
            if (isSelected) {
              if (listUserTag.length > 4) {
                listUserTag.removeWhere((element) => element.id == tag.id,);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('You must select at least 5 preferences.'),
                  ),
                );
              }
            } else {
              listUserTag.add(tag);

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