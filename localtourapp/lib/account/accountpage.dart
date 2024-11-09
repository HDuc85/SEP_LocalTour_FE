import 'package:flutter/material.dart';
import 'package:localtourapp/account/user_provider.dart';
import 'package:localtourapp/account/users_provider.dart';
import 'package:localtourapp/base/custombutton.dart';
import 'package:provider/provider.dart';

import '../base/weathericonbutton.dart';
import '../models/users/followuser.dart';
import '../models/users/users.dart';
import '../page/detailpage/detailpagetabbars/count_provider.dart';

class AccountPage extends StatefulWidget {
  final User user;
  final List<FollowUser> followUsers;

  const AccountPage({super.key, required this.user, required this.followUsers});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late User displayedUser;

  @override
  void dispose() {
    super.dispose();
  }

  // Function to navigate to the Weather page
  void _navigateToWeatherPage() {
    Navigator.pushNamed(context, '/weather');
  }

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
      displayedUser = usersProvider.getUserById(widget.user.userId!) ??
          userProvider.currentUser;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int scheduleCount = Provider.of<CountProvider>(context).scheduleCount;
    final int reviewCount = Provider.of<CountProvider>(context).reviewCount;
    int followerCount =
        FollowUser.countFollowers(widget.user.userId, widget.followUsers);
    int followingCount =
        FollowUser.countFollowing(widget.user.userId, widget.followUsers);
    bool isCurrentUser =
        Provider.of<UserProvider>(context).isCurrentUser(displayedUser.userId);

    // Create a ScrollController for this screen
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
              widget.user,
              scheduleCount,
              reviewCount,
              followerCount,
              followingCount,
            ),
            const SizedBox(height: 16),
            if (isCurrentUser) ...[
              _buildPersonalInformationSection(),
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
                    ? const Icon(Icons.account_circle, size: 60, color: Colors.grey)
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
                    const Text(
                      '0 posts created', // Placeholder for post count
                      style: TextStyle(fontSize: 14),
                    ),
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
        margin: EdgeInsets.only(top: 10),
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: ElevatedButton(
          onPressed: (){},
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFD6B588),
            minimumSize: const Size(double.infinity, 36),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: Text(
            "View Profile",
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

  Widget _buildPersonalInformationSection() {
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
        child: const ListTile(
          leading: Icon(Icons.person),
          title: Text('Personal information'),
          subtitle: Text('Edit or add your personal information'),
        ));
  }

  Widget _buildSettingSection() {
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
        child: const ListTile(
          leading: Icon(Icons.settings),
          title: Text('Settings'),
          subtitle: Text('View, find, and customize account settings'),
        ));
  }

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
        child: const ListTile(
          leading: Icon(Icons.contact_mail),
          title: Text('Contact Us'),
          subtitle: Text('Reach out with support requests or feedback'),
        ));
  }

  Widget _buildFAQSection() {
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
        child: const ListTile(
          leading: Icon(Icons.question_answer),
          title: Text('FAQ'),
          subtitle: Text('Find answers to frequently asked questions'),
        ));
  }
}
