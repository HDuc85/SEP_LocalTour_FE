import 'dart:io';

class UpdateUserRequest {
  final String? username;
  final String? fullName;
  final DateTime? dateOfBirth;
  final String? address;
  final String? gender;
  final File? profilePicture;

  UpdateUserRequest({
    this.username,
    this.fullName,
    this.dateOfBirth,
    this.address,
    this.gender,
    this.profilePicture,
  });

  Map<String, String> toMap() {
    return {
      'Username': username ?? '',
      'FullName': fullName ?? '',
      'DateOfBirth': dateOfBirth?.toIso8601String() ?? '',
      'Address': address ?? '',
      'Gender': gender ?? '',
    };
  }
}