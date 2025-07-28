// ignore_for_file: use_key_in_widget_constructors

import 'package:campus_quest/api/posts.dart';
import 'package:campus_quest/api/users.dart';
import 'package:campus_quest/screens/settings_page.dart';
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
    final credentials = await getToken(context);
    final data = await getProfile(
      userId: credentials['userId']!,
      jwtToken: credentials['accessToken']!,
    );

    if (!mounted) return;

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
                  _editCaption(index);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete Post'),
                onTap: () {
                  Navigator.pop(context);
                  _deletePost(index); // ✅ Hook in delete handler
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _editCaption(int index) async {
    final post = userPosts[index];
    final credentials = await getToken(context);

    final tempController = TextEditingController(text: post['caption']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Edit Caption',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEFBF04),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tempController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Update your caption...',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final newCaption = tempController.text.trim();
                      Navigator.pop(context);

                      final result = await updateCaption(
                        userId: credentials['userId']!,
                        postId: post['_id'],
                        caption: newCaption,
                        jwtToken: credentials['accessToken']!,
                      );

                      if (result != null && result['success'] == true) {
                        setState(() {
                          userPosts[index]['caption'] = newCaption;
                        });
                        if (!context.mounted) return;
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }

                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Caption updated!')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to update caption'),
                          ),
                        );
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deletePost(int index) async {
    final post = userPosts[index];
    final credentials = await getToken(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final result = await deletePost(
      userId: credentials['userId']!,
      postId: post['_id'],
      jwtToken: credentials['accessToken']!,
    );

    if (result != null && result['success'] == true) {
      setState(() {
        userPosts.removeAt(index);
      });
      if (!mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post deleted successfully.')),
      );
    } else {
      Navigator.pop(context); // Close the modal
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to delete post.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          leading: CloseButton(onPressed: widget.onBackToFeedTap),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingPage()),
                );
              }, // Settings page or modal
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
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: Colors.grey[300],
                              backgroundImage: pfp.isNotEmpty
                                  ? NetworkImage(pfp)
                                  : null,
                              child: pfp.isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      size: 32,
                                      color: Colors.black,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    bio,
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

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
