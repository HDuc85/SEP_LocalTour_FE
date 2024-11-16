import 'dart:convert';

import 'package:localtourapp/config/appConfig.dart';
import 'package:localtourapp/config/secure_storage_helper.dart';
import 'package:localtourapp/models/markPlace/markPlaceModel.dart';
import 'package:localtourapp/services/api_service.dart';

class MarkplaceService {
  final apiService = ApiService();
  static final _storage = SecureStorageHelper();

  Future<List<markPlaceModel>> getAllMarkPlace() async {
    final languageCode = await _storage.readValue(AppConfig.language);
    final response = await apiService.makeRequest(
        'MarkPlace?languageCode=$languageCode', 'GET');

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      return responseData.map((data) => markPlaceModel.fromJson(data)).toList();
    } else {
      throw Exception("Không thể tải dữ liệu. Mã lỗi: ${response.statusCode}");
    }
  }
}
