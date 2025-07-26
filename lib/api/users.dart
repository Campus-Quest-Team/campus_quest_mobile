import 'dart:convert';
import 'package:campus_quest/services/api_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:http_parser/http_parser.dart';

Future<Map<String, String>?> loginUser({
  required String login,
  required String password,
}) async {
  final url = Uri.parse('${ApiConstants.baseUrl}/login');

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
  final url = Uri.parse('${ApiConstants.baseUrl}/register');

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
  final url = Uri.parse('${ApiConstants.baseUrl}/getProfile');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'userId': userId, 'jwtToken': jwtToken}),
  );
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['profileData'];
  } else {
    return null;
  }
}

Future<Map<String, dynamic>?> editPFP({
  required String userId,
  required File file,
  required String jwtToken,
}) async {
  final url = Uri.parse('${ApiConstants.baseUrl}/editPFP');

  final request = http.MultipartRequest('POST', url)
    ..fields['userId'] = userId
    ..fields['jwtToken'] = jwtToken
    ..files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: MediaType('image', 'jpeg'),
      ),
    );

  try {
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    final data = jsonDecode(responseBody);

    if (response.statusCode == 200 && data['success'] == true) {
      return data;
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

Future<Map<String, dynamic>?> toggleNotifications({
  required String userId,
  required String jwtToken,
}) async {
  final url = Uri.parse('${ApiConstants.baseUrl}/toggleNotifications');

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: jsonEncode({'userId': userId, 'jwtToken': jwtToken}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to toggle notifications: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('toggleNotifications error: $e');
    return null;
  }
}
