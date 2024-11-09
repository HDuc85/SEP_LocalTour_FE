class UserToken {
  String userId;
  String loginProvider;
  String name;
  String? value;

  UserToken({
    required this.userId,
    required this.loginProvider,
    required this.name,
    this.value,
  });

  factory UserToken.fromJson(Map<String, dynamic> json) => UserToken(
    userId: json['UserId'] as String,
    loginProvider: json['LoginProvider'] as String,
    name: json['Name'] as String,
    value: json['Value'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'UserId': userId,
    'LoginProvider': loginProvider,
    'Name': name,
    'Value': value,
  };
}
