class PasswordChangeResponse {
  final bool success;
  final String? oldPasswordError;
  final String? newPasswordError;

  PasswordChangeResponse({
    required this.success,
    this.oldPasswordError,
    this.newPasswordError,
  });

  // Chuyển từ JSON sang model
  factory PasswordChangeResponse.fromJson(Map<String, dynamic> json) {
    return PasswordChangeResponse(
      success: json['success'],
      oldPasswordError: json['oldPasswordError'],
      newPasswordError: json['newPasswordError'],
    );
  }
}
