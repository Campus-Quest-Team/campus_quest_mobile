import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campus_quest/screens/home_page.dart';
import 'package:campus_quest/api/users.dart';
import 'package:campus_quest/services/save_credentials.dart';

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
  required bool rememberMe,
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
      if (rememberMe) {
        await saveLogin(username.text, passwordController.text);
      } else {
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
