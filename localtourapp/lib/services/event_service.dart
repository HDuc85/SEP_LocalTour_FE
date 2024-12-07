
import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:localtourapp/config/appConfig.dart';
import 'package:localtourapp/config/secure_storage_helper.dart';
import 'package:localtourapp/constants/getListApi.dart';
import 'package:localtourapp/services/location_Service.dart';

import '../models/event/event_model.dart';
import 'api_service.dart';

class EventService {
  final apiService = ApiService();
  final LocationService _locationService = LocationService();

  Future<List<EventModel>> getEventInPlace(int? placeId, double latitude,double longitude, [SortOrder? sortOder,SortBy? sortBy ,String? searchTerm = '',int? Page = 1, int? size = 10,]) async{
    String sortByStr = sortBy != null ? sortByToString(sortBy) : '';
    String sortOrderStr = sortOder != null ? sortOrderToString(sortOder) : '';
    String? languageCode = await SecureStorageHelper().readValue(AppConfig.language);

    Position? position = await _locationService.getCurrentPosition();
    double long = position != null ? position.longitude : 106.8096761;
    double lat =  position != null ? position.latitude : 10.8411123;


    final response = await apiService.makeRequest("Event/SearchEvent?placeid=${placeId ?? ''}&languageCode=$languageCode&latitude=$lat&longitude=$long&Page=$Page&Size=$size&SearchTerm=$searchTerm&SortBy=$sortByStr&SortOrder=$sortOrderStr", "GET");
    if(response.statusCode == 200){
      final jsonResponse = json.decode(response.body);
      return mapJsonToEventModels(jsonResponse['items']);
    }
    else{
      throw Exception("Lỗi khi lấy dữ liệu. Mã lỗi: ${response.statusCode}");

    }
  }
}