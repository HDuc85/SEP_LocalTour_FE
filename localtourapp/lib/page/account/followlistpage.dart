import 'package:flutter/material.dart';
import 'package:localtourapp/models/users/followuser.dart';
import 'package:localtourapp/models/users/users.dart';

class FollowListPage extends StatelessWidget {
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
            _buildUserList(followers, isFollowerTab: true),
            _buildUserList(following, isFollowerTab: false),
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
        final user = allUsers.firstWhere((u) => u.userId == followUser.userId);

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: user.profilePictureUrl != null
                ? NetworkImage(user.profilePictureUrl!)
                : null,
            child: user.profilePictureUrl == null
                ? const Icon(Icons.account_circle, color: Colors.grey)
                : null,
          ),
          title: Text(user.fullName ?? "Unknown User"),
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
