class Userprofile {
  String fullName;
  String userName;
  String userProfileImage;
  String? email;
  DateTime? dateOfBirth;
  String? gender;
  String? address;
  String phoneNumber;
  int totalSchedules;
  int totalPosteds;
  int totalReviews;
  int totalFollowed;
  int totalFollowers;
  bool isFollowed;
  bool isHasPassword;

  Userprofile({
    required this.fullName,
    required this.userName,
    required this.userProfileImage,
    this.email,
    this.dateOfBirth,
    this.gender,
    this.address,
    required this.phoneNumber,
    required this.totalSchedules,
    required this.totalPosteds,
    required this.totalReviews,
    required this.totalFollowed,
    required this.totalFollowers,
    required this.isFollowed,
    required this.isHasPassword,
  });

  factory Userprofile.fromJson(Map<String, dynamic> json) {
    return Userprofile(
      fullName: json['fullName'] ?? 'Unknown Full Name',
      userName: json['userName'] ?? 'Unknown User',
      userProfileImage: json['userProfileImage'] ?? '',
      email: json['email'],
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth']) : null,
      gender: json['gender'],
      address: json['address'],
      phoneNumber: json['phoneNumber'] ?? '',
      totalSchedules: json['totalSchedules'] ?? 0,
      totalPosteds: json['totalPosteds'] ?? 0,
      totalReviews: json['totalReviews'] ?? 0,
      totalFollowed: json['totalFollowed'] ?? 0, // Default to 0 if null
      totalFollowers: json['totalFollowers'] ?? 0, // Default to 0 if null
      isFollowed: json['isFollowed'] ?? false,
      isHasPassword: json['isHasPassword'] ?? false,
    );
  }
}

