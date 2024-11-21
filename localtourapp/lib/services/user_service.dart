import 'dart:convert';
import 'package:localtourapp/config/appConfig.dart';
import 'package:localtourapp/config/secure_storage_helper.dart';
import 'package:localtourapp/models/users/password_change_request.dart';
import 'package:localtourapp/models/users/password_change_response.dart';
import 'package:localtourapp/models/users/userProfile.dart';
import 'package:localtourapp/services/api_service.dart';
import 'package:http/http.dart' as http;

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

    request.headers['Authorization'] = 'Bearer $accessToken';
    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(responseBody.body);
      return Userprofile.fromJson(data);
    } else {
      throw Exception(responseBody.body);
    }
  }
}
