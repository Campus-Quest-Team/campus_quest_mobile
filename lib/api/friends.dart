import 'dart:convert';
import 'package:campus_quest/services/api_constants.dart';
import 'package:http/http.dart' as http;

Future<List<String>?> addFriend({
  required String userId,
  required String friendId,
  required String jwtToken,
}) async {
  final url = Uri.parse('${ApiConstants.baseUrl}/addFriend');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'userId': userId,
      'friendId': friendId,
      'jwtToken': jwtToken,
    }),
  );
  print(
    jsonEncode({'userId': userId, 'friendId': friendId, 'jwtToken': jwtToken}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return List<String>.from(data['friends'] ?? []);
  } else {
    print('Add friend failed: ${response.statusCode}');
    return null;
  }
}

Future<List<String>?> removeFriend({
  required String userId,
  required String friendId,
  required String jwtToken,
}) async {
  final url = Uri.parse('${ApiConstants.baseUrl}/removeFriend');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'userId': userId,
      'friendId': friendId,
      'jwtToken': jwtToken,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return List<String>.from(data['friends'] ?? []);
  } else {
    print('Remove friend failed: ${response.statusCode}');
    return null;
  }
}

Future<List<Map<String, dynamic>>?> fetchFriends({
  required String userId,
  required String jwtToken,
}) async {
  final url = Uri.parse('${ApiConstants.baseUrl}/fetchFriends');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'userId': userId, 'jwtToken': jwtToken}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['friends'] ?? []);
  } else {
    print('Fetch friends failed: ${response.statusCode}');
    return null;
  }
}
