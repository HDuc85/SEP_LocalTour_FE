import 'dart:math';
import 'place.dart'; // Assuming you have the Place class defined

class PlaceReport {
  int id;
  int placeId; // Maps with placeId in Place
  DateTime reportDate;
  String status; // "processed" or "unprocessed"

  PlaceReport({
    required this.id,
    required this.placeId,
    required this.reportDate,
    required this.status,
  });

  factory PlaceReport.fromJson(Map<String, dynamic> json) => PlaceReport(
    id: json['Id'] as int,
    placeId: json['PlaceId'] as int,
    reportDate: DateTime.parse(json['ReportDate'] as String),
    status: json['Status'] as String,
  );

  Map<String, dynamic> toJson() => {
    'Id': id,
    'PlaceId': placeId,
    'ReportDate': reportDate.toIso8601String(),
    'Status': status,
  };
}

// Function to generate random PlaceReport data
List<PlaceReport> generatePlaceReports(int count, List<Place> places) {
  final random = Random();
  List<String> statuses = ['processed', 'unprocessed']; // Possible statuses
  List<PlaceReport> placeReports = [];

  for (int i = 0; i < count; i++) {
    int id = i + 1; // Sequential id for PlaceReport
    // Randomly select a placeId from the provided Place list
    int placeId = places[random.nextInt(places.length)].placeId;
    // Randomly select a status ('processed' or 'unprocessed')
    String status = statuses[random.nextInt(statuses.length)];
    // Randomly generate a report date within the past 30 days
    DateTime reportDate = DateTime.now().subtract(Duration(days: random.nextInt(30)));

    PlaceReport placeReport = PlaceReport(
      id: id,
      placeId: placeId,
      reportDate: reportDate,
      status: status,
    );

    placeReports.add(placeReport);
  }

  return placeReports;
}

List<PlaceReport> reportList = generatePlaceReports(10, dummyPlaces);