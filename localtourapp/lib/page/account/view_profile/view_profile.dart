import 'package:flutter/material.dart';
import 'package:localtourapp/config/appConfig.dart';
import 'package:localtourapp/config/secure_storage_helper.dart';
import 'package:localtourapp/models/users/userProfile.dart';
import 'package:localtourapp/page/account/view_profile/post_tab_bar.dart';
import 'package:localtourapp/page/account/view_profile/reviewed_tab_bar.dart';
import 'package:localtourapp/page/planned_page/planned_page_tab_bars/schedule_tab_bar.dart';

class ViewProfilePage extends StatefulWidget {
  final String userId;
  final Userprofile user;

  const ViewProfilePage({
    Key? key,
    required this.user,
    required this.userId,
  }) : super(key: key);

  @override
  State<ViewProfilePage> createState() => _ViewProfilePageState();
}

class _ViewProfilePageState extends State<ViewProfilePage> {

  bool isCurrentUserId = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetch();
  }

  Future<void> fetch() async{
    String? myUserId = await SecureStorageHelper().readValue(AppConfig.userId);
    if(myUserId != null){
      if(myUserId == widget.userId){
        setState(() {
          isCurrentUserId = true;
        });
      }

    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.user.fullName} Profile', maxLines: 2),
      ),
      body: DefaultTabController(
        length: isCurrentUserId ? 2 : 3,
        child: Column(
          children: [
            TabBar(
              tabs: [
                const Tab(text: "Posts"),
                const Tab(text: "Reviews"),
                if (!isCurrentUserId) const Tab(text: "Schedules"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  PostTabBar(
                    userId: widget.userId,
                    user: widget.user,
                    isCurrentUser: isCurrentUserId,
                  ),
                  ReviewedTabbar(
                      userId: widget.userId,
                  ),
                  if (!isCurrentUserId)
                    ScheduleTabbar(
                      userId: widget.userId,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}