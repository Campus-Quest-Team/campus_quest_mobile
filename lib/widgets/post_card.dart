import 'package:cached_network_image/cached_network_image.dart';
import 'package:campus_quest/widgets/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PostCard extends StatefulWidget {
  final String? username;
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

  @override
  Widget build(BuildContext context) {
    final formattedTime = _formatTimestamp(widget.timestamp);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        if (widget.username != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
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
                        child: CircularProgressIndicator(strokeWidth: 1.5),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.username!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
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

              Text(
                "${widget.likes}",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 12),
              if (widget.username == null)
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: widget.onMorePressed,
                  splashRadius: 20,
                ),
              Flexible(
                child: ExpandableText(
                  widget.quest,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black87,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Caption with timestamp
        if (widget.caption.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87, fontSize: 14),
                children: [
                  TextSpan(
                    text: '[$formattedTime] ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  TextSpan(text: widget.caption),
                ],
              ),
            ),
          ),

        const Divider(height: 0, thickness: 0.4),
      ],
    );
  }
}
