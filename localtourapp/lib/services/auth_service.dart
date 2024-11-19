import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:localtourapp/services/api_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final apiService = ApiService();

  Future<OAuthCredential?> signInWithGoogle() async {
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

       return credential;
      }
    } catch (e) {
      print('Google Sign-In Error: $e');
    }
    return null;
  }



  Future<void> verifyCode(String verificationId, String smsCode) async {
    final credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);
    await _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
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

  Future<void> sendTokenToLogin(String idToken) async {
    final (isSuccess, firstTimelogin) =
        await apiService.sendFirebaseTokenToBackend(idToken);
    if (isSuccess) {
      if (firstTimelogin) {
      }
      // chuyển tới trang chọn user prefrence
      else {
        // chuyển tới Homepage
      }
    } else {
      // chuyển lại trang login
    }
  }

  Future<void> sendTokenToResetPassword(String idToken) async {
    final (isSuccess, firstTimelogin) =
        await apiService.sendFirebaseTokenToBackend(idToken);
    if (isSuccess) {
      if (firstTimelogin) {
        // chuyển tới trang chọn user prefrence
      } else {
        // chuyển tới Homepage
      }
    } else {
      // chuyển lại trang login
    }
  }
}
