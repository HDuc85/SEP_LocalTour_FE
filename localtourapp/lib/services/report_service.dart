import 'package:localtourapp/services/api_service.dart';

class ReportService {
  final ApiService _apiService = ApiService();

  Future<String> reportPlace(int placeId, String message) async {
    var body = {
      "placeId": placeId,
      "message": message
    };

    final response = await _apiService.makeRequest("PlaceReport","POST",body);
    if (response.statusCode == 200) {
      return "Success";
    } else if(response.statusCode == 400) {
      return response.body;
    }
    return '';
  }

  Future<String> reportUser(String userId, String message) async {
    var body = {
      "userId": userId,
      "content": message,
    };

    final response = await _apiService.makeRequest("UserReport","POST",body);
    if (response.statusCode == 200) {
      return "Your report has been sent!";
    } else if(response.statusCode == 400) {
      return response.body;
    }
    return '';
  }
}