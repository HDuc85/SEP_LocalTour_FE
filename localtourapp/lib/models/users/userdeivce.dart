class UserDevice {
  int id;
  String userId;
  String deviceId;

  UserDevice({
    required this.id,
    required this.userId,
    required this.deviceId,
  });

  factory UserDevice.fromJson(Map<String, dynamic> json) => UserDevice(
    id: json['Id'] as int,
    userId: json['UserId'] as String,
    deviceId: json['DeviceId'] as String,
  );

  Map<String, dynamic> toJson() => {
    'Id': id,
    'UserId': userId,
    'DeviceId': deviceId,
  };
}
