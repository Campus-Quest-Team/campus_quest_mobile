import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PostCard extends StatelessWidget {
  final String? username;
  final String caption;
  final String quest;
  final String imageUrl;
  final int likes;
  final int index;
  final VoidCallback onMorePressed;
  final String timestamp;

  const PostCard({
    super.key,
    this.username,
    required this.caption,
    required this.quest,
    required this.imageUrl,
    required this.likes,
    required this.index,
    required this.timestamp,
    required this.onMorePressed,
  });

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
    final formattedTime = _formatTimestamp(timestamp);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        if (username != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 18, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    username!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onPressed: onMorePressed,
                  splashRadius: 20,
                ),
              ],
            ),
          ),

        // Image
        ClipRRect(
          borderRadius: BorderRadius.circular(0),
          child: Image.network(
            imageUrl,
            width: double.infinity,
            height: 300,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 300,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                ),
              );
            },
          ),
        ),

        // Interaction Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.favorite_border, size: 24),
              Text(
                "$likes",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 12),
              username == null
                  ? IconButton(
                      icon: const Icon(Icons.more_horiz),
                      onPressed: onMorePressed,
                      splashRadius: 20,
                    )
                  : const Icon(Icons.chat_bubble_outline, size: 24),
              const Spacer(),
              Text(
                quest.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Caption with timestamp
        if (caption.isNotEmpty)
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
                  TextSpan(text: caption),
                ],
              ),
            ),
          ),

        const Divider(height: 0, thickness: 0.4),
      ],
    );
  }
}
