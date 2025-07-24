import 'package:flutter/material.dart';
import 'package:campus_quest/screens/home_page.dart';
import 'package:campus_quest/screens/register_page.dart';
import 'package:campus_quest/styles/theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final username = TextEditingController();
  final passwordController = TextEditingController();
  bool rememberMe = false;

  Future<void> login({bool isAuto = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final url = Uri.parse('http://supercoolfun.site:5001/api/login');

    final body = jsonEncode({
      'login': username.text,
      'password': passwordController.text,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.body.isEmpty) throw Exception("Empty response");
      final result = jsonDecode(response.body);

      if (result.containsKey('error')) {
        if (!isAuto) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['error'] ?? 'Login failed')),
          );
        }
        return;
      }

      if (result.containsKey('accessToken') && result.containsKey('userId')) {
        // Save credentials and token
        await prefs.setString('savedLogin', username.text);
        await prefs.setString('savedPassword', passwordController.text);
        await prefs.setString('accessToken', result['accessToken']);
        await prefs.setString('userId', result['userId']);

        if (!isAuto) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Login successful')));
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        if (!isAuto) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unexpected response format')),
          );
        }
      }
    } catch (e) {
      if (!isAuto) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    autoLogin();
  }

  Future<void> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLogin = prefs.getString('savedLogin');
    final savedPassword = prefs.getString('savedPassword');

    if (savedLogin != null && savedPassword != null) {
      username.text = savedLogin;
      passwordController.text = savedPassword;

      // Attempt silent login
      await login(isAuto: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: backgroundGradient,
      width: double.infinity,
      height: double.infinity,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8 > 500
                  ? 500
                  : MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 34,
                    offset: const Offset(0, 22),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Campus Quest',
                    style: TextStyle(
                      fontFamily: 'Boldmark',
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEFBF04),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Please log in to continue',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Poppins',
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: username,
                    decoration: const InputDecoration(labelText: 'Username'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: login,
                      child: const Text('Login'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  CheckboxListTile(
                    title: const Text("Remember this device"),
                    value: rememberMe,
                    onChanged: (value) {
                      setState(() {
                        rememberMe = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      );
                    },
                    child: const Text("Don't have an account? Sign Up"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
