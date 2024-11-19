class PasswordChangeRequest {
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;

  PasswordChangeRequest({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  // Chuyển đổi đối tượng thành JSON
  Map<String, dynamic> toJson() {
    return {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
  }
}
