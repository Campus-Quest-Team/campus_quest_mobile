import 'package:flutter/material.dart';
import 'package:campus_quest/screens/home_page.dart';
import 'package:campus_quest/screens/register_page.dart';
import 'package:campus_quest/styles/theme.dart';
import 'package:campus_quest/services/login.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.autoLogin = false});

  final bool autoLogin;

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
    if (widget.autoLogin) {
      _tryAutoLogin();
    }
  }

  Future<void> _tryAutoLogin() async {
    if (await autoLogin(
      username: username,
      passwordController: passwordController,
      context: context,
    )) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      logOut();
    }
  }

  Future<void> _handleLogin() async {
    final success = await login(
      username: username,
      passwordController: passwordController,
      rememberMe: rememberMe,
    );

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Login failed')));
    }
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
              padding: const EdgeInsets.only(
                top: 0,
                bottom: 0,
                left: 25,
                right: 25,
              ),
              decoration: whiteCard,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset('assets/full_logo.svg', height: 120),
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    controller: username,
                    decoration: const InputDecoration(hintText: 'Username'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(hintText: 'Password'),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleLogin,
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