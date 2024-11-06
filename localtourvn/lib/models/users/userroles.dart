class UserRole {
  String userId;
  String roleId;

  UserRole({
    required this.userId,
    required this.roleId,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) => UserRole(
    userId: json['UserId'] as String,
    roleId: json['RoleId'] as String,
  );

  Map<String, dynamic> toJson() => {
    'UserId': userId,
    'RoleId': roleId,
  };
}
