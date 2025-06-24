import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(
    ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X default
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(debugShowCheckedModeBanner: false, home: child);
      },
      child: const InstagramHomePage(), // or LoginPage(), etc.
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return InstagramHomePage();
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> login() async {
    final url = Uri.parse('http://localhost:3000/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': emailController.text,
        'password': passwordController.text,
      }),
    );

    final result = jsonDecode(response.body);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['message'])));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['message'])));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: login, child: Text('Login')),
          ],
        ),
      ),
    );
  }
}

class InstagramHomePage extends StatefulWidget {
  const InstagramHomePage({super.key});

  @override
  State<InstagramHomePage> createState() => _InstagramHomePageState();
}

class _InstagramHomePageState extends State<InstagramHomePage> {
  final PageController _pageController = PageController(
    initialPage: 1,
  ); // Feed in center
  int _selectedIndex = 0;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      const CameraPage(),
      FeedPage(
        onMessageIconPressed: () {
          _pageController.jumpToPage(2); // Navigate to MessagesPage
        },
      ),
      const MessagesPage(),
      const EditProfilePage(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index == 1 ? 0 : _selectedIndex;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        switch (index) {
          case 0:
            // Tap on 'Home' → Go to Feed
            _pageController.jumpToPage(1);
          case 2:
            // Tap on 'Add' → Go to Camera Page (left swipe)
            _pageController.jumpToPage(0);
          case 4:
            _pageController.jumpToPage(4); // Profile Page
        }

        setState(() {
          _selectedIndex = index;
        });
      },

      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_box_outlined),
          label: 'Add',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          label: 'Likes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.camera_alt, size: 100, color: Colors.grey),
    );
  }
}

class FeedPage extends StatelessWidget {
  final VoidCallback onMessageIconPressed;
  const FeedPage({super.key, required this.onMessageIconPressed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Campus Quest',
          style: TextStyle(
            fontFamily: 'Boldmark',
            fontSize: 28.sp,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.explore_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QuestPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: onMessageIconPressed,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return PostCard(index: index);
        },
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final int index;
  const PostCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const CircleAvatar(),
          title: Text(
            'user$index',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: const Icon(Icons.more_vert),
        ),
        Placeholder(fallbackHeight: 300.h),
        Padding(
          padding: EdgeInsets.all(8.w),
          child: Row(
            children: const [
              Icon(Icons.favorite_border),
              SizedBox(width: 12),
              Icon(Icons.comment),
              SizedBox(width: 12),
              Icon(Icons.send),
              Spacer(),
              Icon(Icons.bookmark_border),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: const Text(
            'Liked by user1 and others',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          child: Text('user$index: Caption goes here...'),
        ),
      ],
    );
  }
}

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.message, size: 100, color: Colors.grey),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  void saveProfile() {
    // Here you could send data to the backend or local storage
    String username = usernameController.text;
    String bio = bioController.text;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Profile updated: $username')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: BackButton(),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: saveProfile),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                // Add image picker logic later
              },
              child: CircleAvatar(
                radius: 50.r,
                backgroundColor: Colors.grey[300],
                child: const Icon(Icons.camera_alt, size: 40),
              ),
            ),
            SizedBox(height: 20.h),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: bioController,
              decoration: const InputDecoration(labelText: 'Bio'),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}

class QuestPage extends StatelessWidget {
  const QuestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> quests = [
      {
        'title': 'Find the Lost Compass',
        'description': 'Locate the legendary compass hidden in the old forest.',
      },
      {
        'title': 'Defeat the Shadow Beast',
        'description':
            'Face your fears and conquer the beast beneath the ruins.',
      },
      {
        'title': 'Deliver the Secret Scroll',
        'description':
            'Travel to the Mystic Tower and hand over the scroll safely.',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Quests'),
        leading: const Icon(Icons.explore_outlined),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: quests.length,
        separatorBuilder: (_, __) => SizedBox(height: 16.h),
        itemBuilder: (context, index) {
          final quest = quests[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quest['title']!,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    quest['description']!,
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 12.h),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Started: ${quest['title']}')),
                      );
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Quest'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
