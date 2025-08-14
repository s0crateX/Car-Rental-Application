import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

import 'package:car_rental_app/config/constants.dart';

class ImageKitUploadService {
  static const String imageKitFolder = '/car_rental_app/documents';
  static const String contractFolder = '/car_rental_app/contracts';
  static const String termsAndConditionsFolder = '/car_rental_app/TermsAndCondition';

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

  /// Upload contract file (PDF or image) to the Contract folder in ImageKit
  static Future<String?> uploadContract(File file) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final bytes = await file.readAsBytes();
      final base64File = base64Encode(bytes);
      
      // Get file extension and validate supported formats
      final fileName = file.path.split('/').last;
      final fileExtension = fileName.split('.').last.toLowerCase();
      
      // Validate file type
      const supportedFormats = ['pdf', 'jpg', 'jpeg', 'png'];
      if (!supportedFormats.contains(fileExtension)) {
        throw Exception('Unsupported file format. Please use PDF, JPG, JPEG, or PNG.');
      }

      // Generate unique filename with user ID and timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = 'contract_${user.uid}_$timestamp.$fileExtension';

      final response = await http.post(
        Uri.parse(AppConstants.imageKitUploadUrl),
        headers: {
          'Authorization':
              'Basic ${base64Encode(utf8.encode('${AppConstants.imageKitPrivateKey}:'))}',
        },
        body: {
          'file': base64File,
          'fileName': uniqueFileName,
          'folder': contractFolder,
          'useUniqueFileName': 'false', // We're already making it unique
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['url'] as String?;
      } else {
        print('ImageKit contract upload failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error uploading contract: $e');
      rethrow;
    }
  }

  /// Upload terms and conditions file (PDF or image) to the TermsAndCondition folder in ImageKit
  static Future<String?> uploadTermsAndConditions(File file) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final bytes = await file.readAsBytes();
      final base64File = base64Encode(bytes);
      
      // Get file extension and validate supported formats
      final fileName = file.path.split('/').last;
      final fileExtension = fileName.split('.').last.toLowerCase();
      
      // Validate file type
      const supportedFormats = ['pdf', 'jpg', 'jpeg', 'png'];
      if (!supportedFormats.contains(fileExtension)) {
        throw Exception('Unsupported file format. Please use PDF, JPG, JPEG, or PNG.');
      }

      // Generate unique filename with user ID and timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = 'terms_${user.uid}_$timestamp.$fileExtension';

      final response = await http.post(
        Uri.parse(AppConstants.imageKitUploadUrl),
        headers: {
          'Authorization':
              'Basic ${base64Encode(utf8.encode('${AppConstants.imageKitPrivateKey}:'))}',
        },
        body: {
          'file': base64File,
          'fileName': uniqueFileName,
          'folder': termsAndConditionsFolder,
          'useUniqueFileName': 'false', // We're already making it unique
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['url'] as String?;
      } else {
        print('ImageKit terms and conditions upload failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error uploading terms and conditions: $e');
      rethrow;
    }
  }
}
