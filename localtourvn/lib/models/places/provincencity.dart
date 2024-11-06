class ProvinceNCity {
  int id;
  String name;

  ProvinceNCity({
    required this.id,
    required this.name,
  });

  factory ProvinceNCity.fromJson(Map<String, dynamic> json) => ProvinceNCity(
    id: json['Id'] as int,
    name: json['Name'] as String,
  );

  Map<String, dynamic> toJson() => {
    'Id': id,
    'Name': name,
  };
}
