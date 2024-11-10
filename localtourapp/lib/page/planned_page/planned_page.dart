import 'package:flutter/material.dart';
import 'package:localtourapp/base/schedule_provider.dart';
import 'package:localtourapp/models/places/place.dart';
import 'package:localtourapp/models/places/placetranslation.dart';
import 'package:localtourapp/page/account/user_provider.dart';
import 'package:provider/provider.dart';

import '../../models/schedule/destination.dart';
import '../../models/schedule/schedule.dart';
import '../../models/schedule/schedulelike.dart';
import '../../models/users/users.dart';
import 'planned_page_tab_bars/history_tabbar.dart';
import 'planned_page_tab_bars/schedule_tabbar.dart';

class PlannedPage extends StatefulWidget {
  final String userId;
  final List<ScheduleLike> scheduleLikes;
  final List<Destination> destinations;
  final List<User> users;

  const PlannedPage({
    super.key,
    required this.userId,
    required this.scheduleLikes,
    required this.destinations,
    required this.users,
  });

  @override
  State<PlannedPage> createState() => _PlannedPageState();
}

class _PlannedPageState extends State<PlannedPage> {
  @override
  Widget build(BuildContext context) {
    // Fetching all schedules from ScheduleProvider
    final scheduleProvider = Provider.of<ScheduleProvider>(context);
    final List<Schedule> allSchedules = scheduleProvider.schedules;
    final List<Place> places = scheduleProvider.places;
    final List<PlaceTranslation> translations = scheduleProvider.translations;

    // Filtering schedules for the current user
    final List<Schedule> userSchedules = allSchedules
        .where((schedule) => schedule.userId == widget.userId)
        .toList();
    print('User Schedules Count: ${userSchedules.length}');
    final List<ScheduleLike> userScheduleLikes = widget.scheduleLikes
        .where((like) => like.userId == widget.userId)
        .toList();

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
              schedules: userSchedules,
              scheduleLikes: userScheduleLikes,
              destinations: widget.destinations,
              onFavoriteToggle: (scheduleId, isFavorited) {
                // Implement your favorite toggle logic here
                if (isFavorited) {
                  scheduleProvider.addScheduleLike(ScheduleLike(
                    id: scheduleProvider.scheduleLikes.length + 1,
                    userId: widget.userId,
                    scheduleId: scheduleId,
                    createdDate: DateTime.now(),
                  ));
                } else {
                  scheduleProvider.removeScheduleLike(scheduleId, widget.userId);
                }
              },
              places: places, // Passing all places
              translations: translations, // Passing all translations
            ),
            const HistoryTabbar(),
          ],
        ),
      ),
    );
  }
}
