import 'dart:convert';

import '../config/appConfig.dart';
import '../config/secure_storage_helper.dart';
import '../models/places/traveled_place_model.dart';
import 'api_service.dart';

class TraveledPlaceService {
  final apiService = ApiService();
  final storage = SecureStorageHelper();

  Future<List<TraveledPlaceModel>> getAllTraveledPlace() async {
    try {
      final languageCode = await storage.readValue(AppConfig.language);
      final response = await apiService.makeRequest(
          'TraveledPlace/getAll?languageCode=$languageCode', 'GET');
      print('API Response: ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        return responseData
            .map((data) => TraveledPlaceModel.fromJson(data))
            .toList();
      } else {
        throw Exception(
            'Failed to fetch traveled places: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in TraveledPlaceService.getAllTraveledPlace: $e');
      return [];
    }
  }


  /// Adds a traveled place by its ID.
  Future<bool> addTraveledPlace(int placeId) async {
    try {
      final response = await apiService.makeRequest(
          'TraveledPlace?placeId=$placeId', 'POST');
      if (response.statusCode == 200) {
        return true;
      } else {
        print(
            'Failed to add traveled place. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error in TraveledPlaceService.addTraveledPlace: $e');
      return false;
    }
  }
}
