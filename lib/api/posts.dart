import 'dart:io';
import 'dart:convert';
import 'package:campus_quest/services/login.dart';
import 'package:campus_quest/services/saved_credentials.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:campus_quest/services/api_constants.dart';

Future<bool> submitQuestPost({
  required BuildContext context,
  required String userId,
  required String questId,
  required String caption,
  required String questDescription,
  required File file,
  required String jwtToken,
  bool retrying = false, // Prevent infinite loops
}) async {
  final url = Uri.parse('${ApiConstants.baseUrl}/submitPost');

  final extension = file.path.split('.').last.toLowerCase();
  String? mimeType;

  switch (extension) {
    case 'jpg':
    case 'jpeg':
      mimeType = 'image/jpeg';
      break;
    case 'png':
      mimeType = 'image/png';
      break;
    case 'mp4':
      mimeType = 'video/mp4';
      break;
    default:
      return false;
  }

  final request = http.MultipartRequest('POST', url)
    ..fields['userId'] = userId
    ..fields['questId'] = questId
    ..fields['caption'] = caption
    ..fields['questDescription'] = questDescription
    ..fields['jwtToken'] = jwtToken
    ..files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: MediaType.parse(mimeType),
      ),
    );

  try {
    final streamedResponse = await request.send();
    final responseString = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode == 200) {
      final data = jsonDecode(responseString);

      if (data['error'] == 'The JWT is no longer valid' && !retrying) {
        await reLogin(context);

        return await submitQuestPost(
          context: context,
          userId: userId,
          questId: questId,
          caption: caption,
          questDescription: questDescription,
          file: file,
          jwtToken: jwtToken,
          retrying: true,
        );
      }

      return data['success'] == true;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}

Future<Map<String, dynamic>?> getCurrentQuest() async {
  final url = Uri.parse('${ApiConstants.baseUrl}/currentQuest');

  try {
    final response = await http.get(
      url,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        final currentQuest = data['currentQuest'];
        final questData = currentQuest['questData'];

        return {
          'questId': currentQuest['questId'],
          'questDescription': questData['questDescription'],
          'timestamp': data['timestamp'],
          'questData': questData,
        };
      }
    }
  } catch (e) {
    print('Error fetching current quest: $e');
  }

  return null;
}

Future<List<Map<String, dynamic>>?> getFeed({
  required BuildContext context,
  required String userId,
  required String jwtToken,
  bool retrying = false, // Prevent infinite loops
}) async {
  final url = Uri.parse('${ApiConstants.baseUrl}/getFeed');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'userId': userId, 'jwtToken': jwtToken}),
  );
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print(data);

    if (data['error'] == 'The JWT is no longer valid' && !retrying) {
      await reLogin(context);

      final tokenMap = await getToken(context);
      final newJwtToken = tokenMap['accessToken'];

      return await getFeed(
        context: context,
        userId: userId,
        jwtToken: newJwtToken ?? jwtToken,
        retrying: true,
      );
    }

    if (data.containsKey('feed')) {
      return List<Map<String, dynamic>>.from(data['feed']);
    }
  }

  return null;
}

Future<Map<String, dynamic>?> likePost({
  required String userId,
  required String questPostId,
  required String jwtToken,
}) async {
  final url = Uri.parse('${ApiConstants.baseUrl}/likePost');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'userId': userId,
      'questPostId': questPostId,
      'jwtToken': jwtToken,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print(data);
    return data;
  } else {
    print('Failed to like post: ${response.statusCode}');
    return null;
  }
}
