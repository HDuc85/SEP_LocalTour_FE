import 'package:flutter/material.dart';
import 'package:localtourvn/page/plannedpage/plannedpagetabbars/history_tabbar.dart';
import 'package:localtourvn/page/plannedpage/plannedpagetabbars/schedule_tabbar.dart';

import '../../models/schedule/destination.dart';
import '../../models/schedule/schedule.dart';
import '../../models/schedule/schedulelike.dart';
import '../../models/users/users.dart';

class PlannedPage extends StatefulWidget {
  final User user;
  final List<Schedule> schedules;
  final List<ScheduleLike> scheduleLikes;
  final List<Destination> destinations;

  const PlannedPage({
    super.key,
    required this.user,
    required this.schedules,
    required this.scheduleLikes,
    required this.destinations,
  });

  @override
  State<PlannedPage> createState() => _PlannedPageState();
}

class _PlannedPageState extends State<PlannedPage> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height,
      width: size.width, // Changed from size.height to size.width
      child: DefaultTabController(
        length: 2, // Schedule and History
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Planned Page'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Schedule'),
                Tab(text: 'History'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              ScheduleTabbar(
                userId: widget.user.userId,
                user: widget.user,
                schedules: widget.schedules,
                scheduleLikes: widget.scheduleLikes,
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
