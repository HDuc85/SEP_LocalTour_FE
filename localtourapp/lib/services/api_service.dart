import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:localtourapp/config/secure_storage_helper.dart';
import '../config/appConfig.dart';

class ApiService {
  static final storage = SecureStorageHelper();
  Future<bool> tryAutoLogin() async {
    String? refreshToken = await storage.readToken(AppConfig.refreshToken);
    if (refreshToken != null) {
      return await _refreshAccessToken(refreshToken);
    }
    return false;
  }

  Future<http.Response> makeRequest(
      String endpoint, String method, String body) async {
    String? accessToken = await storage.readToken(AppConfig.accessToken);
    final uri = Uri.parse('${AppConfig.apiUrl}$endpoint');
    Map<String, String>? headers = {};
    ;
    headers['Authorization'] = 'Bearer $accessToken';

    late http.Response response;

    switch (method.toUpperCase()) {
      case 'POST':
        response = await http.post(uri, headers: headers, body: body);
        break;
      case 'PUT':
        response = await http.put(uri, headers: headers, body: body);
        break;
      case 'DELETE':
        response = await http.delete(uri, headers: headers, body: body);
        break;
      default:
        response = await http.get(uri, headers: headers);
    }

    if (response.statusCode == 401) {
      String? refreshToken = await storage.readToken(AppConfig.refreshToken);
      bool refreshed = await _refreshAccessToken(refreshToken);
      if (refreshed) {
        return makeRequest(endpoint, method, body);
      } else {
        _returnToLoginPage();
      }
    }
    return response;
  }

  Future<bool> _refreshAccessToken(String? refreshToken) async {
    if (refreshToken == null) return false;

    var response = await http.post(
      Uri.parse('${AppConfig.apiUrl}/Authen/refreshToken'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _storeTokens(data);
      return true;
    }
    return false;
  }

  Future<void> _storeTokens(Map<String, dynamic> tokens) async {
    await storage.clearAll();
    await storage.saveToken(AppConfig.accessToken, tokens['accessToken']);
    await storage.saveToken(AppConfig.refreshToken, tokens['refreshToken']);
  }

  Future<(bool, bool)> sendFirebaseTokenToBackend(String idToken) async {
    bool firstTime = false;
    bool isSuccess = false;
    try {
      final response =
          await makeRequest("Authen/verifyTokenFirebase", "POST", idToken);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        String firebaseAuthToken = data['firebaseAuthToken'];
        firstTime = data["firstTime"];
        isSuccess = true;
        await storage.deleteToken(AppConfig.accessToken);
        await storage.saveToken(AppConfig.accessToken, firebaseAuthToken);
        return (isSuccess, firstTime);
      } else {
        return (isSuccess, firstTime);
      }
    } catch (e) {
      print("Error sending token to backend: $e");
      return (isSuccess, firstTime);
    }
  }

  void _returnToLoginPage() {}
}
