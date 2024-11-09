class UserLogin {
  String loginProvider;
  String providerKey;
  String? providerDisplayName;
  String userId;

  UserLogin({
    required this.loginProvider,
    required this.providerKey,
    this.providerDisplayName,
    required this.userId,
  });

  factory UserLogin.fromJson(Map<String, dynamic> json) => UserLogin(
    loginProvider: json['LoginProvider'] as String,
    providerKey: json['ProviderKey'] as String,
    providerDisplayName: json['ProviderDisplayName'] as String?,
    userId: json['UserId'] as String,
  );

  Map<String, dynamic> toJson() => {
    'LoginProvider': loginProvider,
    'ProviderKey': providerKey,
    'ProviderDisplayName': providerDisplayName,
    'UserId': userId,
  };
}
