import 'dart:convert';
import 'dart:io';
import 'package:campus_quest/api/users.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:campus_quest/screens/login_page.dart';
import 'package:campus_quest/services/saved_credentials.dart';
import 'package:campus_quest/styles/theme.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  File? _profileImage;
  String? _profileImageUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final credentials = await getToken(context);
    final data = await getProfile(
      userId: credentials['userId']!,
      jwtToken: credentials['accessToken']!,
    );

    if (data != null && mounted) {
      setState(() {
        usernameController.text = data['displayName'] ?? '';
        bioController.text = data['bio'] ?? '';
        _profileImageUrl = data['pfp'] ?? null;
      });
    }
  }

  Future<Map<String, dynamic>?> editPFP({
    required String userId,
    required File file,
    required String jwtToken,
  }) async {
    final url = Uri.parse('http://supercoolfun.site:5001/api/editPFP');

    final request = http.MultipartRequest('POST', url)
      ..fields['userId'] = userId
      ..fields['jwtToken'] = jwtToken
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);

      if (response.statusCode == 200 && data['success'] == true) {
        print('PFP updated: ${data['pfpUrl']}');
        return data;
      } else {
        print('Failed to update PFP: $data');
        return null;
      }
    } catch (e) {
      print('editPFP error: $e');
      return null;
    }
  }

  Future<void> _saveProfileImage(File imageFile) async {
    final credentials = await getToken(context);
    final result = await editPFP(
      userId: credentials['userId']!,
      jwtToken: credentials['accessToken']!,
      file: imageFile,
    );

    if (result != null && mounted) {
      setState(() {
        _profileImageUrl = result['pfpUrl'];
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile picture updated!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile picture.')),
      );
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      await _saveProfileImage(File(pickedFile.path));
    }
  }

  void saveProfile() {
    String username = usernameController.text;
    String bio = bioController.text;

    if (_profileImage != null) {
      _saveProfileImage(_profileImage!);
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Profile updated: $username')));
  }

  void logout() async {
    await removeLogin();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: backgroundGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Settings'),
          leading: CloseButton(onPressed: () => Navigator.pop(context)),
          actions: [
            IconButton(icon: const Icon(Icons.check), onPressed: saveProfile),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : (_profileImageUrl != null
                            ? NetworkImage(_profileImageUrl!) as ImageProvider
                            : null),
                  child: (_profileImage == null && _profileImageUrl == null)
                      ? const Icon(Icons.camera_alt, size: 40)
                      : null,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: bioController,
                decoration: const InputDecoration(labelText: 'Bio'),
                maxLines: 3,
              ),
              SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notifications'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Privacy'),
                onTap: () {},
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFcc3333),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: logout,
                child: const Text("Logout"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
