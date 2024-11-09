import 'package:flutter/material.dart';

import '../../models/schedule/destination.dart';
import '../../models/schedule/schedule.dart';
import '../../models/schedule/schedulelike.dart';
import '../../models/users/users.dart';
import 'planned_page_tab_bars/history_tabbar.dart';
import 'planned_page_tab_bars/schedule_tabbar.dart';

class PlannedPage extends StatefulWidget {
  final String userId;
  final List<Schedule> schedules;
  final List<ScheduleLike> scheduleLikes;
  final List<Destination> destinations;
  final List<User> users;

  const PlannedPage({
    super.key,
    required this.userId,
    required this.schedules,
    required this.scheduleLikes,
    required this.destinations,
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
    return DefaultTabController(
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
                userId: widget.userId,
                users: widget.users,
                schedules: dummySchedules.where((schedule) => schedule.userId == widget.userId).toList(),
                scheduleLikes: dummyScheduleLikes.where((scheduleLike) => scheduleLike.userId == widget.userId).toList(),
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
      );
  }
}
