import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../config/theme.dart';

class OwnerDocumentVerificationScreen extends StatefulWidget {
  const OwnerDocumentVerificationScreen({super.key});

  @override
  State<OwnerDocumentVerificationScreen> createState() => _OwnerDocumentVerificationScreenState();
}

class _OwnerDocumentVerificationScreenState extends State<OwnerDocumentVerificationScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  // Document state: {type: {files: [], urls: [], status}}
  final Map<String, Map<String, dynamic>> _documents = {
    'gov_id': {'files': null, 'urls': null, 'status': null},
    'selfie_with_id': {'files': null, 'urls': null, 'status': null},
    'proof_of_address': {'files': null, 'urls': null, 'status': null},
    'vehicle_docs': {'files': [], 'urls': [], 'status': null}, // Supports multiple files
    'drivers_license': {'files': null, 'urls': null, 'status': null},
  };

  // Check if a document type supports multiple files
  bool _supportsMultipleFiles(String documentType) => documentType == 'vehicle_docs';

  // If owner offers delivery/driving, show driver's license upload
  bool get _showDriversLicense => true; // TODO: Replace with actual logic

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      appBar: AppBar(
        backgroundColor: AppTheme.darkNavy,
        elevation: 0,
        title: const Text(
          'Upload & Verify Documents',
          style: TextStyle(fontSize: 20, color: AppTheme.white),
        ),
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/svg/arrow-left.svg',
            colorFilter: const ColorFilter.mode(AppTheme.white, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Government-Issued ID'),
              _buildUploadCard(
                title: 'Valid Government-Issued ID',
                icon: 'assets/svg/upload.svg',
                documentType: 'gov_id',
                description: 'Driver’s License, National ID, Passport, UMID',
                onTap: () => _pickImage('gov_id'),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Selfie with ID'),
              _buildUploadCard(
                title: 'Selfie with ID',
                icon: 'assets/svg/upload.svg',
                documentType: 'selfie_with_id',
                description: 'To verify the ID matches your face',
                onTap: () => _pickImage('selfie_with_id'),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Proof of Address'),
              _buildUploadCard(
                title: 'Proof of Address',
                icon: 'assets/svg/upload.svg',
                documentType: 'proof_of_address',
                description: 'Utility bill, Barangay certificate, or Lease agreement',
                onTap: () => _pickImage('proof_of_address'),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Vehicle Ownership Documents'),
              _buildUploadCard(
                title: 'OR/CR, Deed of Sale, Authorization Letter',
                icon: 'assets/svg/upload.svg',
                documentType: 'vehicle_docs',
                description: 'Upload all required vehicle ownership documents',
                onTap: () => _pickImage('vehicle_docs'),
              ),
              if (_showDriversLicense) ...[
                const SizedBox(height: 20),
                _buildSectionTitle('Driver’s License'),
                _buildUploadCard(
                  title: 'Driver’s License',
                  icon: 'assets/svg/upload.svg',
                  documentType: 'drivers_license',
                  description: 'Required if you offer delivery/driving',
                  onTap: () => _pickImage('drivers_license'),
                ),
              ],
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, color: AppTheme.paleBlue, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildUploadCard({
    required String title,
    required String icon,
    required String documentType,
    required String description,
    required VoidCallback onTap,
  }) {
    final doc = _documents[documentType]!;
    final files = doc['files'] as List<dynamic>?;
    final urls = doc['urls'] as List<dynamic>?;
    final hasDocument = (files != null && files.isNotEmpty) || (urls != null && urls.isNotEmpty);
    final supportsMultiple = _supportsMultipleFiles(documentType);
    final documentCount = (files?.length ?? 0) + (urls?.length ?? 0);

    return Card(
      color: AppTheme.mediumBlue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(icon, width: 32, height: 32, colorFilter: const ColorFilter.mode(AppTheme.paleBlue, BlendMode.srcIn)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(description, style: TextStyle(fontSize: 13, color: AppTheme.paleBlue.withOpacity(0.8))),
                      if (hasDocument) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.greenAccent, size: 18),
                            const SizedBox(width: 4),
                            Text('Uploaded', style: TextStyle(color: Colors.greenAccent, fontSize: 13)),
                          ],
                        ),
                      ],
                      if (doc['status'] != null) ...[
                        const SizedBox(height: 4),
                        Text('Status: ${doc['status']}', style: const TextStyle(fontSize: 13, color: Colors.amberAccent)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (hasDocument) ...[
              const SizedBox(height: 12),
              Text(
                supportsMultiple ? 'Uploaded Documents ($documentCount)' : 'Uploaded Document',
                style: TextStyle(
                  color: AppTheme.paleBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: documentCount,
                  itemBuilder: (context, index) {
                    final file = files != null && index < files.length ? files[index] as File? : null;
                    final url = urls != null && index >= (files?.length ?? 0) 
                        ? urls[index - (files?.length ?? 0)] as String? 
                        : null;
                    
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 160,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: GestureDetector(
                              onTap: () => _viewDocument(documentType, index),
                              child: file != null
                                  ? Image.file(file, fit: BoxFit.cover)
                                  : url != null
                                      ? Image.network(url, fit: BoxFit.cover)
                                      : Container(
                                          color: AppTheme.navy.withOpacity(0.5),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.image_not_supported, color: AppTheme.paleBlue),
                                              const SizedBox(height: 4),
                                              Text('Preview not available', 
                                                style: TextStyle(color: AppTheme.paleBlue, fontSize: 12)),
                                            ],
                                          ),
                                        ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _showDeleteConfirmation(documentType, index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              if (supportsMultiple) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: onTap,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.add, size: 16, color: AppTheme.paleBlue),
                    label: Text(
                      'Add another document',
                      style: TextStyle(color: AppTheme.paleBlue, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.paleBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      hasDocument ? 'Update' : 'Upload', 
                      style: const TextStyle(color: AppTheme.darkNavy, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                if (hasDocument) ...[
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => _showDeleteConfirmation(documentType),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isUploading ? null : _submitDocuments,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.mediumBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isUploading
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('Submit for Verification', style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }

  Future<void> _pickImage(String documentType) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        if (_supportsMultipleFiles(documentType)) {
          (_documents[documentType]!['files'] as List).add(File(picked.path));
        } else {
          _documents[documentType]!['files'] = [File(picked.path)];
        }
        _documents[documentType]!['status'] = 'Pending';
      });
    }
  }

  void _showDeleteConfirmation(String documentType, [int? index]) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Document'),
          content: Text(index == null 
              ? 'Are you sure you want to remove all documents?'
              : 'Are you sure you want to remove this document?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.paleBlue)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (index != null && _supportsMultipleFiles(documentType)) {
                    (_documents[documentType]!['files'] as List).removeAt(index);
                    if ((_documents[documentType]!['files'] as List).isEmpty) {
                      _documents[documentType] = {'files': null, 'urls': null, 'status': null};
                    }
                  } else {
                    _documents[documentType] = {'files': null, 'urls': null, 'status': null};
                  }
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Document removed')),
                );
              },
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _viewDocument(String documentType, [int index = 0]) {
    final doc = _documents[documentType]!;
    final files = doc['files'] as List<File>?;
    final urls = doc['urls'] as List<String>?;
    
    if ((files == null || files.isEmpty) && (urls == null || urls.isEmpty)) return;

    final file = files != null && files.isNotEmpty ? files[index] : null;
    final url = urls != null && urls.isNotEmpty ? urls[index] : null;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.navy,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Document ${_supportsMultipleFiles(documentType) ? '${index + 1} of ${(files?.length ?? urls?.length ?? 0)}' : ''}',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: file != null
                        ? Image.file(file, fit: BoxFit.contain)
                        : url != null
                            ? Image.network(url, fit: BoxFit.contain)
                            : const Center(child: Text('No preview available', style: TextStyle(color: Colors.white))),
                  ),
                  const SizedBox(height: 16),
                  if (_supportsMultipleFiles(documentType) && ((files?.length ?? 0) + (urls?.length ?? 0)) > 1) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                          onPressed: index > 0 ? () {
                            Navigator.of(context).pop();
                            _viewDocument(documentType, index - 1);
                          } : null,
                        ),
                        Text(
                          '${index + 1} / ${(files?.length ?? urls?.length ?? 0)}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                          onPressed: index < ((files?.length ?? urls?.length ?? 1) - 1) ? () {
                            Navigator.of(context).pop();
                            _viewDocument(documentType, index + 1);
                          } : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close', style: TextStyle(color: AppTheme.paleBlue)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitDocuments() async {
    setState(() => _isUploading = true);
    // TODO: Implement upload logic (API/Firebase)
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isUploading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Documents submitted for verification!')),
      );
    }
  }
}
