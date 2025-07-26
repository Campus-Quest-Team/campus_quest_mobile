// ignore_for_file: use_key_in_widget_constructors

import 'package:campus_quest/api/users.dart';
import 'package:campus_quest/services/saved_credentials.dart';
import 'package:campus_quest/widgets/post_card.dart';
import 'package:flutter/material.dart';

class ProfileBody extends StatefulWidget {
  final VoidCallback onBackToFeedTap;

  const ProfileBody({required this.onBackToFeedTap});

  @override
  State<ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  List<Map<String, dynamic>> userPosts = [];
  String displayName = '';
  String bio = '';
  String pfp = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    // Replace with actual userId and jwtToken from storage

    final credentials = await getToken(context);
    final data = await getProfile(
      userId: credentials['userId']!,
      jwtToken: credentials['accessToken']!,
    );
    if (data != null) {
      setState(() {
        displayName = data['displayName'] ?? 'You';
        bio = data['bio'] ?? '';
        pfp = data['pfp'] ?? '';
        userPosts = List<Map<String, dynamic>>.from(data['questPosts'] ?? []);
        isLoading = false;
      });
    }
  }

  void _showEditOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Caption'),
                onTap: () {
                  Navigator.pop(context);
                  // Handle edit caption logic here
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete Post'),
                onTap: () {
                  Navigator.pop(context);
                  // Handle delete post logic here
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          leading: IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {}, // Settings page or modal
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: widget.onBackToFeedTap,
            ),
          ],
          title: const Text('Your Profile'),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
          elevation: Theme.of(context).appBarTheme.elevation,
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(bio, style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 16),
                      if (userPosts.isEmpty)
                        Center(
                          child: Column(
                            children: const [
                              SizedBox(height: 32),
                              Icon(Icons.tag, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No Posts Yet!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...userPosts.asMap().entries.map((entry) {
                          final post = entry.value;
                          return Column(
                            children: [
                              PostCard(
                                caption: post['caption'] ?? '',
                                quest: post['questDescription'] ?? '',
                                imageUrl: post['mediaUrl'] ?? '',
                                likes: post['likes'] ?? 0,
                                index: entry.key,
                                timestamp: post['timeStamp'] ?? '',
                                onMorePressed: () =>
                                    _showEditOptions(context, entry.key),
                              ),
                              const SizedBox(height: 60),
                            ],
                          );
                        }),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

/* TODO:
Checkmark should navigate to profile view
Settings on top left toolbar
Right back arrow should be X
Replace edit profile button with proile view
Remvove flagging posts
Remove comment button
Three dot menu to delete post, edit caption, 
Integrate view on personal posts
*/
