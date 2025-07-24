import 'package:campus_quest/screens/home_bodies/feed_body.dart';
import 'package:campus_quest/screens/home_bodies/profile_body.dart';
import 'package:campus_quest/styles/theme.dart';
import 'package:flutter/material.dart';
import 'package:campus_quest/screens/home_bodies/quest_body.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 1);
  }

  void _goToQuestPage() => _controller.animateToPage(
    0,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
  );

  void _goToProfilePage() => _controller.animateToPage(
    2,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: backgroundGradient,
      child: PageView(
        controller: _controller,
        children: [
          QuestBody(
            onBackToFeedTap: () => _controller.animateToPage(
              1,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
          ),
          FeedBody(onQuestTap: _goToQuestPage, onProfileTap: _goToProfilePage),
          ProfileBody(
            onBackToFeedTap: () => _controller.animateToPage(
              1,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
          ),
        ],
      ),
    );
  }
}
