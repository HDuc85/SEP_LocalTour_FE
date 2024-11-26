import 'dart:convert';
import 'dart:ui';

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
      return mapJsonToScheduleModel(jsonResponse['data']['items']);
    }
    else {
      return [];
    }
  }

  Future<bool> LikeSchedule(int scheduleId)async {
    var userId = await SecureStorageHelper().readValue(AppConfig.userId);
    if(userId != null){
      final response = await _apiService.makeRequest("ScheduleLike/like?scheduleId=$scheduleId&userId=$userId", "POST");
      if(response.statusCode == 200){
        return true;
      }
      return false;
    }
    return false;
  }

  Future<bool> CreateSchedule(String scheduleName, DateTime? startDate, DateTime? endDate, [bool? isPublic]) async {
    var body = {
      "scheduleName": "$scheduleName",
      "startDate": startDate != null? startDate.toIso8601String() : null,
      "endDate": endDate != null? endDate.toIso8601String() : null,
      "isPublic": isPublic ?? false
    };
    
    var response = await _apiService.makeRequest('Schedule/createSchedule', "POST",body);

    if(response.statusCode == 200){
      return true;
    }
    return false;
    
  }

  Future<bool> UpdateSchedule(int scheduleId, String scheduleName, DateTime? startDate, DateTime? endDate, bool? isPublic) async {
    var body =
      {
        "scheduleId": scheduleId,
        "scheduleName": "$scheduleName",
        "startDate": startDate != null ? startDate.toIso8601String() : null,
        "endDate": endDate != null ? endDate.toIso8601String() : null,
        "isPublic": isPublic ?? false
    };

    var response = await _apiService.makeRequest('Schedule/updateSchedule', "PUT",body);

    if(response.statusCode == 200){
      return true;
    }
    return false;
  }
  Future<bool> DeleteSchedule(int scheduleId) async {
    var response = await _apiService.makeRequest('Schedule/deleteSchedule/$scheduleId', "DELETE");
    if(response.statusCode == 200){
      return true;
    }
    return false;
  }

  Future<bool> CreateDestination(int scheduleId,int placeId, DateTime? startDate, DateTime? endDate,String? detail, [bool? isArrive]) async {
    var body = {
      "scheduleId": scheduleId,
      "placeId": placeId,
      "startDate": startDate != null? startDate.toUtc().toIso8601String() : null,
      "endDate": endDate != null? endDate.toUtc().toIso8601String() : null,
      "detail": detail != null? detail: '',
      "isArrived": false
    };

    var response = await _apiService.makeRequest('Destination/createDestination', "POST",body);

    if(response.statusCode == 200){
      return true;
    }
    return false;

  }
  Future<bool> UpdateDestination(int destinationId,int scheduleId,int placeId, DateTime? startDate, DateTime? endDate,String? detail, bool? isArrive) async {
    var body = {
      "scheduleId": scheduleId,
      "placeId": placeId,
      "startDate": startDate != null? startDate.toIso8601String() : null,
      "endDate": endDate != null? endDate.toIso8601String() : null,
      "detail": detail,
      "isArrived": isArrive != null ? isArrive : false
    };

    var response = await _apiService.makeRequest('Destination/updateDestination/$destinationId', "PUT",body);

    if(response.statusCode == 200){
      return true;
    }
    return false;

  }
  Future<bool> DeleteDestination(int destinationId) async {
    var response = await _apiService.makeRequest('Destination/deleteDestination/$destinationId', "DELETE");
    if(response.statusCode == 200){
      return true;
    }
    return false;
  }


}