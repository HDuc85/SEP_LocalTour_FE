import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:localtourapp/config/appConfig.dart';
import 'package:localtourapp/services/api_service.dart';

import '../config/secure_storage_helper.dart';
import '../models/auth/verify_firebase_response.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final apiService = ApiService();
  final storage = SecureStorageHelper();

  Future<bool> signInWithPassword(String emailOrPhone, String password) async {
    final body = {
      "phoneNumber": emailOrPhone,
      "password": password
    };

    late http.Response response;
    final uri = Uri.parse('${AppConfig.apiUrl}Authen/login');
    Map<String, String>? headers = {};

    headers['Content-Type'] = 'application/json';

    response = await http.post(uri, headers: headers, body: json.encode(body));

    if(response.statusCode == 200){
      final data = jsonDecode(response.body);
      await apiService.storeTokens(data);
      return true;
    }
    if(response.statusCode == 401){
      throw Exception(jsonDecode(response.body));
    }
    return false;
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

       await _auth.signInWithCredential(credential);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Google Sign-In Error: $e');
      }
    }
    return;
  }

  Future<VerifyFirebaseResponse> sendUserIdToBackend() async {
    try {
      
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User chưa đăng nhập.");
      }
      final requestBody = {
        "token": user.uid,
      };

      final response = await apiService.makeRequest("Authen/verifyTokenFirebase", "POST",requestBody);

      if (response.statusCode == 200) {
        // Parse response body
        final jsonData = jsonDecode(response.body);
        final result = VerifyFirebaseResponse.fromJson(jsonData);

        storage.saveValue(AppConfig.accessToken, result.firebaseAuthToken);
        storage.saveValue(AppConfig.isLogin, 'true');
        storage.saveBoolValue(AppConfig.isFirstLogin, result.firstTime);
        storage.saveValue(AppConfig.userId, result.userId);
        storage.saveValue(AppConfig.refreshToken, result.refreshToken);
        return result;


      } else {
        throw("Lỗi: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      throw("Lỗi khi gửi userId: $e");
    }
  }

  Future<void> verifyCode(String verificationId, String smsCode) async {
    final credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);
    await _auth.signInWithCredential(credential);
    
  }

  Future<void> signOut() async {
      storage.deleteValue(AppConfig.isLogin);
      storage.deleteValue(AppConfig.userId);
      storage.deleteValue(AppConfig.accessToken);
      storage.deleteValue(AppConfig.refreshToken);

    await _auth.signOut();
  }

  Future<String?> getIdToken() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        return await user.getIdToken();
      }
    } catch (e) {
      signOut();
    }
    return null;
  }

  Future<bool> setPassword(String password, String confirmPassword) async{
    final body = {
      "password": password,
      "confirmPassword": confirmPassword,
    };
    try{
      final response = await apiService.makeRequest("User/setPassword", "POST",body);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {

        await storage.saveValue(AppConfig.accessToken, responseData['accessToken']);
        await storage.saveValue(AppConfig.refreshToken, responseData['refreshToken']);
        await storage.saveValue(AppConfig.userId, responseData['userId']);
        await storage.saveValue(AppConfig.isLogin, 'true');
       return true;
      } else {
        throw Exception(responseData);
      }
    }catch (e) {
      return false;
    }
  }

  Future<String> addEmailGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await _auth.signInWithCredential(credential);

        User? user = FirebaseAuth.instance.currentUser;
        if(user != null){
          var body = { "token" : user.uid};
          var response = await apiService.makeRequest("User/UpdatePhoneOrEmail", 'PUT',body);

          if(response.statusCode == 200){
            return response.body;
          }
          return response.body;

        }

      }
    } catch (e) {
      if (kDebugMode) {
        print('Google Sign-In Error: $e');
      }
    }
    return '';
  }

  Future<String> addPhoneNumber() async {
    try {

        User? user = FirebaseAuth.instance.currentUser;
        if(user != null){
          var body = { "token" : user.uid};
          var response = await apiService.makeRequest("User/UpdatePhoneOrEmail", 'PUT',body);

          if(response.statusCode == 200){
            return response.body;
          }
          return response.body;

        }


    } catch (e) {
      if (kDebugMode) {
        print('Google Sign-In Error: $e');
      }
    }
    return '';
  }

}
