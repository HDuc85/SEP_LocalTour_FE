import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:localtourapp/config/secure_storage_helper.dart';
import '../config/appConfig.dart';

class ApiService {
  static final storage = SecureStorageHelper();
  Future<bool> tryAutoLogin() async {
    String? refreshToken = await storage.readValue(AppConfig.refreshToken);
    if (refreshToken != null) {
      return await _refreshAccessToken(refreshToken);
    }
    return false;
  }

  Future<http.Response> makeRequest(String endpoint, String method,
      [Map<String, dynamic>? body]) async {
    String? accessToken = await storage.readValue(AppConfig.accessToken);
    final uri = Uri.parse('${AppConfig.apiUrl}$endpoint');
    Map<String, String>? headers = {};
    ;
    //headers['Authorization'] = 'Bearer $accessToken';
    headers['Authorization'] =
        'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJmNmI2MzFiZi1jMzYwLTRjYzgtYmY5Zi02OGZkMjAzODkwOGMiLCJpc3MiOiJodHRwczovL2xvY2FsaG9zdDo3Mjc0IiwiaWF0IjoxNzMxOTEyNTI0LCJhdWQiOlsiaHR0cHM6Ly9sb2NhbGhvc3Q6NzI3NCIsImh0dHBzOi8vbG9jYWxob3N0OjcyNzQiXSwiZXhwIjoxNzMxOTE0OTI0LCJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1laWRlbnRpZmllciI6IjAwMDAwMDAwLTAwMDAtMDAwMC0wMDAwLTAwMDAwMDAwMDAwMCIsImh0dHA6Ly9zY2hlbWFzLnhtbHNvYXAub3JnL3dzLzIwMDUvMDUvaWRlbnRpdHkvY2xhaW1zL21vYmlsZXBob25lIjoiMDEyMzQ1Njc4OSIsImh0dHA6Ly9zY2hlbWFzLnhtbHNvYXAub3JnL3dzLzIwMDUvMDUvaWRlbnRpdHkvY2xhaW1zL2VtYWlsYWRkcmVzcyI6InVzZXJAZXhhbXBsZS5jb20iLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL3JvbGUiOiJWaXNpdG9yIiwibmJmIjoxNzMxOTEyNTI0fQ.hl9GGJUBJlD18TzIQAJkwQfmeoPc6Ubur88--pd86tA';
    headers['Content-Type'] = 'application/json';

    late http.Response response;

    switch (method.toUpperCase()) {
      case 'POST':
        response =
            await http.post(uri, headers: headers, body: json.encode(body));
        break;
      case 'PUT':
        response =
            await http.put(uri, headers: headers, body: json.encode(body));
        break;
      case 'DELETE':
        response =
            await http.delete(uri, headers: headers, body: json.encode(body));
        break;
      default:
        response = await http.get(uri, headers: headers);
    }

    if (response.statusCode == 401) {
      String? refreshToken = await storage.readValue(AppConfig.refreshToken);
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
    await storage.deleteValue(AppConfig.accessToken);
    await storage.deleteValue(AppConfig.refreshToken);

    await storage.saveValue(AppConfig.accessToken, tokens['accessToken']);
    await storage.saveValue(AppConfig.refreshToken, tokens['refreshToken']);
  }

  Future<(bool, bool)> sendFirebaseTokenToBackend(String idToken) async {
    bool firstTime = false;
    bool isSuccess = false;

    try {
      var response = await http.post(
        Uri.parse('${AppConfig.apiUrl}/Authen/verifyTokenFirebase'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({idToken}),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        String firebaseAuthToken = data['firebaseAuthToken'];
        firstTime = data["firstTime"];
        isSuccess = true;
        await storage.deleteValue(AppConfig.accessToken);
        await storage.saveValue(AppConfig.accessToken, firebaseAuthToken);
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
