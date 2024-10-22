import 'package:flutter/material.dart';

import 'location_card_info.dart';

class Category {
  final String name;
  final IconData icon;
  final List<LocationCardInfo> cards;

  Category({required this.name, required this.icon, required this.cards});
}
