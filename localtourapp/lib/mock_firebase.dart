// mock_firebase.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';

// Mock classes
class MockFirebaseAuth extends Mock implements FirebaseAuth {
  String? _expectedSmsCode;
  String? _verificationId;

  @override
  Future<void> verifyPhoneNumber({
    String? phoneNumber, // Make phoneNumber nullable to match FirebaseAuth
    required PhoneVerificationCompleted verificationCompleted,
    required PhoneVerificationFailed verificationFailed,
    required PhoneCodeSent codeSent,
    required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
    Duration timeout = const Duration(seconds: 30),
    int? forceResendingToken,
    String? autoRetrievedSmsCodeForTesting,
    PhoneMultiFactorInfo? multiFactorInfo,
    MultiFactorSession? multiFactorSession,
  }) async {
    // Simulate phone number validation
    if (phoneNumber == null || !validatePhoneNumber(phoneNumber)) {
      verificationFailed(FirebaseAuthException(
        code: 'invalid-phone-number',
        message: 'The phone number entered is invalid!',
      ));
      return;
    }

    // Simulate sending SMS code
    _verificationId = "test-verification-id";
    _expectedSmsCode = "123456"; // Preset SMS code for testing

    // Call codeSent callback
    codeSent(_verificationId!, 1);

    // Do NOT call verificationCompleted to ensure SMS code step is shown
  }

  @override
  Future<UserCredential> signInWithCredential(AuthCredential credential) async {
    if (credential is PhoneAuthCredential) {
      if (credential.smsCode == _expectedSmsCode && credential.verificationId == _verificationId) {
        return MockUserCredential();
      } else {
        throw FirebaseAuthException(
          code: 'invalid-verification-code',
          message: 'The SMS code entered is invalid!',
        );
      }
    }
    // Handle other credential types if necessary
    throw FirebaseAuthException(
      code: 'invalid-credential',
      message: 'The credential is invalid!',
    );
  }

  bool validatePhoneNumber(String phone) {
    final phoneRegExp = RegExp(r'^\+?\d{10}$'); // Adjust regex as needed
    return phoneRegExp.hasMatch(phone);
  }

  @override
  User? get currentUser => MockUser();

// Implement other necessary overrides if needed
}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {
  @override
  String get uid => 'anh-tuan-unique-id-1234';

  @override
  String? get phoneNumber => '+84705543619';

// Implement other necessary getters and methods as needed
}
