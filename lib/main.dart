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
      child: const LoginPage(), // or LoginPage(), etc.
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
  final username = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> login() async {
    final url = Uri.parse('http://supercoolfun.site:5001/api/login');
    final body = jsonEncode({
      'username': username.text,
      'password': passwordController.text,
    });
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    Map<String, dynamic> result = {};
    try {
      if (response.body.isNotEmpty) {
        result = jsonDecode(response.body);
      }
    } catch (e) {
      result = {'message': response.body};
      print(result);
    }
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Login successful')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => InstagramHomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Login failed')),
      );
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
              controller: username,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: login, child: Text('Login')),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegisterPage(),
                  ), // make sure RegisterPage is imported
                );
              },
              child: Text("Don't have an account? Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final loginController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();

  Future<void> register() async {
    final url = Uri.parse(
      'http://supercoolfun.site:5001/api/register',
    ); // replace with actual API endpoint

    final body = jsonEncode({
      "login": loginController.text,
      "password": passwordController.text,
      "firstName": firstNameController.text,
      "lastName": lastNameController.text,
      "email": emailController.text,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Registration successful'),
          ),
        );
        Navigator.pop(context); // Go back to login or home
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Registration failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: loginController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
              ),
              TextField(
                controller: firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
              ),
              TextField(
                controller: lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: register, child: Text('Register')),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ), // make sure RegisterPage is imported
                  );
                },
                child: Text("Have an account? Login"),
              ),
            ],
          ),
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
        onProfileIconPressed: () {
          _pageController.jumpToPage(4); // Navigate to MessagesPage
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
      //bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

/*
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
  */
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
  final VoidCallback onProfileIconPressed;
  const FeedPage({super.key, required this.onProfileIconPressed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.explore_outlined, size: 35), // Quests button
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QuestPage()),
            );
          },
        ),
        title: Text(
          'CAMPUS QUEST',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'Boldmark',
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        toolbarHeight: 75,

        actions: [
          IconButton(
            icon: const Icon(Icons.person, size: 35),
            onPressed: onProfileIconPressed,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) {
          return PostCard(
            username: 'User1234',
            caption: 'Caption words and stuff',
            quest: 'COMPLETE THE QUEST',
            imageUrl:
                'https://graduate.ucf.edu/wp-content/uploads/sites/8/2023/05/Admitted-Students-Page.jpg',
            likes: 327,
            index: index,
          );
        },
      ),
      backgroundColor: const Color.fromARGB(217, 217, 217, 217),
    );
  }
}

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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //user info and flag
            Row(
              children: [
                const Icon(
                  Icons.account_circle_outlined,
                  size: 28,
                ), //replace with profile picture?
                const SizedBox(width: 5),
                Text(
                  username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.outlined_flag, size: 24),
              ],
            ),
            const SizedBox(height: 12),
            //Quest title
            Text(
              quest,
              //index % 2 == 0 ? 'FIND THE HORSEMAN' : 'WHERE IS KNIGHTRO?',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 12),
            //image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                //Placehodler if image fails to load
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
            const SizedBox(height: 12),
            //likes and caption row
            Row(
              children: [
                const Icon(Icons.favorite_border, size: 24),
                const SizedBox(width: 6),
                Text(
                  '$likes',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                Expanded(
                  child: Text(
                    caption,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    /*
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
    */
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
        title: const Text(
          'Your Quests',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'Boldmark',
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        leading: const Icon(Icons.explore_outlined, size: 35),
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
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Started: ${quest['title']}'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start Quest'),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.camera_alt, size: 24),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CameraPage()),
                          );
                        },
                      ),
                    ],
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
