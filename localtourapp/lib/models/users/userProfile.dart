class Userprofile {
  String fullName;
  String userName;
  String userProfileImage;
  String email;
  String gender;
  String address;
  String phoneNumber;
  DateTime? dateOfBirth;
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
    required this.email,
    required this.gender,
    required this.address,
    required this.phoneNumber,
    required this.dateOfBirth,
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
        fullName: json['fullName'] ?? '',
        userName: json['userName'] ?? '',
        userProfileImage: json['userProfileImage'] ?? '',
        email: json['email'] ?? '',
        gender: json['gender'] ?? '',
        address: json['address'] ?? '',
        phoneNumber: json['phoneNumber'] ?? '',
        dateOfBirth: json['dateOfBirth'] != null
            ? DateTime.tryParse(json['dateOfBirth'])
            : null,
        totalSchedules: json['totalSchedules'] ?? 0,
        totalPosteds: json['totalPosteds'] ?? 0,
        totalReviews: json['totalReviews'] ?? 0,
        totalFollowed: json['totalFollowed'] ?? 0,
        totalFollowers: json['totalFollowers'] ?? 0,
        isFollowed: json['isFollowed'] ?? false,
        isHasPassword: json['isHasPassword'] ?? true);
  }
}
