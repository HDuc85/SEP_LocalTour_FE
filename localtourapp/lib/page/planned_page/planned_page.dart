import 'package:flutter/material.dart';
import 'package:localtourapp/page/planned_page/planned_page_tab_bars/history_tab_bar.dart';
import 'planned_page_tab_bars/schedule_tab_bar.dart';

class PlannedPage extends StatefulWidget {
  final String userId;

  const PlannedPage({
    super.key,
    required this.userId,
  });

  @override
  State<PlannedPage> createState() => _PlannedPageState();
}

class _PlannedPageState extends State<PlannedPage> {
  @override
  Widget build(BuildContext context) {
    // Fetching all schedules from ScheduleProvider

    return DefaultTabController(
      length: 2, // Schedule and History
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Planned Page"),
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
              userId: widget.userId,
            ),
            const HistoryTabbar(),
          ],
        ),
      ),
    );
  }
}
