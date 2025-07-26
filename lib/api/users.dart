import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, String>?> loginUser({
  required String login,
  required String password,
}) async {
  final url = Uri.parse('http://supercoolfun.site:5001/api/login');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'login': login, 'password': password}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data.containsKey('accessToken') && data.containsKey('userId')) {
      return {'accessToken': data['accessToken'], 'userId': data['userId']};
    }
  }

  return null;
}

Future<String?> registerUser({
  required String login,
  required String password,
  required String firstName,
  required String lastName,
  required String email,
}) async {
  final url = Uri.parse('http://supercoolfun.site:5001/api/register');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'login': login,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
    }),
  );

  final data = jsonDecode(response.body);
  if (response.statusCode == 200) {
    return data['message'] ?? 'Registration successful';
  } else {
    throw Exception(data['message'] ?? 'Registration failed');
  }
}

Future<Map<String, dynamic>?> getProfile({
  required String userId,
  required String jwtToken,
}) async {
  final url = Uri.parse('http://supercoolfun.site:5001/api/getProfile');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'userId': userId, 'jwtToken': jwtToken}),
  );
  print('Response status: ${response.statusCode}');
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print('User profile fetched successfully: $data');
    return data['profileData'];
  } else {
    print('Error fetching user profile: ${response.body}');
    return null;
  }
}
