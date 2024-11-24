import 'dart:convert';

import 'package:localtourapp/models/places/place_detail_model.dart';

import '../config/secure_storage_helper.dart';
import '../constants/getListApi.dart';
import '../models/HomePage/placeCard.dart';
import '../services/api_service.dart';
import '../config/appConfig.dart';

class PlaceService {
  final apiService = ApiService();

  Future<List<PlaceCardModel>> getListPlace(
      double CurrentLatitude, double CurrentLongitude,
      SortBy? SortBy,
      SortOrder? SortOrder,
      [
      List<int>? tagIds = const <int>[],
      String? SearchTerm = '',
      int? Page = 1,
      int? Size = 10,]) async {

    String sortByStr = SortBy != null ? sortByToString(SortBy) : '';
    String sortOrderStr = SortOrder != null ? sortOrderToString(SortOrder) : '';
    String? languageCode =
        await SecureStorageHelper().readValue(AppConfig.language);
    String temp = "";
    if(tagIds!.length > 0){
      for(int i = 0; i< tagIds.length;i++){
        temp += "&Tags=${tagIds[i]}";
      }
    }
    final response = await apiService
        .makeRequest("Place/getAll?LanguageCode=$languageCode&CurrentLatitude=$CurrentLatitude&CurrentLongitude=$CurrentLongitude&Page=$Page&Size=$Size&SearchTerm=$SearchTerm&SortBy=$sortByStr&SortOrder=$sortOrderStr"+temp,
        "GET");
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['items'] == null || jsonResponse['items'].isEmpty) {
       return [];
      }
      return mapJsonToPlaceCardModels(jsonResponse['items']);
    } else {
      throw Exception("Lỗi khi lấy dữ liệu. Mã lỗi: ${response.statusCode}");
    }
  }
  
  Future<PlaceDetailModel> GetPlaceDetail(int placeId) async{
    String? languageCode = await SecureStorageHelper().readValue(AppConfig.language);
    final response = await apiService.makeRequest("Place/getPlaceById?languageCode=$languageCode&placeid=$placeId", "GET");

    if(response.statusCode == 200){
      final jsonResponse = json.decode(response.body);
      return PlaceDetailModel.fromJson(jsonResponse);
    }
    else{
      throw Exception("Lỗi khi lấy dữ liệu. Mã lỗi: ${response.statusCode}");

    }
  }
}
