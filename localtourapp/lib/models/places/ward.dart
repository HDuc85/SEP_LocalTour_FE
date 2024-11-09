class Ward {
  int id;
  int districtNCityId;
  String wardName;

  Ward({
    required this.id,
    required this.districtNCityId,
    required this.wardName,
  });

  factory Ward.fromJson(Map<String, dynamic> json) => Ward(
    id: json['Id'] as int,
    districtNCityId: json['DistrictNCityId'] as int,
    wardName: json['WardName'] as String,
  );

  Map<String, dynamic> toJson() => {
    'Id': id,
    'DistrictNCityId': districtNCityId,
    'WardName': wardName,
  };
}
