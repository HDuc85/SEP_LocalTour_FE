class DistrictNCity {
  int id;
  int provinceNCityId;
  String name;

  DistrictNCity({
    required this.id,
    required this.provinceNCityId,
    required this.name,
  });

  factory DistrictNCity.fromJson(Map<String, dynamic> json) => DistrictNCity(
    id: json['Id'] as int,
    provinceNCityId: json['ProvinceNCityId'] as int,
    name: json['Name'] as String,
  );

  Map<String, dynamic> toJson() => {
    'Id': id,
    'ProvinceNCityId': provinceNCityId,
    'Name': name,
  };
}
