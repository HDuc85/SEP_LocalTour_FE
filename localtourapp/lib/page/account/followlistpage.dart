import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/users/followuser.dart';
import '../../models/users/users.dart';
import 'account_page.dart';

class FollowListPage extends StatefulWidget {
  final List<FollowUserModel>? followers;
  final List<FollowUserModel>? followings;

  const FollowListPage({
    Key? key,
    this.followers,
    this.followings,
  }) : super(key: key);

  @override
  State<FollowListPage> createState() => _FollowListPageState();
}

class _FollowListPageState extends State<FollowListPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: const Text('Followers & Following'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Followers'),
              Tab(text: 'Following'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUserList(widget.followers ?? [], isFollowerTab: true),
            _buildUserList(widget.followings ?? [], isFollowerTab: false),
          ],
        ),
      ),
    );
  }

  // Build user list for followers or following
  Widget _buildUserList(List<FollowUserModel> followList, {required bool isFollowerTab}) {
    if (followList.isEmpty) {
      return Center(
        child: Text(
          isFollowerTab ? 'No Followers' : 'No Following',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: followList.length,
      itemBuilder: (context, index) {
        final followUser = followList[index];
        final userProfileImage = followUser.userProfileUrl != null && followUser.userProfileUrl!.isNotEmpty
            ? NetworkImage(followUser.userProfileUrl!)
            : const AssetImage('assets/images/default_profile_picture.png') as ImageProvider;

        return ListTile(
          leading: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountPage(
                    userId: isFollowerTab ? followUser.userId : followUser.userFollow,
                  ),
                ),
              );
            },
            child: CircleAvatar(
              backgroundImage: userProfileImage,
              child: (followUser.userProfileUrl == null || followUser.userProfileUrl!.isEmpty)
                  ? const Icon(Icons.account_circle, color: Colors.grey)
                  : null,
            ),
          ),
          title: GestureDetector(
            onTap: () {
              final userIdToNavigate = isFollowerTab || followUser.userFollow.isEmpty
                  ? followUser.userId
                  : followUser.userFollow;

              if (userIdToNavigate.isEmpty) {
                print("Error: userIdToNavigate is empty");
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountPage(userId: userIdToNavigate),
                ),
              );
            },
            child: Text(
              followUser.userName.isNotEmpty ? followUser.userName : "Unknown User",
              style: const TextStyle(fontSize: 16),
            ),
          ),
        );
      },
    );
  }

}

