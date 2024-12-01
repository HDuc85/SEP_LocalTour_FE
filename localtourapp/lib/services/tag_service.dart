
import 'dart:convert';

import 'package:localtourapp/models/Tag/tag_model.dart';
import 'package:localtourapp/services/api_service.dart';

import '../config/appConfig.dart';
import '../config/secure_storage_helper.dart';

class TagService {
  final apiService = ApiService();
  static final _storage = SecureStorageHelper();

  Future<List<TagModel>> getAllTag([int? page = 1, int? size = 30]) async {
    final response = await apiService.makeRequest('Tag/getAll?Page=${page??''}&Size=${size??''}', 'GET');

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['items'] == null || jsonResponse['items'].isEmpty) {
        throw Exception("Không có dữ liệu nào được tìm thấy.");
      }
      return mapJsonToTags(jsonResponse['items']);
    } else {
      throw Exception("Không thể tải dữ liệu. Mã lỗi: ${response.statusCode}");
    }
  }

  Future<List<TagModel>> getTopTagPlace([int? size]) async {
    final response = await apiService.makeRequest('Tag/TagsTopPlace', 'GET');

    List<TagModel> result = [];
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

        var x = mapJsonToTags(jsonResponse);
      if(size != null){
        return x.sublist(0,size);
      }
      return x.sublist(0,5);
    }

    return result;
  }


  Future<List<TagModel>> getTagInPlace(int placeId) async {
    final response = await apiService.makeRequest('Place/getTagsInPlace?placeId=$placeId', 'GET');

    List<TagModel> result = [];
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return mapJsonToTags(jsonResponse);
    }

    return result;
  }

  Future<List<TagModel>> getUserTag() async{
    final response = await apiService.makeRequest('UserPreferenceTags', 'GET');
    List<TagModel> result = [];
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return mapJsonToTags(jsonResponse);
    }

    return result;

  }



  Future<bool> addTagsPreferencs(List<int> tagIds) async{

    final Map<String, dynamic> body = {
      "tagIds": tagIds
    };
    final response = await apiService.makeRequest('UserPreferenceTags', 'POST',body);
    if(response.statusCode == 201){
        return true;
    }
    else{
      return false;
    }
  }

  Future<bool> UpdateTagsPreferencs(List<int> tagIds) async{

    final Map<String, dynamic> body = {
      "tagIds": tagIds
    };
    var userId = await SecureStorageHelper().readValue(AppConfig.userId);

    final response = await apiService.makeRequest('UserPreferenceTags/$userId', 'PUT',body);
    if(response.statusCode == 200){
      return true;
    }
    else{
      return false;
    }
  }
}

