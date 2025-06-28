import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:car_rental_app/config/constants.dart';

class ImageKitUploadService {
  static const String imageKitFolder = '/car_rental_app/documents';

  static Future<String?> uploadFile(File file) async {
    final bytes = await file.readAsBytes();
    final base64File = base64Encode(bytes);

    final response = await http.post(
      Uri.parse(AppConstants.imageKitUploadUrl),
      headers: {
        'Authorization':
            'Basic ${base64Encode(utf8.encode('${AppConstants.imageKitPrivateKey}:'))}',
      },
      body: {
        'file': base64File,
        'fileName': file.path.split('/').last,
        'folder': imageKitFolder,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['url'] as String?;
    } else {
      print('ImageKit upload failed: ${response.body}');
      return null;
    }
  }
}
