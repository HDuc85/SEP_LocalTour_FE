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
    return DefaultTabController(
      length: 2, // Schedule and History
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                title: const Text("Planned Page"),
                floating: true,
                pinned: true,
                bottom: TabBar(
                  tabs: const [
                    Tab(
                      text: 'Schedule',
                      icon: Icon(Icons.schedule),
                    ),
                    Tab(
                      text: 'History',
                      icon: Icon(Icons.history),
                    ),
                  ],
                  labelColor: Colors.black, // Selected tab text color
                  unselectedLabelColor: Colors.black54, // Unselected tab text color
                  indicatorColor: Colors.black, // Underline indicator color
                  indicatorWeight: 3.0, // Underline thickness
                  indicatorPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold), // Selected tab text style
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal), // Unselected tab text style
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  splashBorderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              ScheduleTabbar(
                userId: widget.userId,
              ),
              const HistoryTabbar(),
            ],
          ),
        ),
      ),
    );
  }
}
