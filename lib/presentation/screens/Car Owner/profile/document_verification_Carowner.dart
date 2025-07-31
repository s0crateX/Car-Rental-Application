import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../config/theme.dart';
import 'package:provider/provider.dart';
import 'package:car_rental_app/core/authentication/auth_service.dart';
import 'package:car_rental_app/core/services/image_upload_service.dart';
import 'package:car_rental_app/shared/common_widgets/snackbars/success_snackbar.dart';
import 'package:car_rental_app/shared/common_widgets/snackbars/error_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DocumentVerificationCarOwnerScreen extends StatefulWidget {
  const DocumentVerificationCarOwnerScreen({super.key});

  @override
  State<DocumentVerificationCarOwnerScreen> createState() =>
      _DocumentVerificationCarOwnerScreenState();
}

class _DocumentVerificationCarOwnerScreenState
    extends State<DocumentVerificationCarOwnerScreen>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Document field config: key, label, required, conditional
  final List<Map<String, dynamic>> documentFields = [
    {
      'key': 'government_id',
      'label': 'Owner\'s Government ID',
      'description': 'A valid government-issued ID of the registered owner. The name must match the registered profile name.',
      'required': true,
      'icon': 'assets/svg/id-card.svg',
    },
    {
      'key': 'mayors_permit',
      'label': "Mayor's / Business Permit",
      'description': 'Valid business permit from the local government unit.',
      'required': true,
      'icon': 'assets/svg/permit.svg',
    },
    {
      'key': 'bir_2303',
      'label': 'BIR Certificate (Form 2303)',
      'description': 'Official registration with the Bureau of Internal Revenue.',
      'required': true,
      'icon': 'assets/svg/tax.svg',
    },
    {
      'key': 'ltfrb_permit',
      'label': 'LTFRB Permit to Operate',
      'description': 'Required for vehicles used for public transport services (if applicable).',
      'required': false,
      'icon': 'assets/svg/legal.svg',
    },
  ];

  // Document state for each key
  final Map<String, Map<String, dynamic>> _documents = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    // Initialize all document keys
    for (final field in documentFields) {
      _documents[field['key']] = {'file': null, 'url': null, 'status': null};
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userData = Provider.of<AuthService>(context, listen: false).userData;
    final docData = userData?['documents'] as Map<String, dynamic>?;
    if (docData != null) {
      for (final key in _documents.keys) {
        if (docData[key] != null) {
          final url = docData[key]['url'] as String?;
          _documents[key]!['url'] = url;
          _documents[key]!['status'] =
              docData[key]['status'] ??
              ((url != null && url.isNotEmpty) ? 'Pending' : null);
        }
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Document Verification',
          style: TextStyle(
            fontSize: 20,
            color: AppTheme.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/svg/arrow-left.svg',
            colorFilter: const ColorFilter.mode(
              AppTheme.white,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildHeaderSection(),
                      const SizedBox(height: 24),
                      _buildProgressIndicator(),
                      const SizedBox(height: 24),
                      _buildSectionHeader('Required Documents', Icons.description, AppTheme.lightBlue),
                      const SizedBox(height: 16),
                      ...documentFields
                          .where((d) => d['required'] as bool)
                          .map((field) => Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: _buildEnhancedUploadCard(field),
                              )),
                      const SizedBox(height: 24),
                      _buildSectionHeader(
                          'Optional Documents', Icons.description_outlined, AppTheme.paleBlue),
                      const SizedBox(height: 16),
                      ...documentFields
                          .where((d) => !(d['required'] as bool))
                          .map((field) => Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: _buildEnhancedUploadCard(field),
                              )),
                      const SizedBox(height: 32),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.mediumBlue.withOpacity(0.2),
            AppTheme.navy.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.paleBlue.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.mediumBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.verified_user,
              color: AppTheme.paleBlue,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Organization Verification',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'To comply with regulations and ensure trust on our platform, please upload the required business documents for your organization.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.paleBlue, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final totalRequired =
        documentFields.where((field) => field['required'] as bool).length;

    final completedRequired = documentFields
        .where((field) =>
            field['required'] as bool && _isDocumentUploaded(field['key']))
        .length;

    final progress =
        totalRequired > 0 ? completedRequired / totalRequired : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Verification Progress',
              style: TextStyle(
                color: AppTheme.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            Text(
              '$completedRequired of $totalRequired Required',
              style: const TextStyle(
                color: AppTheme.paleBlue,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppTheme.darkNavy,
          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.lightBlue),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.white,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedUploadCard(Map<String, dynamic> field) {
    final documentType = field['key'];
    final doc = _documents[documentType]!;
    final File? imageFile = doc['file'] as File?;
    final String? url = doc['url'] as String?;
    final String? status = doc['status'] as String?;
    final bool isUploaded = _isDocumentUploaded(documentType);
    final bool isRequired = field['required'] as bool;

    String statusLabel = 'Not Uploaded';
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.upload_file;

    if (status == 'Pending') {
      statusLabel = 'Under Review';
      statusColor = Colors.orange;
      statusIcon = Icons.pending;
    } else if (status == 'Verified') {
      statusLabel = 'Verified';
      statusColor = Colors.green;
      statusIcon = Icons.verified;
    } else if (status == 'Rejected') {
      statusLabel = 'Rejected';
      statusColor = Colors.red;
      statusIcon = Icons.error;
    } else if (isUploaded) {
      statusLabel = 'Uploaded';
      statusColor = AppTheme.mediumBlue;
      statusIcon = Icons.check_circle;
    }

    return GestureDetector(
      onTap: _isUploading ? null : () => _handleUpload(documentType),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.navy,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isUploaded
                    ? statusColor.withOpacity(0.5)
                    : AppTheme.paleBlue.withOpacity(0.2),
            width: isUploaded ? 2 : 1,
          ),
          boxShadow:
              isUploaded
                  ? [
                      BoxShadow(
                        color: statusColor.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              field['label'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isRequired ? Colors.red : Colors.blue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isRequired ? 'Required' : 'Optional',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        field['description'] ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (isUploaded)
                  GestureDetector(
                    onTap: () => _showImagePreview(context, imageFile, url),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child:
                          imageFile != null
                              ? Image.file(
                                  imageFile,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                )
                              : url != null && url.isNotEmpty
                                  ? Image.network(
                                      url,
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 48,
                                          height: 48,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.error),
                                        );
                                      },
                                    )
                                  : const SizedBox(),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePreview(BuildContext context, File? imageFile, String? imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(8),
                child: imageFile != null
                    ? Image.file(imageFile, fit: BoxFit.contain)
                    : (imageUrl != null && imageUrl.isNotEmpty)
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, color: Colors.red, size: 80),
                          )
                        : const Icon(Icons.broken_image, color: Colors.grey, size: 80),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final requiredDocs = documentFields.where(
      (field) => field['required'] == true,
    );

    final hasAllRequired = requiredDocs.every(
      (field) => _isDocumentUploaded(field['key'] as String),
    );

    final hasAnyDocuments = _documents.values.any((doc) {
      final file = doc['file'] as File?;
      final url = doc['url'] as String?;
      return file != null || (url != null && url.isNotEmpty);
    });

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (_isUploading || !hasAnyDocuments) ? null : _submitDocuments,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              hasAllRequired
                  ? AppTheme.mediumBlue
                  : hasAnyDocuments
                  ? AppTheme.mediumBlue.withOpacity(0.7)
                  : Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 18),
          elevation: hasAnyDocuments ? 4 : 0,
          shadowColor: AppTheme.mediumBlue.withOpacity(0.3),
        ),
        child:
            _isUploading
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      hasAllRequired ? Icons.verified : Icons.upload,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      hasAllRequired
                          ? 'Submit for Verification'
                          : 'Submit Available Documents',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  bool _isDocumentUploaded(String documentType) {
    final doc = _documents[documentType]!;
    final File? imageFile = doc['file'] as File?;
    final String? url = doc['url'] as String?;
    return imageFile != null || (url != null && url.isNotEmpty);
  }

  void _handleUpload(String documentType) async {
    final ImageSource? source = await _showImageSourceDialog();
    if (source == null) return;

    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (picked != null) {
      setState(() {
        _documents[documentType]!['file'] = File(picked.path);
        _documents[documentType]!['url'] = null;
        _documents[documentType]!['status'] = 'Pending';
      });
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppTheme.navy,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.paleBlue.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Select Image Source',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.white,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildSourceOption(
                        icon: Icons.camera_alt,
                        label: 'Camera',
                        onTap: () => Navigator.pop(context, ImageSource.camera),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSourceOption(
                        icon: Icons.photo_library,
                        label: 'Gallery',
                        onTap:
                            () => Navigator.pop(context, ImageSource.gallery),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppTheme.darkNavy,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.paleBlue.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.paleBlue, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitDocuments() async {
    setState(() => _isUploading = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final uid = authService.user?.uid;
      if (uid == null) throw Exception('User not logged in');

      final Map<String, dynamic> documentData = {};
      for (final entry in _documents.entries) {
        final docType = entry.key;
        final file = entry.value['file'] as File?;
        String? url = entry.value['url'] as String?;
        String? status = entry.value['status'] as String?;

        if (file != null) {
          url = await ImageUploadService.uploadProfileImage(file);
          status = 'Pending';
        }

        if (url != null) {
          documentData[docType] = {'url': url, 'status': status ?? 'Pending'};
        }
      }

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'documents': documentData,
        'documentsSubmitted': true,
        'documentsSubmittedAt': DateTime.now(),
      }, SetOptions(merge: true));

      if (mounted) {
        SuccessSnackbar.show(
          context: context,
          message:
              'Documents submitted successfully! We\'ll review them within 24-48 hours.',
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorSnackbar.show(
          context: context,
          message: 'Failed to submit documents. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<String?> _uploadToStorage(File imageFile, String documentType) async {
    // Placeholder for actual upload logic
    // Replace this with your Firebase/ImageKit upload implementation
    return 'https://example.com/images/$documentType-${DateTime.now().millisecondsSinceEpoch}.jpg';
  }
}
