import 'dart:convert';
import 'api_service.dart';
import '../models/HomePage/banner.dart';

class BannerService {
  final apiService = ApiService();

  Future<List<BannerModel>> getListBanner() async {
    final response = await apiService.makeRequest("Banner/GetBanner", "GET");

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['bannerUrls'] == null || jsonResponse['bannerUrls'].isEmpty) {
        return [];
      }
      return BannerModel.fromJsonList(jsonResponse['bannerUrls']);
    } else {
      throw Exception("Error fetching banners. Status code: ${response.statusCode}");
    }
  }
}
