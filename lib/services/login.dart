import 'package:flutter/material.dart';
import 'package:campus_quest/api/users.dart';
import 'package:campus_quest/services/saved_credentials.dart';

Future<bool> autoLogin({
  required BuildContext context,
  required TextEditingController username,
  required TextEditingController passwordController,
}) async {
  final savedCredentials = await getLogin(context);

  if (savedCredentials['username'] != null &&
      savedCredentials['password'] != null) {
    username.text = savedCredentials['username']!;
    passwordController.text = savedCredentials['password']!;
    return await login(
      username: username,
      passwordController: passwordController,
      rememberMe: true,
    );
  }
  return false;
}

Future<bool> login({
  required TextEditingController username,
  required TextEditingController passwordController,
  bool? rememberMe,
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
      return true;
    }
  } catch (e) {
    print('Login error: $e');
  }
  return false;
}

// If jwt token expired
Future<bool> reLogin(BuildContext context) async {
  // "error": "The JWT is no longer valid"
  final credentials = await getLogin(context);
  // Attempt login with saved credentials
  return await login(
    username: TextEditingController(text: credentials['username']),
    passwordController: TextEditingController(text: credentials['password']),
  );
}
