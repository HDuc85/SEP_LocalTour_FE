import 'package:flutter/material.dart';
import 'package:localtourapp/models/Tag/tag_model.dart';
import 'package:localtourapp/models/users/userProfile.dart';
import 'package:localtourapp/services/tag_service.dart';

import '../../config/appConfig.dart';
import '../../config/secure_storage_helper.dart';

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
  String _languageCode = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getdata();

  }

  Future<void> getdata()async{
    var languageCode = await SecureStorageHelper().readValue(AppConfig.language);
    var fetchListTag = await _tagService.getAllTag(1,30);
    var fetchUserTag = await _tagService.getUserTag();
    
    setState(() {
      listUserTag = fetchUserTag;
      listTag = fetchListTag;
      isLoading = false;
      _languageCode = languageCode!;
    });
    var x = await _tagService.UpdateTagsPreferencs(fetchUserTag.map((e) => e.id,).toList());

  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(_languageCode == 'vi' ? "Sở thích của ${widget.userprofile.userName}": "Preferences's ${widget.userprofile.userName}"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
      isLoading?  const Center(child: CircularProgressIndicator()) :SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(_languageCode == 'vi' ? "Chọn sở thích của bạn":"Choose your preferences" , style: const TextStyle(fontSize: 18)),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children:  _buildAllTagChips(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Builds a chip for each tag in the listTag
  List<Widget> _buildAllTagChips() {


    return

      listTag.map((tag) {
      final isSelected = listUserTag.any((element) => element.id == tag.id,);

      return
        GestureDetector(
        onTap: () {
          setState(() {
            // Toggle the tag selection with enforcement of minimum 5 selections
            if (isSelected) {
              if (listUserTag.length > 5) {
                listUserTag.removeWhere((element) => element.id == tag.id,);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_languageCode == 'vi' ? 'Chọn ít nhất 5 sở thích':'You must select at least 5 preferences.'),
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
              _languageCode == 'vi' ? tag.tagVi :
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