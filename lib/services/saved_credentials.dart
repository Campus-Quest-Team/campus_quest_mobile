import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveLogin(String username, String password) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('savedLogin', username);
  await prefs.setString('savedPassword', password);
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
