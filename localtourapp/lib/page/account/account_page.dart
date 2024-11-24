import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localtourapp/config/appConfig.dart';
import 'package:localtourapp/config/secure_storage_helper.dart';
import 'package:localtourapp/models/users/userProfile.dart';
import 'package:localtourapp/services/auth_service.dart';
import 'package:localtourapp/services/user_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../base/weather_icon_button.dart';
import '../../models/users/followuser.dart';
import '../../models/users/update_user_request.dart';
import '../../models/users/users.dart';
import '../../provider/users_provider.dart';
import 'faq.dart';
import 'followlistpage.dart';
import 'personal_infomation.dart';
import 'setting_page.dart';
import 'user_preference.dart';
import 'view_profile/auth_provider.dart';
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
  final AuthService _authService = AuthService();
  late UserService _userService = UserService();
  final storage = SecureStorageHelper();
  late List<FollowUser> followers;
  late List<FollowUser> followings;
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
      String? userIdStorage = await storage.readValue(AppConfig.userId);
      String? isLoginStorage = await storage.readValue(AppConfig.isLogin);



      if(isLoginStorage != null){
        setState(() {
          isLogin = true;
        });
      }

      if (userIdStorage != null && userIdStorage.isNotEmpty) {

        if(widget.userId == ''){
          readUserProfile(userIdStorage);
        }else{
          readUserProfile(widget.userId);
        }

        setState(() {
          myUserId = userIdStorage;
        });
      }
    } catch (e) {
      print("Error in readUserId: $e");
    }
  }

  Future<void> readUserProfile(String userId) async {

    final reponse = await _userService.getUserProfile(userId);
    setState(() {
      userprofile = reponse;
    });

    if ( userId == myUserId && myUserId.isNotEmpty) {

      setState(() {
        isCurrentUser = true;

      });
    }
  }

  Future<void> _selectAvatar() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File file = File(pickedFile.path);
     var result = await _userService.sendUserDataRequest(new UpdateUserRequest(profilePicture: file));
     if(result != null){
       setState(() {
         userprofile = result;
       });
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

    return Stack(
      children: [
            ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              children: [
                const SizedBox(height: 16),
                _buildProfileSection(userprofile),
                const SizedBox(height: 16),
                if (!isCurrentUser && isLogin) _buildFollowButton(userprofile.isFollowed),
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
                  const SizedBox(height: 12), // Adjust spacing if needed
                ],

                if (isCurrentUser)_buildLogoutButton(), // Add the Logout button here
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
        );


  }

  Future<void> folowBtn(bool isFollowing) async {
    bool result = await _userService.FollowOrUnFollowUser(widget.userId,isFollowing);
    if(result){
      setState(() {
        userprofile.isFollowed = !isFollowing;
      });
    }
  }

  // Add this method inside _AccountPageState
  Widget _buildFollowButton(
    bool isFollowing,
  ) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          folowBtn(isFollowing);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isFollowing ? Colors.red : Colors.blue,
        ),
        child: Text(isFollowing ? "Unfollow" : "Follow"),
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
              SizedBox(width: 10,),
              // Profile picture on the left
              Column(
                children: [
                  SizedBox(height: 10,),
                  GestureDetector(
                    onTap: isCurrentUser? _selectAvatar : (){}, // Gọi khi nhấn vào avatar
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: userProfile.userProfileImage != ''
                          ? NetworkImage(userProfile.userProfileImage)
                          : null,
                      child: userProfile.userProfileImage == ''
                          ? const Icon(Icons.account_circle, size: 60, color: Colors.grey)
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 25),

              // User details on the right
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userProfile.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '(${userProfile.userName})',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
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
                        const SizedBox(width: 24),
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
            margin: const EdgeInsets.only(top: 15),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewProfilePage(
                      followUsers: [],
                      posts: [],
                      schedules: [],
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
            child: const ListTile(
              leading: Icon(Icons.question_answer),
              title: Text('Your Preference'),
              subtitle: Text('Add or update your preferences here'),
            )));
  }

  // Build Logout Button
  Widget _buildLogoutButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: () {
          // Trigger the logout process
          _logout();
        },
        style: !isLogin? ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent, // Choose a color that signifies logout
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          )) : ElevatedButton.styleFrom(
          backgroundColor: Colors.red, // Choose a color that signifies logout
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Text(
          !isLogin ?'Login':
          'Logout',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Function to handle logout
  void _logout() {
    // Access the AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    authProvider.logout();

    _authService.signOut();

    // Navigate to the login screen or any desired screen after logout
    Navigator.pushReplacementNamed(
        context, '/login'); // Adjust the route as needed

    // Optionally, show a confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logged out successfully'),
      ),
    );
  }
}
