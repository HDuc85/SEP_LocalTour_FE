
import 'dart:convert';

import '../models/event/event_model.dart';
import 'api_service.dart';

class EventService {
  final apiService = ApiService();


  Future<List<EventModel>> GetEventInPlace(int placeId) async{
    final response = await apiService.makeRequest("Event/GetAllEventByVisitor?placeid=$placeId", "GET");

    if(response.statusCode == 200){
      final jsonResponse = json.decode(response.body);
      return mapJsonToEventModels(jsonResponse['items']);
    }
    else{
      throw Exception("Lỗi khi lấy dữ liệu. Mã lỗi: ${response.statusCode}");

    }
  }
}