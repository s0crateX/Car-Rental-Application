import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../config/constants.dart';

class ImageUploadService {
  /// Uploads an image file to ImageKit and returns the image URL on success.
  static Future<String?> uploadImage(
    File imageFile, {
    String? folder,
    String? customFileName,
  }) async {
    final uri = Uri.parse(AppConstants.imageKitUploadUrl);
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    final fileName = customFileName ?? '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';

    final request = http.MultipartRequest('POST', uri)
      ..fields['file'] = base64Image
      ..fields['fileName'] = fileName
      ..fields['useUniqueFileName'] = 'true';

    // Add folder if specified
    if (folder != null && folder.isNotEmpty) {
      request.fields['folder'] = folder;
    }

    // Add HTTP Basic Auth header with private key (password is blank)
    final privateKey = AppConstants.imageKitPrivateKey;
    final authHeader = 'Basic ${base64Encode(utf8.encode('$privateKey:'))}';
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
      rethrow;
    }
  }

  /// Deletes a file from ImageKit using the file URL
  static Future<bool> deleteImage(String fileUrl) async {
    try {
      // Extract file ID from URL (assuming the URL is in the format: https://ik.imagekit.io/your_imagekit_id/rest_of_path/filename.jpg)
      final fileId = fileUrl.split('/').last.split('.').first;
      
      final uri = Uri.parse('https://api.imagekit.io/v1/files/$fileId');
      
      final headers = {
        'Authorization': 'Basic ${base64Encode(utf8.encode('${AppConstants.imageKitPrivateKey}:'))}',
        'Content-Type': 'application/json',
      };
      
      final response = await http.delete(uri, headers: headers);
      
      if (response.statusCode == 204) {
        return true;
      } else {
        print('ImageKit delete failed: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('ImageKit delete error: $e');
      rethrow;
    }
  }

  /// For backward compatibility
  static Future<String?> uploadProfileImage(File imageFile) {
    return uploadImage(imageFile, folder: 'profile_images');
  }

  /// Upload car image to the car_rental_app/documents folder
  static Future<String?> uploadCarImage(File imageFile, String carId) {
    // Generate a unique filename with timestamp to prevent conflicts
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = imageFile.path.split('.').last.toLowerCase();
    final fileName = 'car_${carId}_$timestamp.$extension';
    
    // Upload to the car_rental_app/documents folder
    return uploadImage(
      imageFile, 
      folder: 'car_rental_app/documents',
      customFileName: fileName,
    );
  }
}
