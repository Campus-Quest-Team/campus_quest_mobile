import 'package:campus_quest/screens/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveLogin(String username, String password) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('savedLogin', username);
  await prefs.setString('savedPassword', password);
}

Future<Map<String, String>> getLogin(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  String? savedLogin = prefs.getString('savedLogin');
  String? savedPassword = prefs.getString('savedPassword');
  if (savedLogin == null || savedPassword == null) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(autoLogin: false),
      ),
    );
  }

  return {'username': savedLogin ?? '', 'password': savedPassword ?? ''};
}

Future<void> removeLogin() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('savedLogin');
  await prefs.remove('savedPassword');
  await prefs.remove('accessToken');
  await prefs.remove('userId');
}

Future<void> saveToken(String token, String userId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('accessToken', token);
  await prefs.setString('userId', userId);
}

//get userId and token from shared preferences
Future<Map<String, String>> getToken(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('userId');
  String? token = prefs.getString('accessToken');

  if (userId == null || token == null) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }
  return {'userId': userId ?? '', 'accessToken': token ?? ''};
}
