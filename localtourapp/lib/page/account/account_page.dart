import 'package:flutter/material.dart';
import 'package:localtourapp/page/account/view_profile/post_provider.dart';
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
  final bool isCurrentUser;
  final User user;
  final List<FollowUser> followUsers;

  const AccountPage({
    Key? key,
    required this.isCurrentUser,
    required this.user,
    required this.followUsers,
  }) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late List<FollowUser> followers;
  late List<FollowUser> followings;
  late User displayedUser;

  // **Add these declarations:**
  late int followerCount;
  late int followingCount;

  // Existing ScrollController declaration
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final followUsersProvider =
    Provider.of<FollowUsersProvider>(context, listen: false);
    followers = followUsersProvider.getFollowers(widget.user.userId);
    followings = followUsersProvider.getFollowings(widget.user.userId);
    displayedUser = widget.user;

    // Initialize followerCount and followingCount
    followerCount =
        FollowUser.countFollowers(widget.user.userId, widget.followUsers);
    followingCount =
        FollowUser.countFollowing(widget.user.userId, widget.followUsers);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final usersProvider = Provider.of<UsersProvider>(context, listen: false);
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final scheduleProvider =
    Provider.of<ScheduleProvider>(context, listen: false);
    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);

    if (userProvider.isCurrentUser(widget.user.userId)) {
      // Display current user's information
      displayedUser = userProvider.currentUser;
    } else {
      // Fetch the other user's information from UsersProvider
      displayedUser = (usersProvider.getUserById(widget.user.userId) ??
          userProvider.currentUser);
    }

    final userReviews = reviewProvider.getReviewsByUserId(displayedUser.userId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CountProvider>(context, listen: false)
          .setReviewCount(userReviews.length);
    });
    final userSchedules =
    scheduleProvider.getSchedulesByUserId(displayedUser.userId);
    // Use post-frame callback to set schedule count after initial build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CountProvider>(context, listen: false)
          .setScheduleCount(userSchedules.length);
    });

    final userPosts = postProvider.getPostsByUserId(displayedUser.userId);
    // Use post-frame callback to set post count after initial build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CountProvider>(context, listen: false)
          .setPostCount(userPosts.length);
    });
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
    final followUsersProvider =
    Provider.of<FollowUsersProvider>(context, listen: true);
    final userProvider = Provider.of<UserProvider>(context, listen: true);
    // If viewing another user's profile, determine if the current user follows them
    final int scheduleCount = Provider.of<CountProvider>(context).scheduleCount;
    final int reviewCount = Provider.of<CountProvider>(context).reviewCount;
    final int postCount = Provider.of<CountProvider>(context).postCount;
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

    // Determine if the current user is following the displayed user
    bool isFollowing = false;
    if (!isCurrentUser) {
      isFollowing = followUsersProvider.isFollowing(
          userProvider.userId, displayedUser.userId);
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
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
              postCount,
              followerCount,
              followingCount,
            ),
            const SizedBox(height: 16),
            if (!isCurrentUser)
              _buildFollowButton(
                  isFollowing, followUsersProvider, userProvider),
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

  // Add this method inside _AccountPageState
  Widget _buildFollowButton(bool isFollowing,
      FollowUsersProvider followUsersProvider, UserProvider userProvider) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          if (isFollowing) {
            followUsersProvider.removeFollowUser(
                userProvider.userId, displayedUser.userId);
          } else {
            followUsersProvider.addFollowUser(FollowUser(
              id: followUsersProvider.followUsers.length + 1,
              userId: userProvider.userId,
              userFollow: displayedUser.userId,
              dateCreated: DateTime.now(),
            ));
          }

          // Update follower and following counts after following/unfollowing
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              followerCount = FollowUser.countFollowers(
                  displayedUser.userId, followUsersProvider.followUsers);
              followingCount = FollowUser.countFollowing(
                  displayedUser.userId, followUsersProvider.followUsers);
            });
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isFollowing ? Colors.red : Colors.blue,
        ),
        child: Text(isFollowing ? "Unfollow" : "Follow"),
      ),
    );
  }

  // Build Profile Section
  Widget _buildProfileSection(User user, int scheduleCount, int reviewCount,
      int postCount, int followerCount, int followingCount) {
    final scheduleProvider = Provider.of<ScheduleProvider>(context);
    final List<Schedule> allSchedules = scheduleProvider.schedules;
    final List<Schedule> userSchedules = allSchedules
        .where((schedule) => schedule.userId == displayedUser.userId)
        .toList();
    final postProvider = Provider.of<PostProvider>(context);
    final List<Post> userPosts =
    postProvider.getPostsByUserId(displayedUser.userId);
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
                      '$postCount posts created',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      '$reviewCount reviews',
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
                            '$followerCount followers',
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
                            '$followingCount following',
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
                      schedules: userSchedules,
                      posts: userPosts,
                      user: displayedUser,
                      followUsers: widget.followUsers,
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