import 'package:flutter/material.dart';
import 'package:campus_quest/widgets/post_card.dart';
import 'package:campus_quest/api/posts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedBody extends StatefulWidget {
  final VoidCallback onQuestTap;
  final VoidCallback onProfileTap;

  const FeedBody({
    super.key,
    required this.onQuestTap,
    required this.onProfileTap,
  });

  @override
  State<FeedBody> createState() => _FeedBodyState();
}

class _FeedBodyState extends State<FeedBody> {
  List<Map<String, dynamic>> _feed = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFeed();
  }

  Future<void> fetchFeed() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final jwtToken = prefs.getString('accessToken');

    if (userId != null && jwtToken != null) {
      final feed = await getFeed(
        context: context,
        userId: userId,
        jwtToken: jwtToken,
      );
      if (mounted && feed != null) {
        setState(() {
          _feed = feed;
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Campus Quest'),
          centerTitle: false,
          titleSpacing: 16,
          actions: [
            IconButton(
              icon: const Icon(Icons.explore_outlined, size: 30),
              onPressed: widget.onQuestTap,
            ),
            IconButton(
              icon: const Icon(Icons.person, size: 30),
              onPressed: widget.onProfileTap,
            ),
          ],
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _feed.isEmpty
              ? const Center(child: Text('No posts yet.'))
              : ListView.builder(
                  itemCount: _feed.length,
                  itemBuilder: (context, index) {
                    final post = _feed[index];
                    final creator = post['creator'] ?? {};
                    return PostCard(
                      username: creator['displayName'] ?? 'Anonymous',
                      caption: post['caption'] ?? '',
                      quest: post['questDescription'] ?? '',
                      imageUrl: post['mediaUrl'] ?? '',
                      likes: post['likes'] ?? 0,
                      index: index,
                      timestamp: post['createdAt'] ?? '',
                      onMorePressed: () => {}, //TODO: Implement more
                    );
                  },
                ),
        ),
      ],
    );
  }
}
/* TODO:
Improved emptyview
logo and "no posts yet" text
Three dot menu to hide flag post
*/