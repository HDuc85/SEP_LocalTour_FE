class UserClaim {
  int id;
  String userId;
  String? claimType;
  String? claimValue;

  UserClaim({
    required this.id,
    required this.userId,
    this.claimType,
    this.claimValue,
  });

  factory UserClaim.fromJson(Map<String, dynamic> json) => UserClaim(
    id: json['Id'] as int,
    userId: json['UserId'] as String,
    claimType: json['ClaimType'] as String?,
    claimValue: json['ClaimValue'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'Id': id,
    'UserId': userId,
    'ClaimType': claimType,
    'ClaimValue': claimValue,
  };
}
