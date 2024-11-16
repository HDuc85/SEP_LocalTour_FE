// lib/page/account/account_page.dart
import 'package:flutter/material.dart';
import 'package:localtourapp/config/appConfig.dart';
import 'package:localtourapp/config/secure_storage_helper.dart';
import 'package:localtourapp/models/users/userProfile.dart';
import 'package:localtourapp/page/account/view_profile/post_provider.dart';
import 'package:localtourapp/services/user_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../base/weather_icon_button.dart';
import '../../models/posts/post.dart';
import '../../models/schedule/schedule.dart';
import '../../models/users/followuser.dart';
import '../../models/users/users.dart';
import '../../provider/count_provider.dart';
import '../../provider/follow_users_provider.dart';
import '../../provider/review_provider.dart';
import '../../provider/schedule_provider.dart';
import '../../provider/user_provider.dart';
import '../../provider/users_provider.dart';
import 'faq.dart';
import 'followlistpage.dart';
import 'personal_infomation.dart';
import 'setting_page.dart';
import 'user_preference.dart';
import 'view_profile/view_profile.dart';

// Import other necessary pages like ViewProfilePage, PersonalInformationPage, SettingPage, FAQPage

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
  late UserService _userService = UserService();

  late List<FollowUser> followers;
  late List<FollowUser> followings;
  late Userprofile userprofile;
  late User displayedUser;
  late String myUserId = '';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    readUserId();
    readUserProfile(widget.userId);
    super.initState();
  }

  Future<void> readUserId() async {
    final userIdStorage =
        await SecureStorageHelper().readValue(AppConfig.userId);
    if (userIdStorage != null) {
      setState(() {
        myUserId = userIdStorage;
      });
    }
  }

  Future<void> readUserProfile(String userId) async {
    final reponse = await _userService.getUserProfile(userId);
    setState(() {
      userprofile = reponse;
    });
  }

  Future<void> _FollowButtonFn() async {}
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
    final ScrollController _scrollController = ScrollController();
    bool isCurrentUser = false;
    // Listen to scroll events
    _scrollController.addListener(() {
      // Implement your logic here, e.g., show "Back to Top" button
    });

    if (widget.userId == myUserId) {
      isCurrentUser = true;
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const SizedBox(height: 16),
            _buildProfileSection(userprofile),
            const SizedBox(height: 16),
            if (!isCurrentUser) _buildFollowButton(userprofile.isFollowed),
            if (isCurrentUser) ...[
              _buildPersonInfoSection(),
              const SizedBox(height: 12),
              _buildSettingSection(),
              const SizedBox(height: 12),
              _buildContactSection(),
              const SizedBox(height: 12),
              _buildFAQSection(),
              const SizedBox(height: 12),
              _buildUserPreference(),
              const SizedBox(height: 36),
            ],
          ],
        ),
      ),
    );
  }

  // Add this method inside _AccountPageState
  Widget _buildFollowButton(bool isFollowed) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          _FollowButtonFn();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isFollowed ? Colors.red : Colors.blue,
        ),
        child: Text(isFollowed ? "Unfollow" : "Follow"),
      ),
    );
  }

  // Build Profile Section
  Widget _buildProfileSection(Userprofile userProfile) {
    return Container(
      padding: const EdgeInsets.all(16.0),
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
            crossAxisAlignment: CrossAxisAlignment.start, // Changed to start
            children: [
              // Profile picture on the left
              CircleAvatar(
                radius: 30,
                backgroundImage: userProfile.userProfileImage != ''
                    ? NetworkImage(userProfile.userProfileImage)
                    : null,
                child: userProfile.userProfileImage == ''
                    ? const Icon(Icons.account_circle,
                        size: 60, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 16),

              // User details on the right
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userProfile.userName == ''
                          ? "Empty Name"
                          : userProfile.userName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${userProfile.totalSchedules} schedules created',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      '${userProfile.totalPosteds} posts created',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      '${userProfile.totalReviews} reviews',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FollowListPage(
                                  followers: followers,
                                  following: followings,
                                  allUsers: Provider.of<UsersProvider>(context,
                                          listen: false)
                                      .users, // List of all users
                                ),
                              ),
                            );
                          },
                          child: Text(
                            '${userProfile.totalFollowed} followers',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FollowListPage(
                                  followers: followers,
                                  following: followings,
                                  allUsers: Provider.of<UsersProvider>(context,
                                          listen: false)
                                      .users, // List of all users
                                ),
                              ),
                            );
                          },
                          child: Text(
                            '${userProfile.totalFollowers} following',
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
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewProfilePage(
                      userId: displayedUser.userId,
                      user: displayedUser,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD6B588),
                minimumSize: const Size(double.infinity, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                "View Profile",
                style: TextStyle(
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
              builder: (context) => const PersonalInformationPage(),
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
            child: const ListTile(
              leading: Icon(Icons.person),
              title: Text('Personal information'),
              subtitle: Text('Edit or add your personal information'),
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
              builder: (context) => const SettingPage(),
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
            child: const ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              subtitle: Text('View, find, and customize account settings'),
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
          title: const Text('Contact Us'),
          subtitle: const Text('Reach out with support requests or feedback'),
          onTap: _sendEmail,
        ));
  }

  // Function to handle sending emails
  Future<void> _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'localtourvn123@gmail.com',
      queryParameters: {
        'subject': 'Support Request', // Optional
        'body': 'Hello,', // Optional
      },
    );
    print(emailUri.toString());
    try {
      // Check if the device can handle the mailto scheme
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        // If the device cannot handle the mailto scheme, show an error
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
          title: const Text('Error'),
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
              builder: (context) => const FAQPage(),
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
            child: const ListTile(
              leading: Icon(Icons.question_answer),
              title: Text('FAQ'),
              subtitle: Text('Find answers to frequently asked questions'),
            )));
  }

  Widget _buildUserPreference() {
    return InkWell(
        onTap: () {
          // Navigate to FAQ Page when tapped
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UserPreferencePage(),
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
            child: const ListTile(
              leading: Icon(Icons.question_answer),
              title: Text('Your Preference'),
              subtitle: Text('Add or update your preference here'),
            )));
  }
}
