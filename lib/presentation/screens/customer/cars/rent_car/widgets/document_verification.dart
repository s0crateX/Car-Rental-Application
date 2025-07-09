// Note: Consider renaming this file to document_verification.dart
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:car_rental_app/config/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/authentication/auth_service.dart';

class DocumentVerificationSection extends StatefulWidget {
  final Map<String, dynamic>? userDocuments;
  final VoidCallback onDocumentUploaded;

  const DocumentVerificationSection({
    Key? key,
    required this.userDocuments,
    required this.onDocumentUploaded,
  }) : super(key: key);

  @override
  _DocumentVerificationSectionState createState() =>
      _DocumentVerificationSectionState();
}

class _DocumentVerificationSectionState
    extends State<DocumentVerificationSection> {
  late AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = Provider.of<AuthService>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildVerificationStatus(),
        const SizedBox(height: 16),
        _buildDocumentGrid(),
      ],
    );
  }

  String _getDocumentStatus(String documentId) {
    if (widget.userDocuments == null ||
        !widget.userDocuments!.containsKey(documentId)) {
      return 'missing';
    }
    return widget.userDocuments![documentId]['status'] ?? 'pending';
  }

  String? _getDocumentUrl(String documentId) {
    if (widget.userDocuments == null ||
        !widget.userDocuments!.containsKey(documentId)) {
      return null;
    }
    return widget.userDocuments![documentId]['url'];
  }

  Widget _buildVerificationStatus() {
    final List<String> documentTypes = [
      'government_id',
      'license_front',
      'license_back',
      'selfie_with_license',
    ];

    int uploadedCount = 0;
    for (String docType in documentTypes) {
      final String status = _getDocumentStatus(docType);
      if (status.toLowerCase() == 'approved' ||
          status.toLowerCase() == 'verified') {
        uploadedCount++;
      }
    }

    double progress =
        documentTypes.isNotEmpty ? uploadedCount / documentTypes.length : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verification Progress: $uploadedCount of ${documentTypes.length} documents approved',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
        ),
      ],
    );
  }

  Widget _buildDocumentGrid() {
    final List<String> documentTypes = [
      'government_id',
      'license_front',
      'license_back',
      'selfie_with_license',
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: documentTypes.length,
      itemBuilder: (context, index) {
        final docType = documentTypes[index];
        return _buildDocumentCard(
          title: _getDocumentTitle(docType),
          status: _getDocumentStatus(docType),
          imageUrl: _getDocumentUrl(docType),
          onUpload: () => _pickAndUploadDocument(docType),
          onTap: () {
            final imageUrl = _getDocumentUrl(docType);
            if (imageUrl != null) {
              _showDocumentDetails(docType, imageUrl);
            }
          },
        );
      },
    );
  }

  Widget _buildDocumentCard({
    required String title,
    required String status,
    String? imageUrl,
    required VoidCallback onUpload,
    required VoidCallback onTap,
  }) {
    bool isUploaded = imageUrl != null && imageUrl.isNotEmpty;
    return GestureDetector(
      onTap: isUploaded ? onTap : onUpload,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.navy,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child:
                    isUploaded
                        ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                          errorWidget:
                              (context, url, error) => const Icon(Icons.error),
                        )
                        : Container(
                          color: Colors.grey[200],
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.upload_file,
                                size: 40,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Upload',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  _buildStatusChip(status),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDocumentTitle(String docType) {
    switch (docType) {
      case 'government_id':
        return 'Government ID';
      case 'license_front':
        return 'License (Front)';
      case 'license_back':
        return 'License (Back)';
      case 'selfie_with_license':
        return 'Selfie with License';
      default:
        return 'Document';
    }
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    IconData iconData;
    String statusText = status.toLowerCase();

    switch (statusText) {
      case 'approved':
      case 'verified':
        chipColor = Colors.green;
        iconData = Icons.check_circle;
        break;
      case 'rejected':
        chipColor = Colors.red;
        iconData = Icons.cancel;
        break;
      case 'pending':
        chipColor = Colors.orange;
        iconData = Icons.pending;
        break;
      default:
        chipColor = Colors.grey;
        iconData = Icons.help_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 14, color: chipColor),
          const SizedBox(width: 4),
          Text(
            statusText.substring(0, 1).toUpperCase() + statusText.substring(1),
            style: TextStyle(fontSize: 12, color: chipColor),
          ),
        ],
      ),
    );
  }

  void _showDocumentDetails(String docType, String imageUrl) {
    // Simplified display, dialogs to be added back later.
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InteractiveViewer(
                child: CachedNetworkImage(imageUrl: imageUrl),
              ),
            ),
          ),
    );
  }

  Future<void> _pickAndUploadDocument(String documentType) async {
    try {
      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );

      if (image == null) return;

      final String? userId = _authService.user?.uid;
      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Authentication Error: No user logged in.'),
            ),
          );
        }
        return;
      }

      final storageRef = FirebaseStorage.instance.ref().child(
        'users/$userId/documents/$documentType.jpg',
      );

      final uploadTask = storageRef.putFile(File(image.path));
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      final docData = {
        'url': downloadUrl,
        'status': 'pending',
        'uploadedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'documents': {documentType: docData},
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Success: Document uploaded.')),
        );
      }

      widget.onDocumentUploaded();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload Failed: $e')));
      }
    }
  }
}
