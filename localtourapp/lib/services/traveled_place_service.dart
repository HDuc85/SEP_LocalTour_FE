
import 'api_service.dart';

class TraveledPlaceService {
  final apiService = ApiService();
  
  Future<bool> AddTraveledPlace(int placeId) async {
    
    var response = await apiService.makeRequest('TraveledPlace?placeId=$placeId', 'POST');

    if(response.statusCode == 200){
      return true;
    }
    return false;
  }
  
}