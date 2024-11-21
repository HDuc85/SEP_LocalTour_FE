import 'dart:convert';
import 'dart:ffi';

import 'package:localtourapp/config/appConfig.dart';
import 'package:localtourapp/config/secure_storage_helper.dart';
import 'package:localtourapp/constants/getListApi.dart';
import 'package:localtourapp/generated/intl/messages_en.dart';
import 'package:localtourapp/models/HomePage/placeCard.dart';
import 'package:localtourapp/services/api_service.dart';

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
    if (CurrentLatitude == null || CurrentLongitude == null) {
      return new List.empty();
    }
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
        throw Exception("Không có dữ liệu nào được tìm thấy.");
      }
      return mapJsonToPlaceCardModels(jsonResponse['items']);
    } else {
      throw Exception("Lỗi khi lấy dữ liệu. Mã lỗi: ${response.statusCode}");
    }
  }
}
