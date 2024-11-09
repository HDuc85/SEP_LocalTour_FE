import 'package:flutter/material.dart';
import 'package:localtourvn/page/plannedpage/plannedpagetabbars/history_tabbar.dart';
import 'package:localtourvn/page/plannedpage/plannedpagetabbars/schedule_tabbar.dart';

import '../../models/schedule/destination.dart';
import '../../models/schedule/schedule.dart';
import '../../models/schedule/schedulelike.dart';
import '../../models/users/users.dart';

class PlannedPage extends StatefulWidget {
  final String userId;
  final List<Schedule> schedules;
  final List<ScheduleLike> scheduleLikes;
  final List<Destination> destinations;
  final ScrollController scrollController;
  final List<User> users;

  const PlannedPage({
    super.key,
    required this.userId,
    required this.schedules,
    required this.scheduleLikes,
    required this.destinations,
    required this.scrollController,
    required this.users,
  });

  @override
  State<PlannedPage> createState() => _PlannedPageState();
}

class _PlannedPageState extends State<PlannedPage> {

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height,
      child: DefaultTabController(
        length: 2, // Schedule and History
        child: Scaffold(
          appBar: AppBar(
            title: const TabBar(
              tabs: [
                Tab(text: 'Schedule'),
                Tab(text: 'History'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              ScheduleTabbar(
                scrollController: widget.scrollController,
                userId: 'anh-tuan-unique-id-1234',
                users: widget.users,
                schedules: dummySchedules.where((schedule) => schedule.userId == 'anh-tuan-unique-id-1234').toList(),
                scheduleLikes: dummyScheduleLikes.where((scheduleLike) => scheduleLike.userId == 'anh-tuan-unique-id-1234').toList(),
                destinations: widget.destinations,
                onFavoriteToggle: (scheduleId, isFavorited) {
                  setState(() {
                    // Toggle favorite state here
                  });
                },
              ),
              const HistoryTabbar(),
            ],
          ),
        ),
      ),
    );
  }
}
