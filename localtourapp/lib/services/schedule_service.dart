import 'dart:convert';

import 'package:localtourapp/config/appConfig.dart';
import 'package:localtourapp/config/secure_storage_helper.dart';
import 'package:localtourapp/constants/getListApi.dart';
import 'package:localtourapp/models/schedule/schedule_model.dart';
import 'package:localtourapp/services/api_service.dart';

class ScheduleService {
  ApiService _apiService = ApiService();


  Future<List<ScheduleModel>> GetScheduleCurrentUser() async {
    var myUserId = await SecureStorageHelper().readValue(AppConfig.userId);

    if(myUserId == null){
      throw new Exception('User is not login');
    }

    final response = await _apiService.makeRequest("Schedule/getByUserId/$myUserId", "GET");

    if(response.statusCode == 200){
      final jsonResponse = json.decode(response.body);
      var result = mapJsonToScheduleModel(jsonResponse['data']);
      return result;
    }
    else{
     return [];
    }
  }

  Future<List<ScheduleModel>> getListSchedule(
      String userId,
      [SortBy? SortBy,
        SortOrder? SortOrder,
        int? Page = 1,
        int? Size = 10,]) async {
    String sortByStr = SortBy != null ? sortByToString(SortBy) : '';
    String sortOrderStr = SortOrder != null ? sortOrderToString(SortOrder) : '';
    String? languageCode = await SecureStorageHelper().readValue(AppConfig.language);

    final response = await _apiService
        .makeRequest("Schedule/getAllSchedule?UserId=$userId&languageCode=$languageCode&SortBy=$sortByStr&SortOrder=$sortOrderStr",
        "GET");
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return mapJsonToScheduleModel(jsonResponse);
    }
    else {
      return [];
    }
  }

}