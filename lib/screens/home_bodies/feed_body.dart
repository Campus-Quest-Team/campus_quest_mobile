import 'package:campus_quest/services/saved_credentials.dart';
import 'package:flutter/material.dart';
import 'package:campus_quest/widgets/post_card.dart';
import 'package:campus_quest/api/posts.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

class _FeedBodyState extends State<FeedBody>
    with AutomaticKeepAliveClientMixin {
  List<Map<String, dynamic>> _feed = [];
  bool _isLoading = true;
  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    fetchFeed();
  }

  Future<void> fetchFeed() async {
    final token = await getToken(context);
    final userId = token['userId'];
    final jwtToken = token['accessToken'];

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
    print('Feed fetched: ${_feed.length} posts');
  }

  Future<void> _toggleLike(int index) async {
    final post = _feed[index];
    final credentials = await getToken(context);
    final userId = credentials['userId'];
    final jwtToken = credentials['accessToken'];

    if (userId != null && jwtToken != null) {
      final response = await likePost(
        userId: userId,
        questPostId: post['postId'],
        jwtToken: jwtToken,
      );

      if (response != null && response['success'] == true) {
        setState(() {
          _feed[index]['likes'] = response['likeCount'];
          _feed[index]['liked'] = response['liked'];
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to toggle like')));
      }
    }
  }

  Future<void> _flagPost(int index) async {
    final post = _feed[index];
    final credentials = await getToken(context);
    final userId = credentials['userId'];
    final jwtToken = credentials['accessToken'];

    if (userId != null && jwtToken != null) {
      final response = await flagPost(
        userId: userId,
        questPostId: post['postId'],
        jwtToken: jwtToken,
      );

      if (response != null && response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post flagged for review.')),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to flag post.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 12.0),
          child: SvgPicture.asset('assets/full_logo.svg', height: 50),
        ),
        centerTitle: false,
        titleSpacing: 0,
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _feed.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.hourglass_empty,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No posts yet.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _feed.length,
              itemBuilder: (context, index) {
                final post = _feed[index];
                final creator = post['creator'] ?? {};
                return Column(
                  children: [
                    PostCard(
                      username: creator['displayName'] ?? 'Anonymous',
                      profileImageUrl: creator['pfpUrl'] ?? '',
                      caption: post['caption'] ?? '',
                      quest: post['questDescription'] ?? '',
                      imageUrl: post['mediaUrl'] ?? '',
                      likes: post['likes'] ?? 0,
                      index: index,
                      timestamp: post['timeStamp'] ?? '',
                      onLikePressed: () => _toggleLike(index),
                      onMorePressed: () {
                        final parentContext =
                            context; // save valid Scaffold context

                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (context) => Wrap(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.hide_source),
                                title: const Text('Hide Post'),
                                onTap: () {
                                  Navigator.pop(context);
                                  setState(() => _feed.removeAt(index));
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.flag),
                                title: const Text('Flag Post'),
                                onTap: () async {
                                  Navigator.pop(context);
                                  await _flagPost(index);
                                  ScaffoldMessenger.of(
                                    parentContext,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text('Post flagged for review.'),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 12.h),
                  ],
                );
              },
            ),
    );
  }
}
