class VerifyFirebaseResponse {
  final String firebaseAuthToken;
  final String expiredDateToken;
  final bool firstTime;
  final String userId;
  final String refreshToken;

  VerifyFirebaseResponse({
    required this.firebaseAuthToken,
    required this.expiredDateToken,
    required this.firstTime,
    required this.userId,
    required this.refreshToken
  });

  factory VerifyFirebaseResponse.fromJson(Map<String, dynamic> json) {
    return VerifyFirebaseResponse(
      firebaseAuthToken: json['firebaseAuthToken'],
      expiredDateToken: json['expiredDateToken'],
      firstTime: json['firstTime'],
      userId: json['userId'],
      refreshToken: json['refreshToken']
    );
  }


}