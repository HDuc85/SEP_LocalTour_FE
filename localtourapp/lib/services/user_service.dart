import 'dart:convert';
import 'package:localtourapp/config/appConfig.dart';
import 'package:localtourapp/config/secure_storage_helper.dart';
import 'package:localtourapp/models/users/password_change_request.dart';
import 'package:localtourapp/models/users/password_change_response.dart';
import 'package:localtourapp/models/users/userProfile.dart';
import 'package:localtourapp/services/api_service.dart';
import 'package:http/http.dart' as http;

import '../models/users/followuser.dart';
import '../models/users/update_user_request.dart';

class UserService {
  final apiService = ApiService();
  static final _storage = SecureStorageHelper();

  Future<Userprofile> getUserProfile(String userId) async {
    final response =
    await apiService.makeRequest('User/getProfile?userId=$userId', 'GET');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Userprofile.fromJson(data);
    } else {
      throw Exception("Không thể tải dữ liệu. Mã lỗi: ${response.statusCode}");
    }
  }

  Future<PasswordChangeResponse> changePassword(
      PasswordChangeRequest request) async {
    final response = await apiService.makeRequest(
        'User/changePassword', 'POST', request.toJson());

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final result = PasswordChangeResponse.fromJson(jsonResponse);

      return result;
    } else {
      throw Exception(
          "Không thể tải dữ liệu. Mã lỗi: ${response.statusCode} Message: ${response.body}");
    }
  }

  Future<Userprofile> sendUserDataRequest(UpdateUserRequest userData) async {
    final url = Uri.parse("${AppConfig.apiUrl}User");

    var request = http.MultipartRequest('PUT', url);

    request.fields.addAll(userData.toMap());

    if (userData.profilePicture != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'ProfilePicture',
          userData.profilePicture!.path,
        ),
      );
    }
    String? accessToken = await _storage.readValue(AppConfig.accessToken);

    Map<String, String> headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'multipart/form-data',
    };
    request.headers.addAll(headers);
    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(responseBody.body);
      return Userprofile.fromJson(data);
    } else {
      throw Exception(responseBody.body);
    }
  }

  Future<bool> FollowOrUnFollowUser(String userId, bool isFollowed) async {
    final response = await apiService.makeRequest(
        'FollowUser?userFollowedId=$userId', isFollowed ? 'DELETE' : 'POST',{});

    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<List<FollowUserModel>> getFollowers(String userId) async {
    final response = await apiService.makeRequest(
        'FollowUser/followed?userId=$userId', 'GET');
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => FollowUserModel.fromJson(e)).toList();
    } else if (response.statusCode == 404) {
      // Return an empty list if there are no followers
      return [];
    } else {
      throw Exception(
          "Could not load followers. Error code: ${response.statusCode}");
    }
  }

  Future<List<FollowUserModel>> getFollowings(String userId) async {
    final response = await apiService.makeRequest(
        'FollowUser/follow?userId=$userId', 'GET');
    print('Followings API Response: ${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => FollowUserModel.fromJson(e)).toList(); // Ensure proper mapping
    } else if (response.statusCode == 404) {
      return []; // No followings
    } else {
      throw Exception("Could not load followings. Error code: ${response.statusCode}");
    }
  }

}

