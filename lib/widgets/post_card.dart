import 'package:cached_network_image/cached_network_image.dart';
import 'package:campus_quest/api/friends.dart';
import 'package:campus_quest/services/saved_credentials.dart';
import 'package:campus_quest/widgets/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PostCard extends StatefulWidget {
  final String? username;
  final String? userId;
  final String? profileImageUrl;
  final String caption;
  final String quest;
  final String imageUrl;
  final int likes;
  final int index;
  final VoidCallback onMorePressed;
  final String timestamp;
  final VoidCallback? onLikePressed;

  const PostCard({
    super.key,
    this.username,
    this.userId,
    this.profileImageUrl,
    required this.caption,
    required this.quest,
    required this.imageUrl,
    required this.likes,
    required this.index,
    required this.timestamp,
    required this.onMorePressed,
    this.onLikePressed,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool liked = false;
  bool isFriend = false;
  bool _friendStatusChecked = false;
  @override
  void initState() {
    super.initState();
    _checkFriendStatus();
  }

  String _formatTimestamp(String rawTimestamp) {
    try {
      final postTime = DateTime.parse(rawTimestamp).toLocal();
      final now = DateTime.now();

      final isToday =
          postTime.year == now.year &&
          postTime.month == now.month &&
          postTime.day == now.day;

      if (isToday) {
        return DateFormat.jm().format(postTime); // e.g., 3:24 PM
      } else {
        return DateFormat.yMMMd().format(postTime); // e.g., Jul 24, 2025
      }
    } catch (_) {
      return '';
    }
  }

  Future<void> _checkFriendStatus() async {
    final credentials = await getToken(context);
    final userId = credentials['userId'];
    final jwtToken = credentials['accessToken'];
    final friendId = widget.userId;

    if (friendId == null || friendId == userId) return;

    final friends = await fetchFriends(userId: userId!, jwtToken: jwtToken!);
    setState(() {
      isFriend = friends?.any((f) => f['userId'] == friendId) ?? false;
      _friendStatusChecked = true;
    });
  }

  void _showFriendMenu(BuildContext context, Offset position) async {
    if (!_friendStatusChecked) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Loading friend status...')));
      return;
    }

    final credentials = await getToken(context);
    final userId = credentials['userId'];
    final jwtToken = credentials['accessToken'];
    final friendId = widget.userId;

    if (friendId == null || friendId == userId) return;

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx - 150, // shift left by ~150 pixels
        position.dy + 10,
        0,
        0,
      ),

      items: [
        PopupMenuItem(
          value: isFriend ? 'remove' : 'add',
          child: Text(isFriend ? 'Remove Friend' : 'Add Friend'),
        ),
      ],
    );

    if (selected == 'add') {
      final result = await addFriend(
        userId: userId!,
        friendId: friendId,
        jwtToken: jwtToken!,
      );
      if (result != null) {
        setState(() => isFriend = true);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Friend added!')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to add friend.')));
      }
    } else if (selected == 'remove') {
      final result = await removeFriend(
        userId: userId!,
        friendId: friendId,
        jwtToken: jwtToken!,
      );
      if (result != null) {
        setState(() => isFriend = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Friend removed!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to remove friend.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedTime = _formatTimestamp(widget.timestamp);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Profile Picture (conditionally shown)
              if (widget.username != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTapDown: (details) =>
                          _showFriendMenu(context, details.globalPosition),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.grey[200],
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: widget.profileImageUrl ?? '',
                            fit: BoxFit.cover,
                            width: 32,
                            height: 32,
                            errorWidget: (context, url, error) => const Icon(
                              Icons.person,
                              size: 18,
                              color: Colors.white,
                            ),
                            placeholder: (context, url) => const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 5),
                    Text(
                      widget.username!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                )
              else
                SizedBox(width: 10.w),

              const SizedBox(width: 8),

              // Quest title always shown, takes remaining space
              ExpandableText(
                widget.quest,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black87,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),

        // Image
        ClipRRect(
          borderRadius: BorderRadius.circular(0),
          child: CachedNetworkImage(
            imageUrl: widget.imageUrl,
            width: double.infinity,
            height: 300,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) => Container(
              height: 300,
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
              ),
            ),
            placeholder: (context, url) => Container(
              height: 300,
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
        ),

        // Interaction Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  widget.onLikePressed?.call();
                  setState(() {
                    liked = !liked;
                  });
                },
                child: Icon(
                  liked ? Icons.favorite : Icons.favorite_border,
                  color: liked ? Colors.red : Colors.black,
                  size: 24,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                "${widget.likes}",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 12),

              // Timestamp + Caption using ExpandableText
              Expanded(
                child: ExpandableText(
                  '$formattedTime: ${widget.caption}',
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                ),
              ),

              IconButton(
                icon: const Icon(Icons.more_vert, size: 20),
                onPressed: widget.onMorePressed,
                splashRadius: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
