import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/users/followuser.dart';
import '../../models/users/users.dart';
import 'account_page.dart';

class FollowListPage extends StatefulWidget {
  final List<FollowUser> followers;
  final List<FollowUser> following;
  final List<User> allUsers;

  const FollowListPage({
    Key? key,
    required this.followers,
    required this.following,
    required this.allUsers,
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
          title: const Text(''),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Followers'),
              Tab(text: 'Following'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUserList(widget.followers, isFollowerTab: true),
            _buildUserList(widget.following, isFollowerTab: false),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList(List<FollowUser> followList,
      {required bool isFollowerTab}) {
    return ListView.builder(
      itemCount: followList.length,
      itemBuilder: (context, index) {
        final followUser = followList[index];
        // Determine whose profile to show based on isFollowerTab
        final userIdToShow =
            isFollowerTab ? followUser.userId : followUser.userFollow;

        final user = widget.allUsers.firstWhere(
          (u) => u.userId == userIdToShow,
          orElse: () => User(
            userId: 'default',
            userName: 'Unknown User',
            emailConfirmed: false,
            phoneNumberConfirmed: false,
            dateCreated: DateTime.now(),
            dateUpdated: DateTime.now(),
            reportTimes: 0,
          ),
        );

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: user.profilePictureUrl != null
                ? NetworkImage(user.profilePictureUrl!)
                : null,
            child: user.profilePictureUrl == null
                ? const Icon(Icons.account_circle, color: Colors.grey)
                : null,
          ),
          title: GestureDetector(
            onTap: () {
              // Use UserProvider to get the user's details

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountPage(
                    userId: '',
                  ),
                ),
              );
            },
            child: Text(user.userName ?? "Unknown User"),
          ),
          subtitle: Text(
            isFollowerTab
                ? 'Followed you at: ${followUser.dateCreated.toLocal().toString().split(' ')[0]}'
                : 'You followed at: ${followUser.dateCreated.toLocal().toString().split(' ')[0]}',
          ),
        );
      },
    );
  }
}
