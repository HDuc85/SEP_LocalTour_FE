import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localtourapp/config/appConfig.dart';
import 'package:localtourapp/config/secure_storage_helper.dart';
import 'package:localtourapp/models/users/userProfile.dart';
import 'package:localtourapp/services/auth_service.dart';
import 'package:localtourapp/services/user_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../base/weather_icon_button.dart';
import '../../models/users/followuser.dart';
import '../../models/users/update_user_request.dart';
import '../../models/users/users.dart';
import 'faq.dart';
import 'followlistpage.dart';
import 'personal_infomation.dart';
import 'setting_page.dart';
import 'user_preference.dart';
import 'view_profile/view_profile.dart';


class AccountPage extends StatefulWidget {
  final String userId;

  const AccountPage({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String _languageCode = '';
  bool isLoadingProfile = false;
  bool isFollowLoading = false;
  final AuthService _authService = AuthService();
  late final UserService _userService = UserService();
  final storage = SecureStorageHelper();
  List<FollowUserModel> followers = [];
  List<FollowUserModel> followings = [];
  late Userprofile userprofile = Userprofile(
      fullName: "Unknown Full Name",
      userName: "Unknown",
      userProfileImage: "",
      email: "Unknown Email",
      gender: '',
      address: "Unknown Address",
      phoneNumber: "zero Number",
      dateOfBirth: DateTime(2000, 1, 1),
      totalSchedules: 0,
      totalPosteds: 0,
      totalReviews: 0,
      totalFollowed: 0,
      totalFollowers: 0,
      isFollowed: true,
      isHasPassword: true);
  late User displayedUser;
  String myUserId = '';
  late bool isLogin = false;
  bool isCurrentUser = false;
  // Existing ScrollController declaration
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  @override
  void initState() {
    readUserId();
    super.initState();
  }

  Future<void> readUserId() async {
    try {
      var languageCode = await SecureStorageHelper().readValue(AppConfig.language);
      String? userIdStorage = await storage.readValue(AppConfig.userId);
      String? isLoginStorage = await storage.readValue(AppConfig.isLogin);
      if (isLoginStorage != null) {
        setState(() {
          isLogin = true;
        });
      }
      setState(() {
        _languageCode = languageCode!;
      });
      if (userIdStorage != null && userIdStorage.isNotEmpty) {
        if (widget.userId == '') {
          readUserProfile(userIdStorage);
        } else {
          readUserProfile(widget.userId);
        }

        setState(() {
          myUserId = userIdStorage;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error in readUserId: $e");
      }
    }
  }


  Future<void> readUserProfile(String userId) async {
    final response = await _userService.getUserProfile(userId);
    setState(() {
      userprofile = response;
    });
    if ( userId == myUserId && myUserId.isNotEmpty) {
      setState(() {
        isCurrentUser = true;
      });
    }
    // Fetch followers and followings
    fetchFollowersAndFollowings(userId);
  }

  Future<void> fetchFollowersAndFollowings(String userId) async {
    try {
      final followersResponse = await _userService.getFollowers(userId);
      setState(() {
        followers = followersResponse;
      });
    } catch (e) {
      debugPrint("Error fetching followers: $e");
    }

    try {
      final followingsResponse = await _userService.getFollowings(userId);
      setState(() {
        followings = followingsResponse;
      });
    } catch (e) {
      debugPrint("Error fetching followings: $e");
    }
  }

  Future<void> _selectAvatar() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File file = File(pickedFile.path);
      try {
        var result = await _userService.sendUserDataRequest(UpdateUserRequest(profilePicture: file));
        String? userIdStorage = await storage.readValue(AppConfig.userId);
        final response = await _userService.getUserProfile(userIdStorage!);
        setState(() {
          userprofile = response;
        });

      } catch (e) {
        debugPrint("Error updating avatar: $e");
      }
    }
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _navigateToWeatherPage() {
    Navigator.pushNamed(context, '/weather');
  }

  @override
  Widget build(BuildContext context) {

    // Listen to scroll events
    _scrollController.addListener(() {
      // Implement your logic here, e.g., show "Back to Top" button
    });
    // Determine if the current user is following the displayed user

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
                ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8.0),
                  children: [
                    const SizedBox(height: 16),
                    if(isLogin) _buildProfileSection(userprofile),
                    const SizedBox(height: 16),
                    if (!isCurrentUser && isLogin) _buildFollowButton(userprofile.isFollowed),
                    if (isCurrentUser) ...[
                      _buildPersonInfoSection(),
                      const SizedBox(height: 12),
                    ],
                      _buildSettingSection(),
                      const SizedBox(height: 12),
                      _buildContactSection(),
                      const SizedBox(height: 12),
                      _buildFAQSection(),
                      const SizedBox(height: 12),
                      if (isCurrentUser) ...[
                      _buildUserPreference(),
                      const SizedBox(height: 12), // Adjust spacing if needed
                         ],
                    if (isCurrentUser || !isLogin) _buildLogoutButton(), // Add the Logout button here
                      const SizedBox(height: 36),
                  ],
                ),
                Positioned(
                  bottom: 0,
                  left: 20,
                  child: WeatherIconButton(
                    onPressed: _navigateToWeatherPage,
                    assetPath: 'assets/icons/weather.png',
                  ),
                ),
              ],
            ),
      ),
    );


  }

  Future<void> followBtn(bool isFollowing) async {
    if (isFollowLoading) return;
    setState(() => isFollowLoading = true);

    bool result = await _userService.FollowOrUnFollowUser(widget.userId, isFollowing);

    if (result) {
      setState(() {
        userprofile.isFollowed = !isFollowing;
      });
    }

    setState(() => isFollowLoading = false);
  }

  // Add this method inside _AccountPageState
  Widget _buildFollowButton(
    bool isFollowing,
  ) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          followBtn(isFollowing);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isFollowing ? Colors.red : Colors.blue,
        ),
        child: Text(
          isFollowing
              ? (_languageCode == 'vi' ? "Hủy theo dõi" : "Unfollow")
              : (_languageCode == 'vi' ? "Theo dõi" : "Follow"),
        ),
      ),
    );
  }

  // Build Profile Section
  Widget _buildProfileSection(Userprofile userProfile) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(width: 2),
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(1),
            spreadRadius: 7,
            blurRadius: 15,
            offset: const Offset(5, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center, // Changed to start
            children: [
              // Profile picture on the left
                  GestureDetector(
                    onTap: isCurrentUser? _selectAvatar : (){}, // Gọi khi nhấn vào avatar
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: userProfile.userProfileImage != ''
                          ? NetworkImage(userProfile.userProfileImage)
                          : null,
                      child: userProfile.userProfileImage == ''
                          ? const Icon(Icons.account_circle, size: 80, color: Colors.grey)
                          : null,
                    ),
                  ),
              const SizedBox(width: 25),

              // User details on the right
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userProfile.userName ,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '(${userProfile.fullName})',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_languageCode == 'vi' ?
                      '${userProfile.totalSchedules} lịch trình đã tạo':'${userProfile.totalSchedules} schedules created',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(_languageCode == 'vi' ?
                    '${userProfile.totalPosteds} bài đã tạo':'${userProfile.totalPosteds} posts created',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(_languageCode == 'vi' ?
                      '${userProfile.totalReviews} đánh giá':'${userProfile.totalReviews} reviews',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FollowListPage(
                                  followers: followers,
                                  followings: followings,
                                ),
                              ),
                            );
                          },
                          child: Text(_languageCode == 'vi' ?
                            '${userProfile.totalFollowers} người theo dõi':'${userProfile.totalFollowers} followers',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FollowListPage(
                                  followers: followers,
                                  followings: followings,
                                ),
                              ),
                            );
                          },
                          child: Text(_languageCode == 'vi' ?
                          '${userProfile.totalFollowed} đang theo dõi':'${userProfile.totalFollowed} followings',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 15),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewProfilePage(
                      user: userprofile,
                      userId: widget.userId == ''? myUserId : widget.userId,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD6B588),
                minimumSize: const Size(double.infinity, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(_languageCode == 'vi' ?
                "Xem Hồ sơ":"View Profile",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build Personal Information Section
  Widget _buildPersonInfoSection() {
    return InkWell(
        onTap: () {
          // Navigate to Personal Information Page when tapped
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>  PersonalInformationPage(userprofile: userprofile, userId: myUserId,fetchData: () {
                readUserProfile(myUserId);
              },),
            ),
          );
        },
        child: Container(
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              border: Border.all(width: 1),
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(_languageCode == 'vi' ?'Thông tin cá nhân':'Personal information'),
              subtitle: Text(_languageCode == 'vi' ?'Sửa hoặc thêm thông tin của bạn':'Edit or add your personal information'),
            )));
  }

  // Build Settings Section
  Widget _buildSettingSection() {
    return InkWell(
        onTap: () {
          // Navigate to Setting Page when tapped
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SettingPage(onButtonPressed: (string) {
                setState(() {
                  _languageCode = string;
                });
              },),
            ),
          );
        },
        child: Container(
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              border: Border.all(width: 1),
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              leading: const Icon(Icons.settings),
              title: Text(_languageCode == 'vi' ?'Cài đặt':'Settings'),
              subtitle: Text(_languageCode == 'vi' ?'tùy chỉnh ngôn ngữ':'language settings'),
            )));
  }

  // Build Contact Section
  Widget _buildContactSection() {
    return Container(
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          border: Border.all(width: 1),
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          leading: const Icon(Icons.contact_mail),
          title: Text(_languageCode == 'vi' ?'Liên hệ':'Contact Us'),
          subtitle: Text(_languageCode == 'vi' ?'Yêu cầu hỗ trợ hoặc phản hồi':'Reach out with support requests or feedback'),
          onTap: _sendEmail,
        ));
  }

  // Function to handle sending emails
  Future<void> _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'localtoursep@gmail.com',
      queryParameters: {
        'subject': 'Support Request', // Optional
        'body': 'Hello,', // Optional
      },
    );
    if (kDebugMode) {
      print(emailUri.toString());
    }
    try {
      var x  = await canLaunchUrl(emailUri);
      if (x) {
        await launchUrl(emailUri);
      } else {
        _showErrorDialog('Could not launch the mail client.');
      }
    } catch (e) {
      // Handle any exceptions
      _showErrorDialog('An error occurred while trying to send the email.');
    }
  }

  // Function to show error dialogs
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_languageCode == 'vi' ?'Lỗi':'Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Build FAQ Section
  Widget _buildFAQSection() {
    return InkWell(
        onTap: () {
          // Navigate to FAQ Page when tapped
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FAQPage(languageCode: _languageCode),
            ),
          );
        },
        child: Container(
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              border: Border.all(width: 1),
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              leading: const Icon(Icons.question_answer),
              title: const Text('FAQ'),
              subtitle: Text(_languageCode == 'vi' ?'Tìm câu trả lời cho những câu hỏi thường gặp':'Find answers to frequently asked questions'),
            )));
  }

  // Build User Preference Section
  Widget _buildUserPreference() {
    return InkWell(
        onTap: () {
          // Navigate to User Preference Page when tapped
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>  UserPreferencePage(userprofile: userprofile,),
            ),
          );
        },
        child: Container(
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              border: Border.all(width: 1),
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              leading: const Icon(Icons.question_answer),
              title: Text(_languageCode == 'vi' ? 'Sở thích của bạn':'Your Preference'),
              subtitle: Text(_languageCode == 'vi' ? 'Thêm hoặc cập nhật sở thích của bạn':'Add or update your preferences here'),
            )));
  }

  // Build Logout Button
  Widget _buildLogoutButton() {
    return
      Container(
      margin:  EdgeInsets.only(top: !isLogin?300:8,bottom: 8,left: 8,right: 8),
      child: ElevatedButton(
        onPressed: () {
          if (!isLogin) {
            // Navigate to the login page
            Navigator.pushNamed(context, '/login');
          } else {
            _logout();
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          backgroundColor: isLogin ? Colors.red : Colors.blueAccent,
        ),
        child: Text(
          isLogin ?  (_languageCode != 'vi' ? "Logout" :'Đăng xuất') : (_languageCode != 'vi' ? "Login" :'Đăng nhập'),
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Function to handle logout
  void _logout() {
    _authService.signOut();

    // Update the login status
    setState(() {
      isLogin = false;
    });

    // Navigate to the login screen using pushNamed
    Navigator.pushNamed(context, '/login');

    // Show the notification for logout
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_languageCode == 'vi' ? 'Đăng xuất thành công':'Logged out successfully'),
        duration: const Duration(milliseconds: 500), // Optional: Control how long the message appears
      ),
    );
  }

}
