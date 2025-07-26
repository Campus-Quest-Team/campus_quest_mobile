import 'package:flutter/material.dart';
import 'package:campus_quest/styles/theme.dart';
import 'package:campus_quest/screens/login_page.dart';
import 'package:campus_quest/api/users.dart'; // <-- Import your API function

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

  Future<void> handleRegister() async {
    try {
      final message = await registerUser(
        login: loginController.text,
        password: passwordController.text,
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        email: emailController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message!)));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
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
                    'Create Account',
                    style: TextStyle(
                      fontFamily: 'Boldmark',
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEFBF04),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Start your adventure!',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Poppins',
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: loginController,
                    decoration: const InputDecoration(hintText: 'Username'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(hintText: 'Password'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: firstNameController,
                    decoration: const InputDecoration(hintText: 'First Name'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: lastNameController,
                    decoration: const InputDecoration(hintText: 'Last Name'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(hintText: 'Email'),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: handleRegister,
                      child: const Text('Register'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    child: const Text('Already have an account? Login'),
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
