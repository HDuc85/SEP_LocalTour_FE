import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:localtourapp/services/api_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final apiService = ApiService();

  Future<User?> signInWithGoogle() async {
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

        final userCredential = await _auth.signInWithCredential(credential);
        return userCredential.user;
      }
    } catch (e) {
      print('Google Sign-In Error: $e');
    }
    return null;
  }

  Future<User?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final OAuthCredential credential =
            FacebookAuthProvider.credential(result.accessToken!.tokenString);
        final userCredential = await _auth.signInWithCredential(credential);
        return userCredential.user;
      }
    } catch (e) {
      print('Facebook Sign-In Error: $e');
    }
    return null;
  }

  Future<void> signInWithPhone(
      String phone, Function(String) onCodeSent) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        print('Phone verification failed: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
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
