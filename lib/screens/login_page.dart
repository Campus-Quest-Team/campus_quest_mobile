import 'package:flutter/material.dart';
import 'package:campus_quest/screens/home_page.dart';
import 'package:campus_quest/screens/register_page.dart';
import 'package:campus_quest/styles/theme.dart';
import 'package:campus_quest/services/login.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final username = TextEditingController();
  final passwordController = TextEditingController();
  bool rememberMe = false;

  @override
  void initState() {
    super.initState();
    autoLogin(
      username: username,
      passwordController: passwordController,
      context: context,
      onSuccess: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: backgroundGradient,
        child: Center(
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
                    color: Colors.black.withAlpha(51),
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
                      onPressed: () {
                        login(
                          username: username,
                          passwordController: passwordController,
                          rememberMe: rememberMe,
                          context: context,
                          onSuccess: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HomePage(),
                              ),
                            );
                          },
                        );
                      },
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
/*
focused labels should be readable and not grey
*/