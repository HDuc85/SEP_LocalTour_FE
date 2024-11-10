import 'dart:math';

class User {
  String userId;
  String? userName;
  String? normalizedUserName;
  String? email;
  String? normalizedEmail;
  bool emailConfirmed;
  String? passwordHash;
  String? phoneNumber;
  bool phoneNumberConfirmed;
  String? fullName;
  DateTime? dateOfBirth;
  String? address;
  String? gender;
  String? profilePictureUrl;
  DateTime dateCreated;
  DateTime dateUpdated;
  int reportTimes;

  User({
    required this.userId,
    this.userName,
    this.normalizedUserName,
    this.email,
    this.normalizedEmail,
    required this.emailConfirmed,
    this.passwordHash,
    this.phoneNumber,
    required this.phoneNumberConfirmed,
    this.fullName,
    this.dateOfBirth,
    this.address,
    this.gender,
    this.profilePictureUrl,
    required this.dateCreated,
    required this.dateUpdated,
    required this.reportTimes,
  });

  // Named constructor for a minimal User with default values for non-nullable fields
  User.minimal({
    required this.userId,
    required this.userName,
  })  : emailConfirmed = false,
        phoneNumberConfirmed = false,
        dateCreated = DateTime.now(),
        dateUpdated = DateTime.now(),
        reportTimes = 0;

  // Factory method to create a User object from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      userName: json['userName'],
      normalizedUserName: json['normalizedUserName'],
      email: json['email'],
      normalizedEmail: json['normalizedEmail'],
      emailConfirmed: json['emailConfirmed'],
      passwordHash: json['passwordHash'],
      phoneNumber: json['phoneNumber'],
      phoneNumberConfirmed: json['phoneNumberConfirmed'],
      fullName: json['fullName'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      address: json['address'],
      gender: json['gender'],
      profilePictureUrl: json['profilePictureUrl'],
      dateCreated: DateTime.parse(json['dateCreated']),
      dateUpdated: DateTime.parse(json['dateUpdated']),
      reportTimes: json['reportTimes'],
    );
  }

  // Method to convert a User object to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'normalizedUserName': normalizedUserName,
      'email': email,
      'normalizedEmail': normalizedEmail,
      'emailConfirmed': emailConfirmed,
      'passwordHash': passwordHash,
      'phoneNumber': phoneNumber,
      'phoneNumberConfirmed': phoneNumberConfirmed,
      'fullName': fullName,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'address': address,
      'gender': gender,
      'profilePictureUrl': profilePictureUrl,
      'dateCreated': dateCreated.toIso8601String(),
      'dateUpdated': dateUpdated.toIso8601String(),
      'reportTimes': reportTimes,
    };
  }

}

// Helper function to generate a random GUID
String generateGuid() {
  final random = Random();

  String _fourChars() {
    return random.nextInt(65536).toRadixString(16).padLeft(4, '0');
  }

  return '${_fourChars()}${_fourChars()}-${_fourChars()}-${_fourChars()}-${_fourChars()}-${_fourChars()}${_fourChars()}${_fourChars()}';
}

// Function to generate a list of 10 fake users
List<User> generateFakeUsers(int count) {
  final random = Random();
  List<User> users = [];

  List<String> firstNames = [
    'Alice',
    'Bob',
    'Charlie',
    'Diana',
    'Ethan',
    'Fiona',
    'George',
    'Hannah',
    'Ian',
    'Julia'
  ];

  List<String> lastNames = [
    'Smith',
    'Johnson',
    'Williams',
    'Brown',
    'Jones',
    'Miller',
    'Davis',
    'Garcia',
    'Rodriguez',
    'Wilson'
  ];

  List<String> domains = ['example.com', 'mail.com', 'test.org', 'sample.net'];

  List<String> genders = ['Male', 'Female', 'Other'];

  // Create your specific user
  User myUser = User(
    userId: 'anh-tuan-unique-id-1234',
    userName: 'tuannta2k',
    normalizedUserName: 'TUANNTA2K',
    email: 'nguyenthanhanhtuan123@gmail.com',
    normalizedEmail: 'NGUYENTHANHANHTUAN123@GMAIL.COM',
    emailConfirmed: true,
    passwordHash: null,
    phoneNumber: '+84705543619',
    phoneNumberConfirmed: true,
    fullName: 'Nguyen Thanh Anh Tuan',
    dateOfBirth: DateTime(2000, 04, 24), // Example birthdate
    address: '123 Example Street',
    gender: 'Male',
    profilePictureUrl: 'https://picsum.photos/seed/${random.nextInt(1000)}/600/400/',
    dateCreated: DateTime.now().subtract(Duration(days: 100)),
    dateUpdated: DateTime.now(),
    reportTimes: 0,
  );

  users.add(myUser); // Add your specific user first

  // Now generate the remaining fake users
  for (int i = 1; i < count; i++) {
    String userId = generateGuid();

    // Generate random first and last name
    String firstName = firstNames[random.nextInt(firstNames.length)];
    String lastName = lastNames[random.nextInt(lastNames.length)];
    String fullName = '$firstName $lastName';

    // Generate userName and normalizedUserName
    String userName = '${firstName.toLowerCase()}.${lastName.toLowerCase()}';
    String normalizedUserName = userName.toUpperCase();

    // Generate email and normalizedEmail
    String email = '$userName@${domains[random.nextInt(domains.length)]}';
    String normalizedEmail = email.toUpperCase();

    // Randomly decide if email and phone number are confirmed
    bool emailConfirmed = random.nextBool();
    bool phoneNumberConfirmed = random.nextBool();

    // Generate phone number
    String phoneNumber = '+1${random.nextInt(4294967296) + 1}';

    // Random date of birth between 18 and 60 years ago
    DateTime dateOfBirth = DateTime.now().subtract(
      Duration(days: random.nextInt(15340) + 6570), // Between 18 and 60 years
    );

    // Generate random address
    String address = '${random.nextInt(9999) + 1} ${lastNames[random.nextInt(lastNames.length)]} Street';

    // Random gender
    String gender = genders[random.nextInt(genders.length)];

    // Placeholder profile picture URL
    String profilePictureUrl = 'https://picsum.photos/seed/${random.nextInt(1000)}/600/400/';

    // Date created and updated
    DateTime dateCreated = DateTime.now().subtract(Duration(days: random.nextInt(365)));
    DateTime dateUpdated = dateCreated.add(Duration(days: random.nextInt(30)));

    // Report times
    int reportTimes = random.nextInt(5); // Between 0 and 4

    User user = User(
      userId: userId,
      userName: userName,
      normalizedUserName: normalizedUserName,
      email: email,
      normalizedEmail: normalizedEmail,
      emailConfirmed: emailConfirmed,
      passwordHash: null, // You can set a placeholder or leave it null
      phoneNumber: phoneNumber,
      phoneNumberConfirmed: phoneNumberConfirmed,
      fullName: fullName,
      dateOfBirth: dateOfBirth,
      address: address,
      gender: gender,
      profilePictureUrl: profilePictureUrl,
      dateCreated: dateCreated,
      dateUpdated: dateUpdated,
      reportTimes: reportTimes,
    );

    users.add(user);
  }

  return users;
}

  // Generate 10 fake users
  List<User> fakeUsers = generateFakeUsers(10);

