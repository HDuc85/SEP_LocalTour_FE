class Role {
  String id;
  String? name;
  String? normalizedName;
  String? concurrencyStamp;

  Role({
    required this.id,
    this.name,
    this.normalizedName,
    this.concurrencyStamp,
  });

  factory Role.fromJson(Map<String, dynamic> json) => Role(
    id: json['Id'] as String,
    name: json['Name'] as String?,
    normalizedName: json['NormalizedName'] as String?,
    concurrencyStamp: json['ConcurrencyStamp'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'Id': id,
    'Name': name,
    'NormalizedName': normalizedName,
    'ConcurrencyStamp': concurrencyStamp,
  };
}
