import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String?> uploadMedia(
  File file,
  String userId,
  String questId,
  String jwtToken,
) async {
  final url = Uri.parse('http://supercoolfun.site:5001/api/uploadMedia');
  final request = http.MultipartRequest('POST', url)
    ..fields['userId'] = userId
    ..fields['questId'] = questId
    ..fields['jwtToken'] = jwtToken
    ..files.add(await http.MultipartFile.fromPath('file', file.path));

  final response = await request.send();

  if (response.statusCode == 200) {
    final responseData = await response.stream.bytesToString();
    final result = jsonDecode(responseData);
    return result['fileUrl'];
  } else {
    return null;
  }
}

Future<bool> submitQuestPost({
  required String userId,
  required String questId,
  required String caption,
  required String questDescription,
  required String fileUrl,
  required String jwtToken,
}) async {
  final url = Uri.parse('http://supercoolfun.site:5001/api/submitPost');
  final body = jsonEncode({
    'userId': userId,
    'questId': questId,
    'caption': caption,
    'questDescription': questDescription,
    'file': fileUrl,
    'jwtToken': jwtToken,
  });

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: body,
  );

  return response.statusCode == 200;
}
