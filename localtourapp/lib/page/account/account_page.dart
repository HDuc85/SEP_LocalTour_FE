// lib/page/account/account_page.dart

import 'package:flutter/material.dart';
import 'package:localtourapp/base/weather_icon_button.dart';
import 'package:localtourapp/models/users/users.dart';
import 'package:localtourapp/page/account/faq.dart';
import 'package:localtourapp/page/account/personal_infomation.dart';
import 'package:localtourapp/page/account/view_profile/view_profile.dart';
import 'package:localtourapp/page/detail_page/detail_page_tab_bars/count_provider.dart';
import 'package:provider/provider.dart';
import 'package:localtourapp/page/account/user_provider.dart';
import 'package:localtourapp/page/account/users_provider.dart';
import 'package:localtourapp/page/account/setting_page.dart';
import 'package:localtourapp/models/users/followuser.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountPage extends StatefulWidget {
  final User user;
  final List<FollowUser> followUsers;

  const AccountPage({
    Key? key,
    required this.user,
    required this.followUsers,
  }) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late User displayedUser;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final usersProvider = Provider.of<UsersProvider>(context, listen: false);

    if (userProvider.isCurrentUser(widget.user.userId)) {
      // Display current user's information
      displayedUser = userProvider.currentUser;
    } else {
      // Fetch the other user's information from UsersProvider
      displayedUser = usersProvider.getUserById(widget.user.userId) ??
          userProvider.currentUser;
    }
  }
  void _navigateToWeatherPage() {
    Navigator.pushNamed(context, '/weather');
  }
  @override
  Widget build(BuildContext context) {
    final int scheduleCount =
        Provider.of<CountProvider>(context).scheduleCount;
    final int reviewCount =
        Provider.of<CountProvider>(context).reviewCount;
    int followerCount =
    FollowUser.countFollowers(widget.user.userId, widget.followUsers);
    int followingCount =
    FollowUser.countFollowing(widget.user.userId, widget.followUsers);
    bool isCurrentUser =
    Provider.of<UserProvider>(context).isCurrentUser(displayedUser.userId);
    final ScrollController _scrollController = ScrollController();

    // Listen to scroll events
    _scrollController.addListener(() {
      // Implement your logic here, e.g., show "Back to Top" button
    });

    return Stack(
      children: [
        ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(8.0),
          children: [
            const SizedBox(height: 16),
            _buildProfileSection(
              displayedUser,
              scheduleCount,
              reviewCount,
              followerCount,
              followingCount,
            ),
            const SizedBox(height: 16),
            if (isCurrentUser) ...[
              _buildPersonInfoSection(),
              const SizedBox(height: 12),
              _buildSettingSection(),
              const SizedBox(height: 12),
              _buildContactSection(),
              const SizedBox(height: 12),
              _buildFAQSection(),
            ],
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
    );
  }

  // Build Profile Section
  Widget _buildProfileSection(User user, int scheduleCount, int reviewCount,
      int followerCount, int followingCount) {
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
                backgroundImage: user.profilePictureUrl != null
                    ? NetworkImage(user.profilePictureUrl!)
                    : null,
                child: user.profilePictureUrl == null
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
                      user.fullName ?? "Unknown User",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '(${user.userName})',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$scheduleCount schedules created',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      '$reviewCount reviews',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '$followerCount followers',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '$followingCount following',
                          style: const TextStyle(fontSize: 14),
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
                    builder: (context) => ViewProfilePage(userId: displayedUser.userId),
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
}