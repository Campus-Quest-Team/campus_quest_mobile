import 'package:flutter/material.dart';
import 'package:campus_quest/widgets/post_card.dart';

class FeedBody extends StatelessWidget {
  final VoidCallback onQuestTap;
  final VoidCallback onProfileTap;

  const FeedBody({
    super.key,
    required this.onQuestTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          automaticallyImplyLeading: false, // disables default back button
          title: const Text('Campus Quest'),
          centerTitle: false,
          titleSpacing: 16,
          actions: [
            IconButton(
              icon: const Icon(Icons.explore_outlined, size: 30),
              onPressed: onQuestTap,
            ),
            IconButton(
              icon: const Icon(Icons.person, size: 30),
              onPressed: onProfileTap,
            ),
          ],
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
          elevation: Theme.of(context).appBarTheme.elevation,
        ),

        Expanded(
          child: ListView.builder(
            itemCount: 3,
            itemBuilder: (context, index) => PostCard(
              username: 'User1234',
              caption: 'Caption words and stuff',
              quest: 'COMPLETE THE QUEST',
              imageUrl:
                  'https://graduate.ucf.edu/wp-content/uploads/sites/8/2023/05/Admitted-Students-Page.jpg',
              likes: 327,
              index: index,
            ),
          ),
        ),
      ],
    );
  }
}
