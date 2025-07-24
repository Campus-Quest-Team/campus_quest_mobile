import 'package:campus_quest/screens/edit_profile_page.dart';
import 'package:campus_quest/widgets/post_card.dart';
import 'package:flutter/material.dart';

class ProfileBody extends StatelessWidget {
  final VoidCallback onBackToFeedTap;

  const ProfileBody({super.key, required this.onBackToFeedTap});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> userPosts = [
      {
        'username': 'You',
        'caption': 'Exploring the north tower!',
        'quest': 'Tower Quest',
        'imageUrl':
            'https://images.unsplash.com/photo-1558980664-10e7170d71db?fit=crop&w=800&q=60',
        'likes': 127,
      },
      {
        'username': 'You',
        'caption': 'Secret scroll delivered!',
        'quest': 'Scroll Quest',
        'imageUrl':
            'https://images.unsplash.com/photo-1608827702224-009c9c6f7ee6?fit=crop&w=800&q=60',
        'likes': 212,
      },
    ];

    return Column(
      children: [
        AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBackToFeedTap,
          ),
          title: const Text('Your Profile'),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
          elevation: Theme.of(context).appBarTheme.elevation,
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              );
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profile'),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: userPosts.length,
            itemBuilder: (context, index) {
              final post = userPosts[index];
              return PostCard(
                username: post['username'],
                caption: post['caption'],
                quest: post['quest'],
                imageUrl: post['imageUrl'],
                likes: post['likes'],
                index: index,
              );
            },
          ),
        ),
      ],
    );
  }
}
