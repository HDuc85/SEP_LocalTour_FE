import 'dart:convert';
import 'dart:io';

import 'package:localtourapp/config/appConfig.dart';
import 'package:localtourapp/config/secure_storage_helper.dart';
import 'package:localtourapp/models/feedback/feedback_model.dart';
import 'package:http/http.dart' as http;
import '../constants/getListApi.dart';
import 'api_service.dart';

class ReviewService {
  final apiService = ApiService();

  Future<(List<FeedBackModel>,int)> getFeedback(
        [int? placeId,
        String? userId,
        SortBy? SortBy,
        SortOrder? SortOrder,
        int? Page = 1,
        int? Size = 10,]) async {
    String sortByStr = SortBy != null ? sortByToString(SortBy) : '';
    String sortOrderStr = SortOrder != null ? sortOrderToString(SortOrder) : '';
    String? language = await SecureStorageHelper().readValue(AppConfig.language);

    final response = await apiService
        .makeRequest("PlaceFeedback/getAllFeedback?PlaceId=${placeId ?? ''}&UserId=${userId ?? ''}&LanguageCode=$language&Page=$Page&Size=$Size&SortBy=$sortByStr&SortOrder=$sortOrderStr","GET");
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['items'] == null || jsonResponse['items'].isEmpty) {
        List<FeedBackModel> temp = [];
       return (temp, 0);
      }
      int totalFeedback = (jsonResponse['totalCount'] ?? 0).toInt();
      return (jsonToFeedbackList(jsonResponse['items']), totalFeedback);
    } else {
      throw Exception("Lỗi khi lấy dữ liệu. Mã lỗi: ${response.statusCode}");
    }
  }

  Future<bool> LikeFeedback(int placeId, int feedbackId) async{
    final response = await apiService.makeRequest('PlaceFeedbackHelpful/likeOrUnlike?placeid=$placeId&placefeedbackid=$feedbackId', "POST");
    if (response.statusCode == 200) {
      return true;
    } else  {

      return false;
    }
  }

  Future<bool> DeleteFeedback(int placeId,int feedbackId) async{
    final response = await apiService.makeRequest('PlaceFeedback/delete?placeid=$placeId&feedbackid=$feedbackId', "DELETE");
    if (response.statusCode == 200) {
      return true;
    } else  {

      return false;
    }
  }

  Future<String> CreateFeedback(int placeId,int rating, String content, List<File> listMedia) async {

    try {
      String url = "${AppConfig.apiUrl}PlaceFeedback/create";

      Uri uri = Uri.parse(url);
      final request =  http.MultipartRequest('POST',uri);


      String? asscesstoken = await SecureStorageHelper().readValue(AppConfig.accessToken);

      Map<String, String> headers = {
        'Authorization': 'Bearer $asscesstoken',
        'Content-Type': 'multipart/form-data',
      };

      request.headers.addAll(headers);

      request..fields['placeid'] = placeId.toString();
      request..fields['Rating'] = rating.toString();
      request..fields['Content'] = content;

    // Add files to the request
      for (var file in listMedia) {
        request.files.add(await http.MultipartFile.fromPath(
          'PlaceFeedbackMedia',
          file.path,
        ));
      }


      // Send the request
      var response = await request.send();

      // Handle the response
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        return 'Success';
      } else {
        var responseBody = await response.stream.bytesToString();
        return responseBody;
      }
    } catch (e) {
      return '$e';
    }

  }


  Future<String> UpdateFeedback(int placeId,int rating,int feedbackId, String content, List<File> listMedia) async {

    try {
      String url = "${AppConfig.apiUrl}PlaceFeedback/update?feedbackid=$feedbackId&placeid=$placeId&Rating=$rating&Content=$content";

      Uri uri = Uri.parse(url);
      final request =  http.MultipartRequest('PUT',uri);


      String? asscesstoken = await SecureStorageHelper().readValue(AppConfig.accessToken);

      Map<String, String> headers = {
        'Authorization': 'Bearer $asscesstoken',
        'Content-Type': 'multipart/form-data',
      };

      request.headers.addAll(headers);

      // Add files to the request
      for (var file in listMedia) {
        request.files.add(await http.MultipartFile.fromPath(
          'PlaceFeedbackMedia',
          file.path,
        ));
      }


      // Send the request
      var response = await request.send();

      // Handle the response
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        return 'Success';
      } else {
        var responseBody = await response.stream.bytesToString();
        return responseBody;
      }
    } catch (e) {
      return '$e';
    }

  }


}