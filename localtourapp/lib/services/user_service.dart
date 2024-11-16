import 'dart:convert';
import 'package:localtourapp/config/secure_storage_helper.dart';
import 'package:localtourapp/models/users/userProfile.dart';
import 'package:localtourapp/services/api_service.dart';

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
}
