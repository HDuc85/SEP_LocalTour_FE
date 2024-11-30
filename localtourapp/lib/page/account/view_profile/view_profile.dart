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
    super.initState();
    fetch();
  }

  Future<void> fetch() async {
    String? myUserId = await SecureStorageHelper().readValue(AppConfig.userId);
    if (myUserId != null && myUserId == widget.userId) {
      setState(() {
        isCurrentUserId = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: isCurrentUserId ? 2 : 3,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                title: Text('${widget.user.fullName} Profile', maxLines: 2),
                pinned: true,
                floating: true,
                snap: false,
                forceElevated: innerBoxIsScrolled,
                bottom: TabBar(
                  indicatorColor: Colors.black,
                  tabs: [
                    Tab(
                      icon: Icon(Icons.post_add, color: Colors.blue),
                      text: "Posts",
                    ),
                    Tab(
                      icon: Icon(Icons.rate_review, color: Colors.green),
                      text: "Reviews",
                    ),
                    if (!isCurrentUserId)
                      Tab(
                        icon: Icon(Icons.schedule, color: Colors.red),
                        text: "Schedules",
                      ),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
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
      ),
    );
  }
}
