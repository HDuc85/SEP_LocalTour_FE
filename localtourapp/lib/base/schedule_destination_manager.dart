// lib/base/schedule_destination_manager.dart

import 'package:flutter/material.dart';
import 'package:localtourapp/base/destination_provider.dart';
import 'package:localtourapp/base/schedule_provider.dart';

class ScheduleDestinationManager {
  final ScheduleProvider scheduleProvider;
  final DestinationProvider destinationProvider;

  ScheduleDestinationManager({
    required this.scheduleProvider,
    required this.destinationProvider,
  });

  void removeSchedule(int scheduleId) {
    scheduleProvider.removeSchedule(scheduleId);
    destinationProvider.removeDestinationsByScheduleId(scheduleId);
  }
}
