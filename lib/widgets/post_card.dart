import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final String username;
  final String caption;
  final String quest;
  final String imageUrl;
  final int likes;
  final int index;

  const PostCard({
    super.key,
    required this.username,
    required this.caption,
    required this.quest,
    required this.imageUrl,
    required this.likes,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.grey,
                radius: 14,
                child: Icon(Icons.person, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Text(
                username,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.outlined_flag, size: 20),
                onPressed: () {},
                splashRadius: 20,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Quest Title
          Text(
            quest.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 0.5,
              color: Color(0xFF213547),
            ),
          ),
          const SizedBox(height: 10),

          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // Footer
          Row(
            children: [
              const Icon(Icons.favorite_border, size: 20),
              const SizedBox(width: 6),
              Text(
                '$likes likes',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.comment_outlined, size: 20),
                onPressed: () {},
                splashRadius: 20,
              ),
            ],
          ),

          // Caption
          if (caption.isNotEmpty)
            Text(
              caption,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
        ],
      ),
    );
  }
}
