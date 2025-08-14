import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/theme.dart';
import '../../../../core/authentication/auth_service.dart';
import '../../../../core/services/imagekit_upload_service.dart';
import '../../../../shared/common_widgets/snackbars/success_snackbar.dart';
import '../../../../shared/common_widgets/snackbars/error_snackbar.dart';

class ContractScreen extends StatefulWidget {
  const ContractScreen({super.key});

  @override
  State<ContractScreen> createState() => _ContractScreenState();
}

class _ContractScreenState extends State<ContractScreen>
    with SingleTickerProviderStateMixin {
  bool _isUploading = false;
  bool _isLoadingContract = true;
  File? _contractFile;
  String? _contractUrl;
  String? _fileName;
  String? _fileExtension;
  DateTime? _uploadedAt;

  // Terms and Conditions variables
  bool _isUploadingTerms = false;
  File? _termsFile;
  String? _termsUrl;
  String? _termsFileName;
  String? _termsFileExtension;
  DateTime? _termsUploadedAt;

  // Pending changes tracking
  bool _hasContractChanges = false;
  bool _hasTermsChanges = false;
  bool _isSaving = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    _loadExistingContract();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingContract() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final uid = authService.user?.uid;
    if (uid == null) {
      setState(() {
        _isLoadingContract = false;
      });
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      
      if (doc.exists) {
        final data = doc.data();
        
        // Load contract data
        final contractUrl = data?['rentalContract'] as String?;
        if (contractUrl != null && contractUrl.isNotEmpty) {
          setState(() {
            _contractUrl = contractUrl;
            // Extract filename from URL for display
            _fileName = contractUrl.split('/').last.split('?').first;
            _fileExtension = _fileName?.split('.').last.toLowerCase();
            // Use a placeholder date since we're not storing upload timestamp separately
            _uploadedAt = DateTime.now();
          });
        }
        
        // Load terms and conditions data
        final termsUrl = data?['termsAndConditions'] as String?;
        if (termsUrl != null && termsUrl.isNotEmpty) {
          setState(() {
            _termsUrl = termsUrl;
            _termsFileName = data?['termsFileName'] as String? ?? termsUrl.split('/').last.split('?').first;
            _termsFileExtension = data?['termsFileExtension'] as String? ?? _termsFileName?.split('.').last.toLowerCase();
            // Try to get upload timestamp from Firestore, fallback to current time
            final timestamp = data?['termsUploadedAt'] as Timestamp?;
            _termsUploadedAt = timestamp?.toDate() ?? DateTime.now();
          });
        }
      }
    } catch (e) {
      print('Error loading existing contract: $e');
    } finally {
      setState(() {
        _isLoadingContract = false;
      });
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          setState(() {
            _contractFile = File(file.path!);
            _fileName = file.name;
            _fileExtension = file.extension;
            _hasContractChanges = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorSnackbar.show(
          context: context,
          message: 'Error picking file: $e',
        );
      }
    }
  }

  Future<void> _saveChanges() async {
    if (!_hasContractChanges && !_hasTermsChanges) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final uid = authService.user?.uid;
      if (uid == null) throw Exception('User not authenticated');

      Map<String, dynamic> updates = {};

      // Handle contract upload if there are changes
      if (_hasContractChanges && _contractFile != null) {
        final contractUrl = await ImageKitUploadService.uploadContract(_contractFile!);
        if (contractUrl == null) {
          throw Exception('Failed to upload contract to ImageKit');
        }
        updates['rentalContract'] = contractUrl;
        setState(() {
          _contractUrl = contractUrl;
          _contractFile = null;
          _uploadedAt = DateTime.now();
          _hasContractChanges = false;
        });
      }

      // Handle terms upload if there are changes
      if (_hasTermsChanges && _termsFile != null) {
        final termsUrl = await ImageKitUploadService.uploadTermsAndConditions(_termsFile!);
        if (termsUrl == null) {
          throw Exception('Failed to upload terms to ImageKit');
        }
        updates['termsAndConditions'] = termsUrl;
        updates['termsFileName'] = _termsFileName;
        updates['termsFileExtension'] = _termsFileExtension;
        updates['termsUploadedAt'] = FieldValue.serverTimestamp();
        setState(() {
          _termsUrl = termsUrl;
          _termsFile = null;
          _termsUploadedAt = DateTime.now();
          _hasTermsChanges = false;
        });
      }

      // Save all updates to Firestore
      if (updates.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .update(updates);
      }

      SuccessSnackbar.show(
        context: context,
        message: 'Changes saved successfully!',
      );
    } catch (e) {
      ErrorSnackbar.show(
        context: context,
        message: 'Failed to save changes: $e',
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }



  Future<void> _removeContract() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.navy,
          title: const Text(
            'Remove Contract',
            style: TextStyle(color: AppTheme.white),
          ),
          content: const Text(
            'Are you sure you want to remove the current contract?',
            style: TextStyle(color: AppTheme.paleBlue),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppTheme.lightBlue),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _performRemoveContract();
              },
              child: const Text(
                'Remove',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performRemoveContract() async {
    setState(() {
      _isUploading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final uid = authService.user?.uid;
      if (uid == null) throw Exception('User not authenticated');

      // Remove contract info from Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({
        'rentalContract': '',
      });

      setState(() {
        _contractUrl = null;
        _fileName = null;
        _fileExtension = null;
        _contractFile = null;
        _uploadedAt = null;
      });

      SuccessSnackbar.show(
        context: context,
        message: 'Contract removed successfully!',
      );
    } catch (e) {
      ErrorSnackbar.show(
        context: context,
        message: 'Failed to remove contract: $e',
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _viewContract() async {
    if (_contractUrl == null) return;

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.lightBlue),
          ),
        ),
      );

      // Close loading dialog
      Navigator.of(context).pop();

      // Determine file type and handle accordingly
      final isImage = _fileExtension != null && 
                     ['jpg', 'jpeg', 'png'].contains(_fileExtension!.toLowerCase());
      
      if (isImage) {
        // Show image in full-screen viewer
        _showImageViewer(_contractUrl!);
      } else {
        // For PDFs, try to open externally
        try {
          final uri = Uri.parse(_contractUrl!);
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (e) {
          // If external launch fails, show image viewer as fallback
          _showImageViewer(_contractUrl!);
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      ErrorSnackbar.show(
        context: context,
        message: 'Failed to open contract: $e',
      );
    }
  }

  void _showImageViewer(String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _ImageViewerScreen(
          imageUrl: imageUrl,
          fileName: _fileName ?? 'Contract',
        ),
      ),
    );
  }

  // Terms and Conditions Methods
  Future<void> _pickTermsFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          setState(() {
            _termsFile = File(file.path!);
            _termsFileName = file.name;
            _termsFileExtension = file.extension;
            _hasTermsChanges = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorSnackbar.show(
          context: context,
          message: 'Error picking file: $e',
        );
      }
    }
  }

  Future<void> _uploadTerms() async {
    if (_termsFile == null) {
      ErrorSnackbar.show(
        context: context,
        message: 'Please select a terms and conditions file first.',
      );
      return;
    }

    setState(() {
      _isUploadingTerms = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final uid = authService.user?.uid;
      if (uid == null) throw Exception('User not authenticated');

      // Upload file to ImageKit TermsAndCondition folder
      final downloadUrl = await ImageKitUploadService.uploadTermsAndConditions(_termsFile!);
      
      if (downloadUrl == null) {
        throw Exception('Failed to upload file to ImageKit');
      }

      // Save terms data to users collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({
        'termsAndConditions': downloadUrl,
        'termsFileName': _termsFileName,
        'termsFileExtension': _termsFileExtension,
        'termsUploadedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _termsUrl = downloadUrl;
        _termsFile = null;
        _termsUploadedAt = DateTime.now();
      });

      SuccessSnackbar.show(
        context: context,
        message: 'Terms and conditions uploaded successfully!',
      );
    } catch (e) {
      ErrorSnackbar.show(
        context: context,
        message: 'Failed to upload terms and conditions: $e',
      );
    } finally {
      setState(() {
        _isUploadingTerms = false;
      });
    }
  }

  Future<void> _removeTerms() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.navy,
          title: const Text(
            'Remove Terms and Conditions',
            style: TextStyle(color: AppTheme.white),
          ),
          content: const Text(
            'Are you sure you want to remove the current terms and conditions?',
            style: TextStyle(color: AppTheme.paleBlue),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppTheme.lightBlue),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _performRemoveTerms();
              },
              child: const Text(
                'Remove',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performRemoveTerms() async {
    setState(() {
      _isUploadingTerms = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final uid = authService.user?.uid;
      if (uid == null) throw Exception('User not authenticated');

      // Remove terms info from Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({
        'termsAndConditions': FieldValue.delete(),
        'termsFileName': FieldValue.delete(),
        'termsFileExtension': FieldValue.delete(),
        'termsUploadedAt': FieldValue.delete(),
      });

      setState(() {
        _termsUrl = null;
        _termsFileName = null;
        _termsFileExtension = null;
        _termsFile = null;
        _termsUploadedAt = null;
      });

      SuccessSnackbar.show(
        context: context,
        message: 'Terms and conditions removed successfully!',
      );
    } catch (e) {
      ErrorSnackbar.show(
        context: context,
        message: 'Failed to remove terms and conditions: $e',
      );
    } finally {
      setState(() {
        _isUploadingTerms = false;
      });
    }
  }

  Future<void> _viewTerms() async {
    if (_termsUrl == null) return;

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.lightBlue),
          ),
        ),
      );

      // Close loading dialog
      Navigator.of(context).pop();

      // Determine file type and handle accordingly
      final isImage = _termsFileExtension != null && 
                     ['jpg', 'jpeg', 'png'].contains(_termsFileExtension!.toLowerCase());
      
      if (isImage) {
        // Show image in full-screen viewer
        _showTermsImageViewer(_termsUrl!);
      } else {
        // For PDFs, try to open externally
        try {
          final uri = Uri.parse(_termsUrl!);
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (e) {
          // If external launch fails, show image viewer as fallback
          _showTermsImageViewer(_termsUrl!);
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      ErrorSnackbar.show(
        context: context,
        message: 'Failed to open terms and conditions: $e',
      );
    }
  }

  void _showTermsImageViewer(String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _ImageViewerScreen(
          imageUrl: imageUrl,
          fileName: _termsFileName ?? 'Terms and Conditions',
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(24),
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.lightBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SvgPicture.asset(
              'assets/svg/note.svg',
              width: 48,
              height: 48,
              colorFilter: const ColorFilter.mode(
                AppTheme.lightBlue,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Rental Contract',
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Upload your rental contract template for customers',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }



  Widget _buildCurrentContractSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.navy.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.paleBlue.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/svg/note.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  AppTheme.lightBlue,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Rental Contract',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_contractUrl == null && _contractFile == null) ...[
            _buildNoContractContent(),
          ],
          if (_contractFile != null && _contractUrl == null) ...[
            _buildSelectedContractContent(),
          ],
          if (_contractUrl != null) ...[
            _buildExistingContractContent(),
          ],
        ],
      ),
    );
  }

  Widget _buildNoContractContent() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.navy.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.paleBlue.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              SvgPicture.asset(
                'assets/svg/note.svg',
                width: 48,
                height: 48,
                colorFilter: ColorFilter.mode(
                  AppTheme.paleBlue.withOpacity(0.5),
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No Contract Uploaded',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.paleBlue.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Upload a rental contract template to get started',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.paleBlue.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _pickFile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightBlue,
              foregroundColor: AppTheme.navy,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: SvgPicture.asset(
              'assets/svg/upload.svg',
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(
                AppTheme.navy,
                BlendMode.srcIn,
              ),
            ),
            label: const Text('Upload Contract'),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedContractContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lightBlue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.lightBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SvgPicture.asset(
                  _fileExtension == 'pdf' ? 'assets/svg/note.svg' : 'assets/svg/camera.svg',
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _fileName ?? 'Selected File',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pending changes - Click Save to upload',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : () {
                setState(() {
                  _contractFile = null;
                  _fileName = null;
                  _fileExtension = null;
                  _hasContractChanges = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.1),
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red, width: 1),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: SvgPicture.asset(
                'assets/svg/trash.svg',
                width: 16,
                height: 16,
                colorFilter: const ColorFilter.mode(
                  Colors.red,
                  BlendMode.srcIn,
                ),
              ),
              label: const Text('Cancel Selection'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExistingContractContent() {

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.navy.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.lightBlue.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/svg/check.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  AppTheme.lightBlue,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Current Contract',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.lightBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.lightBlue.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.lightBlue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SvgPicture.asset(
                        _fileExtension == 'pdf' ? 'assets/svg/note.svg' : 'assets/svg/camera.svg',
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _fileName ?? 'Contract File',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_uploadedAt != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Uploaded on ${_uploadedAt!.day}/${_uploadedAt!.month}/${_uploadedAt!.year}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.paleBlue.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _viewContract,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.lightBlue,
                          foregroundColor: AppTheme.navy,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: SvgPicture.asset(
                          'assets/svg/binoculars.svg',
                          width: 16,
                          height: 16,
                          colorFilter: const ColorFilter.mode(
                            AppTheme.navy,
                            BlendMode.srcIn,
                          ),
                        ),
                        label: const Text('View'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isUploading ? null : _removeContract,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.1),
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red, width: 1),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: SvgPicture.asset(
                          'assets/svg/trash.svg',
                          width: 16,
                          height: 16,
                          colorFilter: const ColorFilter.mode(
                            Colors.red,
                            BlendMode.srcIn,
                          ),
                        ),
                        label: const Text('Remove'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.navy.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.paleBlue.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/svg/note.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  AppTheme.lightBlue,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Terms & Conditions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_termsUrl == null && _termsFile == null) ...[
            _buildNoTermsContent(),
          ],
          if (_termsFile != null && _termsUrl == null) ...[
            _buildSelectedTermsContent(),
          ],
          if (_termsUrl != null) ...[
            _buildExistingTermsContent(),
          ],
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.lightBlue.withOpacity(0.1),
            AppTheme.mediumBlue.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.lightBlue.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.lightBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SvgPicture.asset(
                  'assets/svg/check.svg',
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pending Changes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _buildPendingChangesText(),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.paleBlue.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightBlue,
                foregroundColor: AppTheme.navy,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.navy),
                      ),
                    )
                  : SvgPicture.asset(
                      'assets/svg/upload.svg',
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                        AppTheme.navy,
                        BlendMode.srcIn,
                      ),
                    ),
              label: Text(
                _isSaving ? 'Saving Changes...' : 'Save Changes',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _buildPendingChangesText() {
    List<String> changes = [];
    if (_hasContractChanges) {
      changes.add('Contract file selected');
    }
    if (_hasTermsChanges) {
      changes.add('Terms & conditions file selected');
    }
    return changes.join(' • ');
  }

  Widget _buildSelectedTermsContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lightBlue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.lightBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SvgPicture.asset(
                  _termsFileExtension == 'pdf' ? 'assets/svg/note.svg' : 'assets/svg/camera.svg',
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _termsFileName ?? 'Selected File',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                       'Pending changes - Click Save to upload',
                       style: TextStyle(
                         fontSize: 12,
                         color: Colors.orange.withOpacity(0.8),
                       ),
                     ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
             width: double.infinity,
             child: ElevatedButton.icon(
               onPressed: _isSaving ? null : () {
                 setState(() {
                   _termsFile = null;
                   _termsFileName = null;
                   _termsFileExtension = null;
                   _hasTermsChanges = false;
                 });
               },
               style: ElevatedButton.styleFrom(
                 backgroundColor: Colors.red.withOpacity(0.1),
                 foregroundColor: Colors.red,
                 side: const BorderSide(color: Colors.red, width: 1),
                 padding: const EdgeInsets.symmetric(vertical: 10),
                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(8),
                 ),
               ),
               icon: SvgPicture.asset(
                 'assets/svg/trash.svg',
                 width: 16,
                 height: 16,
                 colorFilter: const ColorFilter.mode(
                   Colors.red,
                   BlendMode.srcIn,
                 ),
               ),
               label: const Text('Cancel Selection'),
             ),
           ),
        ],
      ),
    );
  }

  Widget _buildNoTermsContent() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.navy.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.paleBlue.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              SvgPicture.asset(
                'assets/svg/note.svg',
                width: 48,
                height: 48,
                colorFilter: ColorFilter.mode(
                  AppTheme.paleBlue.withOpacity(0.5),
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No Terms & Conditions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.paleBlue.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Upload your terms and conditions document',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.paleBlue.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isUploadingTerms ? null : _pickTermsFile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightBlue,
              foregroundColor: AppTheme.navy,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: _isUploadingTerms
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.navy),
                    ),
                  )
                : SvgPicture.asset(
                    'assets/svg/upload.svg',
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(
                      AppTheme.navy,
                      BlendMode.srcIn,
                    ),
                  ),
            label: Text(_isUploadingTerms ? 'Uploading...' : 'Upload Terms & Conditions'),
          ),
        ),
      ],
    );
  }

  Widget _buildExistingTermsContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lightBlue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.lightBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SvgPicture.asset(
                  _termsFileExtension == 'pdf' ? 'assets/svg/note.svg' : 'assets/svg/camera.svg',
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _termsFileName ?? 'Terms & Conditions',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_termsUploadedAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Uploaded on ${_termsUploadedAt!.day}/${_termsUploadedAt!.month}/${_termsUploadedAt!.year}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.paleBlue.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _viewTerms,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lightBlue,
                    foregroundColor: AppTheme.navy,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: SvgPicture.asset(
                    'assets/svg/binoculars.svg',
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(
                      AppTheme.navy,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: const Text('View'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isUploadingTerms ? null : _removeTerms,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red, width: 1),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: SvgPicture.asset(
                    'assets/svg/trash.svg',
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(
                      Colors.red,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: const Text('Remove'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isUploadingTerms ? null : _pickTermsFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.navy.withOpacity(0.5),
                foregroundColor: AppTheme.lightBlue,
                side: const BorderSide(color: AppTheme.lightBlue, width: 1),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: _isUploadingTerms
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.lightBlue),
                      ),
                    )
                  : SvgPicture.asset(
                      'assets/svg/upload.svg',
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(
                        AppTheme.lightBlue,
                        BlendMode.srcIn,
                      ),
                    ),
              label: Text(_isUploadingTerms ? 'Uploading...' : 'Replace Terms & Conditions'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      appBar: AppBar(
        backgroundColor: AppTheme.darkNavy,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: SvgPicture.asset(
            'assets/svg/arrow-left.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(
              AppTheme.lightBlue,
              BlendMode.srcIn,
            ),
          ),
        ),
        title: const Text(
          'Contract Management',
          style: TextStyle(
            color: AppTheme.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoadingContract
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.lightBlue),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading contract data...',
                    style: TextStyle(
                      color: AppTheme.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderSection(),
                    const SizedBox(height: 24),
                    _buildCurrentContractSection(),
                    const SizedBox(height: 24),
                    _buildTermsSection(),
                    if (_hasContractChanges || _hasTermsChanges) ...[
                      const SizedBox(height: 24),
                      _buildSaveButton(),
                    ],
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }
}

class _ImageViewerScreen extends StatefulWidget {
  final String imageUrl;
  final String fileName;

  const _ImageViewerScreen({
    required this.imageUrl,
    required this.fileName,
  });

  @override
  State<_ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<_ImageViewerScreen> {
  final TransformationController _transformationController = TransformationController();
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  Future<void> _shareContract() async {
    try {
      final uri = Uri.parse(widget.imageUrl);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ErrorSnackbar.show(
          context: context,
          message: 'Could not open contract externally',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.7),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.close,
            color: Colors.white,
            size: 28,
          ),
        ),
        title: Text(
          widget.fileName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            onPressed: _resetZoom,
            icon: const Icon(
              Icons.zoom_out_map,
              color: Colors.white,
            ),
            tooltip: 'Reset Zoom',
          ),
          IconButton(
            onPressed: _shareContract,
            icon: const Icon(
              Icons.open_in_new,
              color: Colors.white,
            ),
            tooltip: 'Open Externally',
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    });
                    return child;
                  }
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.lightBlue),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                        _hasError = true;
                      });
                    }
                  });
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Failed to load image',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Error: $error',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _shareContract,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.lightBlue,
                            foregroundColor: AppTheme.navy,
                          ),
                          child: const Text('Open Externally'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          if (_isLoading && !_hasError)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.lightBlue),
              ),
            ),
        ],
      ),
    );
  }
}