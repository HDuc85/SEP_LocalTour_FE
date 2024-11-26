import 'dart:convert';
import 'dart:io';

import 'package:localtourapp/config/appConfig.dart';
import 'package:localtourapp/config/secure_storage_helper.dart';
import 'package:localtourapp/models/posts/comment_model.dart';
import 'package:localtourapp/services/api_service.dart';
import 'package:http/http.dart' as http;

import '../constants/getListApi.dart';
import '../models/posts/post_model.dart';

class PostService {
  final ApiService _apiService = ApiService();

Future<List<PostModel>> getListPost(
      String userId,
      [SortBy? SortBy,
      SortOrder? SortOrder,
        int? Page = 1,
        int? Size = 10,]) async {
    String sortByStr = SortBy != null ? sortByToString(SortBy) : '';
    String sortOrderStr = SortOrder != null ? sortOrderToString(SortOrder) : '';
    String? languageCode = await SecureStorageHelper().readValue(AppConfig.language);

    final response = await _apiService
        .makeRequest("Post?UserId=$userId&Page=$Page&Size=$Size&SortBy=$sortByStr&SortOrder=$sortOrderStr&languageCode=$languageCode",
        "GET");
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
        return mapJsonToPostModels(jsonResponse);
    }

     else {
      return [];
    }
    }

  Future<(PostModel, List<CommentModel>)> GetPostDetail(int postId) async{
    final response = await _apiService.makeRequest("Post/getPost/$postId", "GET");

    if(response.statusCode == 200){
      final jsonResponse = json.decode(response.body);
      PostModel postModel = PostModel.fromJson(jsonResponse['data']['data']);
      List<CommentModel> listComment = mapJsonToCommentModels(jsonResponse['comments']);
      return (postModel,listComment);
    }
    else{
      throw Exception("Lỗi khi lấy dữ liệu. Mã lỗi: ${response.statusCode}");

    }
  }

  Future<String> CreatePost(String title, String content,int? placeId,int? scheduleId,List<File> mediaFiles, [bool? public]) async {

    try {
      String url = "${AppConfig.apiUrl}Post/createPost";

      Uri uri = Uri.parse(url);
      final request =  http.MultipartRequest('POST',uri);


      String? asscesstoken = await SecureStorageHelper().readValue(AppConfig.accessToken);

      Map<String, String> headers = {
        'Authorization': 'Bearer $asscesstoken',
        'Content-Type': 'multipart/form-data',
      };

      request.headers.addAll(headers);

      request..fields['Title'] = title;
      request..fields['Content'] = content;
      if(placeId != null){
        request..fields['PlaceId'] = placeId.toString();
      }
      if(scheduleId != null){
        request..fields['ScheduleId'] = scheduleId.toString();
      }
      request..fields['Public'] = public != null?public.toString(): 'false';

      // Add files to the request
      for (var file in mediaFiles) {
        request.files.add(await http.MultipartFile.fromPath(
          'MediaFiles',
          file.path,
        ));
      }


      // Send the request
      var response = await request.send();

      // Handle the response
      if (response.statusCode == 201) {
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

  Future<String> UpdatePost(int postId,String title, String content,int? placeId,int? scheduleId, List<File> mediaFiles ,[ bool? public]) async {

    try {
      String url = "${AppConfig.apiUrl}Post/updatePost/$postId";

      Uri uri = Uri.parse(url);
      final request =  http.MultipartRequest('PUT',uri);


      String? asscesstoken = await SecureStorageHelper().readValue(AppConfig.accessToken);

      Map<String, String> headers = {
        'Authorization': 'Bearer $asscesstoken',
        'Content-Type': 'multipart/form-data',
      };

      request.headers.addAll(headers);

      request..fields['Title'] = title;
      request..fields['Content'] = content;
      if(placeId != null){
        request..fields['PlaceId'] = placeId.toString();
      }
      if(scheduleId != null){
        request..fields['ScheduleId'] = scheduleId.toString();
      }
      request..fields['Public'] = public != null?public.toString(): 'false';

      // Add files to the request
      for (var file in mediaFiles) {
        request.files.add(await http.MultipartFile.fromPath(
          'MediaFiles',
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
  Future<String> UpdatePostStatus(int postId, bool public, String title, String Content) async {

    try {
      String url = "${AppConfig.apiUrl}Post/updatePost/$postId";

      Uri uri = Uri.parse(url);
      final request =  http.MultipartRequest('PUT',uri);


      String? asscesstoken = await SecureStorageHelper().readValue(AppConfig.accessToken);

      Map<String, String> headers = {
        'Authorization': 'Bearer $asscesstoken',
        'Content-Type': 'multipart/form-data',
      };

      request.headers.addAll(headers);

      request..fields['Title'] = title;
      request..fields['Content'] = Content;
      request..fields['Public'] = public.toString();

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

  Future<bool> CreateComment(int postId,int? parentId,String Content) async {
  var body = 
    {
      "postId": postId,
      "parentId": parentId,
      "content": "$Content"
    };
    
    final response = await _apiService.makeRequest("PostComment/createPostComment", "POST",body);

  if(response.statusCode == 201){
    return true;
  }
  else{
    final jsonResponse = json.decode(response.body);
    throw Exception("Lỗi khi lấy dữ liệu. Mã lỗi: ${jsonResponse}");
  }
  }

  Future<bool> LikeComment(int commentId) async {
    final response = await _apiService.makeRequest("PostCommentLike/$commentId/like", "POST");

    if(response.statusCode == 200){
      return true;
    }
    return false;
  }

  Future<bool> LikePost(int postId) async {
    final response = await _apiService.makeRequest("PostLike/toggle/$postId", "POST");

    if(response.statusCode == 200){
      return true;
    }
    return false;
  }

  Future<bool> DeletePost(int postId) async{
    var result = await _apiService.makeRequest('Post/deletePost/$postId', "DELETE");

    if(result.statusCode == 200){
      return true;
    }
    return false;
  }

  Future<bool> DeleteComment(int commentId) async{
    var result = await _apiService.makeRequest('PostComment/deleteComments/$commentId', "DELETE");

    if(result.statusCode == 204){
      return true;
    }
    return false;
  }

}