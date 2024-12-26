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
import '../../base/const.dart';
import '../../base/weather_icon_button.dart';
import '../../models/users/followuser.dart';
import '../../models/users/update_user_request.dart';
import '../../models/users/users.dart';
import '../../services/notification_service.dart';
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
  final NotificationService _notificationService = NotificationService();
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
      final languageCode = await storage.readValue(AppConfig.language);
      final userIdStorage = await storage.readValue(AppConfig.userId);
      final isLoginStorage = await storage.readValue(AppConfig.isLogin);

      if (!mounted) return;

      setState(() {
        isLogin = isLoginStorage != null;
        _languageCode = languageCode ?? 'en';
        myUserId = userIdStorage ?? '';
      });

      if (userIdStorage != null && userIdStorage.isNotEmpty) {
        readUserProfile(widget.userId.isEmpty ? userIdStorage : widget.userId);
      }
    } catch (e) {
      debugPrint("Error in readUserId: $e");
    }
  }

  Future<void> readUserProfile(String userId) async {
    try {
      final response = await _userService.getUserProfile(userId);

      if (!mounted) return;

      setState(() {
        userprofile = response;
        isCurrentUser = userId == myUserId;
      });

      fetchFollowersAndFollowings(userId);
    } catch (e) {
      debugPrint("Error fetching user profile: $e");
    }
  }

  Future<void> fetchFollowersAndFollowings(String userId) async {
    try {
      final followersResponse = await _userService.getFollowers(userId);
      final followingsResponse = await _userService.getFollowings(userId);

      if (!mounted) return;

      setState(() {
        followers = followersResponse;
        followings = followingsResponse;
      });
    } catch (e) {
      debugPrint("Error fetching followers or followings: $e");
    }
  }

  Future<void> _selectAvatar() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      try {
        await _userService
            .sendUserDataRequest(UpdateUserRequest(profilePicture: file));

        if (!mounted) return;

        final userIdStorage = await storage.readValue(AppConfig.userId);
        final response = await _userService.getUserProfile(userIdStorage!);

        if (!mounted) return;

        setState(() {
          userprofile = response;
        });
      } catch (e) {
        debugPrint("Error updating avatar: $e");
      }
    }
  }

  Future<void> followBtn(bool isFollowing) async {
    if (isFollowLoading) return;

    setState(() => isFollowLoading = true);

    try {
      final result =
          await _userService.FollowOrUnFollowUser(widget.userId, isFollowing);

      if (!mounted) return;

      if (result) {
        setState(() {
          userprofile.isFollowed = !isFollowing;
        });
      }
    } catch (e) {
      debugPrint("Error following/unfollowing: $e");
    } finally {
      if (mounted) {
        setState(() => isFollowLoading = false);
      }
    }
  }

  Future<void> _logout() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      // Delete the device token
      final tokenDeleted = await _notificationService.deleteDeviceToken();
      if (!tokenDeleted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              _languageCode == 'vi'
                  ? 'Không thể xóa thiết bị khỏi danh sách thông báo.'
                  : 'Failed to deregister your device from notifications.',
            ),
          ),
        );
      }

      // Sign out the user
      await _authService.signOut();

      if (!mounted) return;

      // Update the state
      setState(() {
        isLogin = false;
      });

      // Navigate to the login page
      navigator.pushNamedAndRemoveUntil('/login', (route) => false);

      // Show a logout success message
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            _languageCode == 'vi'
                ? 'Đăng xuất thành công'
                : 'Logged out successfully',
          ),
        ),
      );
    } catch (e) {
      debugPrint("Error during logout: $e");
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _navigateToWeatherPage() {
    Navigator.pushNamed(context, '/weather');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          _languageCode == 'vi' ? 'Trang cá nhân' : 'Account Page',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Constants.defaultState, Constants.selectedState],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                const SizedBox(height: 16),
                if (isLogin) _buildProfileSection(userprofile),
                const SizedBox(height: 24),
                if (!isCurrentUser && isLogin)
                  _buildFollowButton(userprofile.isFollowed),
                const SizedBox(height: 16),
                if (isCurrentUser) ...[
                  _buildCardSection(
                    icon: Icons.person,
                    title: _languageCode == 'vi' ? 'Thông tin cá nhân' : 'Personal Information',
                    subtitle: _languageCode == 'vi' ? 'Sửa hoặc thêm thông tin của bạn' : 'Edit or add your personal information',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PersonalInformationPage(
                            userprofile: userprofile,
                            userId: myUserId,
                            fetchData: () {
                              readUserProfile(myUserId);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                _buildCardSection(
                  icon: Icons.settings,
                  title: _languageCode == 'vi' ? 'Cài đặt' : 'Settings',
                  subtitle: _languageCode == 'vi' ? 'Tùy chỉnh ngôn ngữ' : 'Language settings',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingPage(
                          onButtonPressed: (string) {
                            setState(() {
                              _languageCode = string;
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildCardSection(
                  icon: Icons.contact_mail,
                  title: _languageCode == 'vi' ? 'Liên hệ' : 'Contact Us',
                  subtitle: _languageCode == 'vi' ? 'Yêu cầu hỗ trợ hoặc phản hồi' : 'Reach out with support requests or feedback',
                  onTap: _sendEmail,
                ),
                const SizedBox(height: 16),
                _buildCardSection(
                  icon: Icons.question_answer,
                  title: _languageCode == 'vi' ? 'Câu hỏi thường gặp' : 'FAQ',
                  subtitle: _languageCode == 'vi'
                      ? 'Tìm câu trả lời cho những câu hỏi thường gặp'
                      : 'Find answers to frequently asked questions',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FAQPage(languageCode: _languageCode),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                if (isCurrentUser)
                  _buildCardSection(
                    icon: Icons.favorite,
                    title: _languageCode == 'vi' ? 'Sở thích của bạn' : 'Your Preference',
                    subtitle: _languageCode == 'vi'
                        ? 'Thêm hoặc cập nhật sở thích của bạn'
                        : 'Add or update your preferences here',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserPreferencePage(userprofile: userprofile),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 24),
                if (isCurrentUser || !isLogin)
                  _buildLogoutButton(),
                const SizedBox(height: 36),
              ],
            ),
            Positioned(
              bottom: 16,
              left: 16,
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
      var x = await canLaunchUrl(emailUri);
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
          title: Text(_languageCode == 'vi' ? 'Lỗi' : 'Error'),
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

  Widget _buildCardSection({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(icon, color: Constants.defaultState),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
    );
  }

  Widget _buildProfileSection(Userprofile userProfile) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Constants.selectedState, Constants.defaultState],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 4,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: userProfile.userProfileImage != ''
                ? NetworkImage(userProfile.userProfileImage)
                : null,
            child: userProfile.userProfileImage == ''
                ? const Icon(Icons.account_circle, size: 80, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            userProfile.userName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            userProfile.fullName,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildProfileStat(
                count: userProfile.totalSchedules,
                label: _languageCode == 'vi' ? 'Lịch trình' : 'Schedules',
              ),
              _buildProfileStat(
                count: userProfile.totalPosteds,
                label: _languageCode == 'vi' ? 'Bài đăng' : 'Posts',
              ),
              _buildProfileStat(
                count: userProfile.totalReviews,
                label: _languageCode == 'vi' ? 'Đánh giá' : 'Reviews',
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                child: Column(
                  children: [
                    Text(
                      '${userProfile.totalFollowers}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _languageCode == 'vi' ? 'người theo dõi' : 'followers',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
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
                child: Column(
                  children: [
                    Text(
                      '${userProfile.totalFollowed}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _languageCode == 'vi' ? 'đang theo dõi' : 'followings',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
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
                      userId: widget.userId == '' ? myUserId : widget.userId,
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
              child: Text(
                _languageCode == 'vi' ? "Xem Hồ sơ" : "View Profile",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
    ]));
  }

  Widget _buildProfileStat({required int count, required String label}) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton(
      onPressed: () {
        if (!isLogin) {
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
        backgroundColor: isLogin ? Colors.red : Colors.blue,
      ),
      child: Text(
        isLogin
            ? (_languageCode != 'vi' ? "Logout" : 'Đăng xuất')
            : (_languageCode != 'vi' ? "Login" : 'Đăng nhập'),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}