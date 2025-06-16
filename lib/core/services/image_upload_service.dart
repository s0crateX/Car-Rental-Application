import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../config/constants.dart';

class ImageUploadService {
  /// Uploads an image file to ImageKit and returns the image URL on success.
  static Future<String?> uploadProfileImage(File imageFile) async {
    final uri = Uri.parse(AppConstants.imageKitUploadUrl);
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final request = http.MultipartRequest('POST', uri)
      ..fields['file'] = base64Image
      ..fields['fileName'] = imageFile.path.split('/').last;
    // Do not send publicKey in fields for private key upload

    // Add HTTP Basic Auth header with private key (password is blank)
    final privateKey = AppConstants.imageKitPrivateKey;
    final authHeader = 'Basic ' + base64Encode(utf8.encode('$privateKey:'));
    request.headers['Authorization'] = authHeader;

    try {
      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        final respJson = jsonDecode(respStr);
        return respJson['url'] as String?;
      } else {
        print('ImageKit upload failed: ${response.statusCode}');
        print('Response: $respStr');
        return null;
      }
    } catch (e) {
      print('ImageKit upload error: $e');
      return null;
    }
  }
}
