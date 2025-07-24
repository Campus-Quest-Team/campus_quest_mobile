import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

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
    ..files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: MediaType('image', 'jpeg'), // or png if applicable
      ),
    );
  try {
    final response = await request.send();

    final responseData = await response.stream.bytesToString();
    final result = jsonDecode(responseData);

    if (response.statusCode == 200 && result['fileUrl'] != null) {
      print('Upload response: $result');

      if (result['fileUrl'] != null) {
        return result['fileUrl'];
      } else {
        print('Upload error: ${result['error']}');
        return null;
      }
    } else {
      print('Upload failed: ${result['error'] ?? 'Unknown error'}');
      return null;
    }
  } catch (e) {
    print('Upload error: $e');
    return null;
  }
}

Future<bool> submitQuestPost({
  required String userId,
  required String questId,
  required String caption,
  required String questDescription,
  required File file,
  required String jwtToken,
}) async {
  final url = Uri.parse('http://supercoolfun.site:5001/api/submitPost');

  // 🔍 Detect file extension (e.g., .jpg, .png)
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
      print('Unsupported file extension: $extension');
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

    print('Submit response (${streamedResponse.statusCode}): $responseString');

    if (streamedResponse.statusCode == 200) {
      final data = jsonDecode(responseString);
      return data['success'] == true;
    } else {
      return false;
    }
  } catch (e) {
    print('Submit post error: $e');
    return false;
  }
}

Future<Map<String, dynamic>?> getCurrentQuest() async {
  final url = Uri.parse('http://supercoolfun.site:5001/api/currentQuest');

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
