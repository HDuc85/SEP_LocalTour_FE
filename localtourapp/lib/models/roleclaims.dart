class RoleClaim {
  int id;
  String roleId;
  String? claimType;
  String? claimValue;

  RoleClaim({
    required this.id,
    required this.roleId,
    this.claimType,
    this.claimValue,
  });

  factory RoleClaim.fromJson(Map<String, dynamic> json) => RoleClaim(
    id: json['Id'] as int,
    roleId: json['RoleId'] as String,
    claimType: json['ClaimType'] as String?,
    claimValue: json['ClaimValue'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'Id': id,
    'RoleId': roleId,
    'ClaimType': claimType,
    'ClaimValue': claimValue,
  };
}
