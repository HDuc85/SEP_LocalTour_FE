import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {
  @override
  Future<UserCredential> signInWithCredential(AuthCredential credential) async {
    return Future.value(MockUserCredential());
  }

  @override
  Future<void> verifyPhoneNumber({
    String? phoneNumber,
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
    // Simulate a successful verification for testing
    final fakeVerificationId = "test-verification-id";

    // Simulate code being sent successfully
    codeSent(fakeVerificationId, 1);

    // Directly call verificationCompleted for simplicity in testing
    final mockCredential = PhoneAuthProvider.credential(
      verificationId: fakeVerificationId,
      smsCode: '123456',
    );
    verificationCompleted(mockCredential);
  }
}

class MockUserCredential extends Mock implements UserCredential {
  @override
  User get user => MockUser();
}

class MockUser extends Mock implements User {
  @override
  String get uid => 'anh-tuan-unique-id-1234';

  @override
  String get phoneNumber => '+84705543619';
}
