import 'dart:convert';
import 'dart:ui';

import 'package:intl/intl.dart';
import 'package:localtourapp/config/appConfig.dart';
import 'package:localtourapp/config/secure_storage_helper.dart';
import 'package:localtourapp/constants/getListApi.dart';
import 'package:localtourapp/models/schedule/destination_model.dart';
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
      [String? userId,
      SortBy? SortBy,
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
      "startDate": startDate != null? startDate.toUtc().toIso8601String() : null,
      "endDate": endDate != null? endDate.toUtc().toIso8601String() : null,
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
        "startDate": startDate != null ? startDate.toUtc().toIso8601String() : null,
        "endDate": endDate != null ? endDate.toUtc().toIso8601String() : null,
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
      "startDate": startDate != null? startDate.toUtc().toIso8601String() : null,
      "endDate": endDate != null? endDate.toUtc().toIso8601String() : null,
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

  Future<bool> CloneSchedule(int scheduleId) async {
    var response = await _apiService.makeRequest('Schedule/cloneSchedule?scheduleId=$scheduleId', "POST");
    if(response.statusCode == 201){
      return true;
    }
    return false;
  }

  Future<List<DestinationModel>> SuggestSchedule(double long, double lat,DateTime startDate,int day) async {
    String? languageCode = await SecureStorageHelper().readValue(AppConfig.language);

    var body = {
      "userLongitude": long,
      "userLatitude": lat,
      "languageCode": languageCode,
      "startDate": startDate.toUtc().toIso8601String(),
      "days": day
    };
    
    var response = await _apiService.makeRequest('Schedule/suggestSchedule', 'POST',body);

    if(response.statusCode == 200){
      final jsonResponse = json.decode(response.body);
      if(jsonResponse['data'] == null){
        return [];
      }
      List<dynamic> jsonData = jsonResponse['data'];

      List<DestinationModel> destinations = jsonData.asMap().entries.map((entry) {
        int index = entry.key + 1;
        Map<String, dynamic> item = entry.value;

        return DestinationModel(
          id: index,
          scheduleId: -1,
          placeId: item['placeId'],
          startDate: DateTime.tryParse(item['startDate']),
          endDate: DateTime.tryParse(item['endDate']),
          detail: item['detail'] ?? "",
          isArrived: item['isArrived'] ?? false,
          placePhotoDisplay: item['placePhotoDisplay'],
          placeName: item['placeName'],
          longitude: item['longitude'].toDouble(),
          latitude: item['latitude'].toDouble()
        );
      }).toList();
      return destinations;
    }
    return [];
  
  }

  Future<bool> SaveSuggestSchedule(DateTime startDate, DateTime endDate, List<DestinationModel> listDestination) async {

    var jsonDestination = listDestination.map((e) => e.toJson(),).toList();

    var body = {
      "scheduleName": "Suggest schedule ${DateFormat('dd-MM-yyyy').format(startDate)} - ${DateFormat('dd-MM-yyyy').format(endDate)}",
      "startDate": startDate.toUtc().toIso8601String(),
      "endDate": endDate.toUtc().toIso8601String(),
      "isPublic": false,
      "destinations": jsonDestination
    };

    var userId = await SecureStorageHelper().readValue(AppConfig.userId);
    
    var response = await _apiService.makeRequest('Schedule/saveSuggestedSchedule?userId=$userId', "POST", body);
    final jsonResponse = json.decode(response.body);

    if(response.statusCode == 200){
      return true;
    }
    return false;
  }

}