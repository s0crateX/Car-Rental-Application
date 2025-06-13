import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../config/theme.dart';

class DocumentVerificationScreen extends StatefulWidget {
  const DocumentVerificationScreen({super.key});

  @override
  State<DocumentVerificationScreen> createState() => _DocumentVerificationScreenState();
}

class _DocumentVerificationScreenState extends State<DocumentVerificationScreen> {
  // Image picker instance
  final ImagePicker _picker = ImagePicker();
  
  // Track uploaded images
  File? _driverLicenseFrontImage;
  File? _driverLicenseBackImage;
  File? _governmentIdImage;
  File? _selfieWithLicenseImage;
  
  // Track upload status for each document
  bool _driverLicenseFrontUploaded = false;
  bool _driverLicenseBackUploaded = false;
  bool _governmentIdUploaded = false;
  bool _selfieWithLicenseUploaded = false;
  
  // Track if images are currently uploading
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      appBar: AppBar(
        backgroundColor: AppTheme.darkNavy,
        elevation: 0,
        title: const Text(
          'Document Verification',
          style: TextStyle(
            fontSize: 20,
            color: AppTheme.white,
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(),
              const SizedBox(height: 24),
              _buildSectionTitle('Driver\'s License'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildUploadCard(
                      title: 'Front Side',
                      icon: 'assets/svg/upload.svg',
                      isUploaded: _driverLicenseFrontUploaded,
                      onTap: () => _handleUpload('license_front'),
                      documentType: 'license_front',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildUploadCard(
                      title: 'Back Side',
                      icon: 'assets/svg/upload.svg',
                      isUploaded: _driverLicenseBackUploaded,
                      onTap: () => _handleUpload('license_back'),
                      documentType: 'license_back',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Government-Issued ID'),
              const SizedBox(height: 4),
              Text(
                'Passport, National ID, SSS, or UMID',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.paleBlue.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 12),
              _buildUploadCard(
                title: 'Upload ID',
                icon: 'assets/svg/note.svg',
                isUploaded: _governmentIdUploaded,
                onTap: () => _handleUpload('government_id'),
                documentType: 'government_id',
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Selfie with Driver\'s License'),
              const SizedBox(height: 4),
              Text(
                'For identity and document match verification',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.paleBlue.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 12),
              _buildUploadCard(
                title: 'Take Selfie with ID',
                icon: 'assets/svg/camera.svg',
                isUploaded: _selfieWithLicenseUploaded,
                onTap: () => _handleUpload('selfie_with_license'),
                documentType: 'selfie_with_license',
              ),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.navy.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.mediumBlue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.navy,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SvgPicture.asset(
              'assets/svg/alert-square-rounded.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                AppTheme.lightBlue,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Document Requirements',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'All documents must be valid, not expired, and clearly visible. Your name must match across all documents.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.paleBlue.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppTheme.white,
      ),
    );
  }

  Widget _buildUploadCard({
    required String title,
    required String icon,
    required bool isUploaded,
    required VoidCallback onTap,
    String documentType = '',
  }) {
    File? imageFile;
    
    // Get the correct image file based on document type
    switch (documentType) {
      case 'license_front':
        imageFile = _driverLicenseFrontImage;
        break;
      case 'license_back':
        imageFile = _driverLicenseBackImage;
        break;
      case 'government_id':
        imageFile = _governmentIdImage;
        break;
      case 'selfie_with_license':
        imageFile = _selfieWithLicenseImage;
        break;
    }
    
    return GestureDetector(
      onTap: isUploaded ? () => _showImageOptions(documentType) : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: isUploaded ? AppTheme.navy : AppTheme.navy.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUploaded ? AppTheme.mediumBlue : AppTheme.navy,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isUploaded && imageFile != null) ...[  
              // Show image preview if uploaded
              Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      imageFile,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Overlay with view icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.navy.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.visibility,
                      color: AppTheme.lightBlue,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ] else ... [
              // Show icon if not uploaded or no image
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isUploaded ? AppTheme.mediumBlue.withOpacity(0.2) : AppTheme.navy,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  isUploaded ? 'assets/svg/clock-check.svg' : icon,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    isUploaded ? AppTheme.mediumBlue : AppTheme.lightBlue,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              isUploaded ? 'Tap to manage' : title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isUploaded ? AppTheme.mediumBlue : AppTheme.white,
              ),
            ),
            if (!isUploaded) ...[
              const SizedBox(height: 6),
              Text(
                'Tap to upload',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.paleBlue.withOpacity(0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final bool allDocumentsUploaded = _driverLicenseFrontUploaded &&
        _driverLicenseBackUploaded &&
        _governmentIdUploaded &&
        _selfieWithLicenseUploaded;
        
    final bool isProcessing = _isUploading;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (allDocumentsUploaded && !isProcessing)
            ? () async {
                // Set uploading state
                setState(() {
                  _isUploading = true;
                });
                
                try {
                  // Here you would upload all documents to Firebase/ImageKit if not already done
                  // For now, we'll simulate a network delay
                  await Future.delayed(const Duration(seconds: 2));
                  
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Documents submitted for verification'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  
                  // Navigate back
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error submitting documents: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } finally {
                  setState(() {
                    _isUploading = false;
                  });
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: allDocumentsUploaded ? AppTheme.lightBlue : AppTheme.lightBlue.withOpacity(0.3),
          disabledBackgroundColor: AppTheme.lightBlue.withOpacity(0.3),
          disabledForegroundColor: AppTheme.navy.withOpacity(0.5),
        ),
        child: isProcessing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.navy,
                ),
              )
            : const Text('Submit for Verification'),
      ),
    );
  }

  // Show image source selection dialog
  Future<void> _showImageSourceDialog(String documentType) async {
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.navy,
          title: const Text('Select Image Source', style: TextStyle(color: AppTheme.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppTheme.lightBlue),
                title: const Text('Gallery', style: TextStyle(color: AppTheme.white)),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppTheme.lightBlue),
                title: const Text('Camera', style: TextStyle(color: AppTheme.white)),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );

    if (source != null) {
      await _pickImage(source, documentType);
    }
  }

  // Pick image from gallery or camera
  Future<void> _pickImage(ImageSource source, String documentType) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _isUploading = true;
        });

        // Create file from picked image
        final File imageFile = File(pickedFile.path);
        
        // Here you would upload to Firebase/ImageKit
        // For now, we'll simulate a network delay
        await Future.delayed(const Duration(seconds: 1));
        
        setState(() {
          switch (documentType) {
            case 'license_front':
              _driverLicenseFrontImage = imageFile;
              _driverLicenseFrontUploaded = true;
              break;
            case 'license_back':
              _driverLicenseBackImage = imageFile;
              _driverLicenseBackUploaded = true;
              break;
            case 'government_id':
              _governmentIdImage = imageFile;
              _governmentIdUploaded = true;
              break;
            case 'selfie_with_license':
              _selfieWithLicenseImage = imageFile;
              _selfieWithLicenseUploaded = true;
              break;
          }
          _isUploading = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image selected successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // Handle document upload
  void _handleUpload(String documentType) {
    _showImageSourceDialog(documentType);
  }
  
  // Show options to view, update or remove the uploaded image
  Future<void> _showImageOptions(String documentType) async {
    String title = '';
    
    switch (documentType) {
      case 'license_front':
        title = 'Driver\'s License (Front)';
        break;
      case 'license_back':
        title = 'Driver\'s License (Back)';
        break;
      case 'government_id':
        title = 'Government ID';
        break;
      case 'selfie_with_license':
        title = 'Selfie with License';
        break;
    }
    
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) => Container(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );
        
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 8,
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.navy,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.mediumBlue.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                  border: Border.all(
                    color: AppTheme.mediumBlue.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with title
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.mediumBlue.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: SvgPicture.asset(
                            'assets/svg/note.svg',
                            width: 20,
                            height: 20,
                            colorFilter: const ColorFilter.mode(
                              AppTheme.lightBlue,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: AppTheme.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.navy.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: AppTheme.paleBlue,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: AppTheme.paleBlue, thickness: 0.5),
                    const SizedBox(height: 10),
                    
                    // Option buttons
                    _buildOptionButton(
                      icon: Icons.visibility,
                      label: 'View Document',
                      color: AppTheme.lightBlue,
                      onTap: () {
                        Navigator.pop(context);
                        _viewDocument(documentType);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildOptionButton(
                      icon: Icons.edit,
                      label: 'Update Document',
                      color: AppTheme.mediumBlue,
                      onTap: () {
                        Navigator.pop(context);
                        _showImageSourceDialog(documentType);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildOptionButton(
                      icon: Icons.delete_outline,
                      label: 'Remove Document',
                      color: Colors.redAccent,
                      onTap: () {
                        Navigator.pop(context);
                        _removeDocument(documentType);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  // Helper method to build option buttons for the dialog
  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  // View the document in full screen
  void _viewDocument(String documentType) {
    File? imageFile;
    String title = '';
    
    switch (documentType) {
      case 'license_front':
        imageFile = _driverLicenseFrontImage;
        title = 'Driver\'s License (Front)';
        break;
      case 'license_back':
        imageFile = _driverLicenseBackImage;
        title = 'Driver\'s License (Back)';
        break;
      case 'government_id':
        imageFile = _governmentIdImage;
        title = 'Government ID';
        break;
      case 'selfie_with_license':
        imageFile = _selfieWithLicenseImage;
        title = 'Selfie with License';
        break;
    }
    
    if (imageFile != null) {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'Dismiss',
        barrierColor: Colors.black87,
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation1, animation2) => Container(),
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );
          
          return FadeTransition(
            opacity: curvedAnimation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
              child: Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.navy,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.mediumBlue.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                    ],
                    border: Border.all(
                      color: AppTheme.mediumBlue.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with title and close button
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.mediumBlue.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: SvgPicture.asset(
                                'assets/svg/note.svg',
                                width: 20,
                                height: 20,
                                colorFilter: const ColorFilter.mode(
                                  AppTheme.lightBlue,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  color: AppTheme.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              borderRadius: BorderRadius.circular(15),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.navy.withOpacity(0.8),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: AppTheme.paleBlue,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: AppTheme.paleBlue, thickness: 0.5),
                      
                      // Image
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        child: Image.file(
                          imageFile!,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
  }

  // Remove the document
  void _removeDocument(String documentType) {
    String title = '';
    
    switch (documentType) {
      case 'license_front':
        title = 'Driver\'s License (Front)';
        break;
      case 'license_back':
        title = 'Driver\'s License (Back)';
        break;
      case 'government_id':
        title = 'Government ID';
        break;
      case 'selfie_with_license':
        title = 'Selfie with License';
        break;
    }
    
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) => Container(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );
        
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 8,
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.navy,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.2),
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Warning icon
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Title
                    Text(
                      'Remove $title',
                      style: const TextStyle(
                        color: AppTheme.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Message
                    const Text(
                      'Are you sure you want to remove this document? This action cannot be undone.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.paleBlue,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Action buttons
                    Row(
                      children: [
                        // Cancel button
                        Expanded(
                          child: InkWell(
                            onTap: () => Navigator.pop(context),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: AppTheme.navy,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.paleBlue.withOpacity(0.5),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  color: AppTheme.paleBlue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // Remove button
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                switch (documentType) {
                                  case 'license_front':
                                    _driverLicenseFrontImage = null;
                                    _driverLicenseFrontUploaded = false;
                                    break;
                                  case 'license_back':
                                    _driverLicenseBackImage = null;
                                    _driverLicenseBackUploaded = false;
                                    break;
                                  case 'government_id':
                                    _governmentIdImage = null;
                                    _governmentIdUploaded = false;
                                    break;
                                  case 'selfie_with_license':
                                    _selfieWithLicenseImage = null;
                                    _selfieWithLicenseUploaded = false;
                                    break;
                                }
                              });
                              Navigator.pop(context);
                              
                              // Show feedback
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.check_circle, color: Colors.white),
                                      const SizedBox(width: 12),
                                      const Text('Document removed successfully'),
                                    ],
                                  ),
                                  backgroundColor: Colors.red.shade700,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  margin: const EdgeInsets.all(10),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'Remove',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Future implementation for Firebase/ImageKit upload
  Future<String?> _uploadToStorage(File imageFile, String documentType) async {
    // This is a placeholder for Firebase/ImageKit implementation
    // You would implement this when connecting to Firebase/ImageKit
    
    // Example implementation structure:
    // 1. Create a reference to Firebase Storage or ImageKit
    // 2. Upload the file
    // 3. Get the download URL
    // 4. Store the URL in Firestore or your database
    
    // For now, just return a mock URL
    return 'https://example.com/images/$documentType-${DateTime.now().millisecondsSinceEpoch}.jpg';
  }
}
