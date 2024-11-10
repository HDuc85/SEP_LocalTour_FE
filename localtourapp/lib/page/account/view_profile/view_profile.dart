import 'package:flutter/material.dart';
import 'package:localtourapp/base/schedule_provider.dart';
import 'package:localtourapp/models/schedule/schedule.dart';
import 'package:localtourapp/page/account/user_provider.dart';
import 'package:localtourapp/page/account/view_profile/post_tab_bar.dart';
import 'package:localtourapp/page/account/view_profile/reviewd_tab_bar.dart';
import 'package:localtourapp/page/planned_page/planned_page_tab_bars/schedule_tab_bar.dart';
import 'package:provider/provider.dart';

class ViewProfilePage extends StatefulWidget {
  final String userId;

  ViewProfilePage({required this.userId});

  @override
  State<ViewProfilePage> createState() => _ViewProfilePageState();
}

class _ViewProfilePageState extends State<ViewProfilePage> {
  @override
  Widget build(BuildContext context) {
    final scheduleProvider = Provider.of<ScheduleProvider>(context);
    final List<Schedule> allSchedules = scheduleProvider.schedules;
    final List<Schedule> userSchedules = allSchedules
        .where((schedule) => schedule.userId == widget.userId)
        .toList();
    final currentUserId = Provider.of<UserProvider>(context).userId;
    final bool isCurrentUser = currentUserId == widget.userId;

    return Scaffold(
      appBar: AppBar(title: Text("User Profile")),
      body: DefaultTabController(
        length: isCurrentUser ? 2 : 3,
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(text: "Posts"),
                Tab(text: "Reviews"),
                if (!isCurrentUser) Tab(text: "Schedules"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  PostTabBar(
                    schedules: userSchedules,
                    posts: [],
                  ),
                  ReviewedTabBar(),
                  if (!isCurrentUser)
                    ScheduleTabbar(
                      userId: '',
                      schedules: [],
                      scheduleLikes: [],
                      destinations: [],
                      onFavoriteToggle: (int scheduleId, bool isFavorited) {},
                      users: [],
                      places: [],
                      translations: [],
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
