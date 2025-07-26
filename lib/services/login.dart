import 'package:campus_quest/screens/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campus_quest/api/users.dart';
import 'package:campus_quest/services/saved_credentials.dart';

Future<void> autoLogin({
  required TextEditingController username,
  required TextEditingController passwordController,
  required BuildContext context,
  required void Function() onSuccess,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final savedLogin = prefs.getString('savedLogin');
  final savedPassword = prefs.getString('savedPassword');

  if (savedLogin != null && savedPassword != null) {
    username.text = savedLogin;
    passwordController.text = savedPassword;
    await login(
      username: username,
      passwordController: passwordController,
      rememberMe: true,
      context: context,
      isAuto: true,
      onSuccess: onSuccess,
    );
  }
}

Future<void> login({
  required TextEditingController username,
  required TextEditingController passwordController,
  bool? rememberMe,
  required BuildContext context,
  required void Function() onSuccess,
  bool isAuto = false,
}) async {
  try {
    final result = await loginUser(
      login: username.text,
      password: passwordController.text,
    );

    if (result != null) {
      if (rememberMe == true) {
        await saveLogin(username.text, passwordController.text);
      }
      if (rememberMe == false) {
        await removeLogin();
      }
      await saveToken(result['accessToken']!, result['userId']!);

      if (!isAuto && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login successful')));
      }

      if (context.mounted) {
        onSuccess();
      }
    } else {
      if (!isAuto && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login failed')));
      }
    }
  } catch (e) {
    if (!isAuto && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}

//get userId and token from shared preferences
Future<Map<String, String>> getUserCredentials(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('userId');
  String? token = prefs.getString('accessToken');

  if (userId == null || token == null) {
    await loginFallback(context);
    userId = prefs.getString('userId');
    token = prefs.getString('accessToken');
  }
  return {'userId': userId ?? '', 'accessToken': token ?? ''};
}

// If jwt token expired
Future<void> loginFallback(BuildContext context) async {
  final credentials = await getUserCredentials(context);
  // Attempt login with saved credentials
  await login(
    username: TextEditingController(text: credentials['userId']),
    passwordController: TextEditingController(text: credentials['accessToken']),
    context: context,
    isAuto: true,
    onSuccess: () {},
  );
}
