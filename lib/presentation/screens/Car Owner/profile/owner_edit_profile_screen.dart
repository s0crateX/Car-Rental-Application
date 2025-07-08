import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../config/theme.dart';
import '../../../../core/authentication/auth_service.dart';
import '../../../../core/services/image_upload_service.dart';
import '../../../../shared/common_widgets/snackbars/success_snackbar.dart';
import '../../../../shared/common_widgets/snackbars/error_snackbar.dart';

class OwnerEditProfileScreen extends StatefulWidget {
  const OwnerEditProfileScreen({super.key});

  @override
  State<OwnerEditProfileScreen> createState() => _OwnerEditProfileScreenState();
}

class _OwnerEditProfileScreenState extends State<OwnerEditProfileScreen> {
  File? _profileImage;
  String? _profileImageUrl;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController organizationNameController = TextEditingController();

  bool _hasChanges = false;
  bool _isSaving = false;
  String? joinedDate;

  void _setupChangeListeners() {
    for (final controller in [
      fullNameController,
      emailController,
      mobileController,
      addressController,
      organizationNameController,
    ]) {
      controller.addListener(() {
        if (mounted) {
          setState(() {
            _hasChanges = true;
          });
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _setupChangeListeners();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadCarOwnerProfile();
  }

  Future<void> _loadCarOwnerProfile() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final uid = authService.user?.uid;
    if (uid == null) return;
    try {
      // Fetch from users collection instead of car_owners
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final ownerData = doc.data();
      if (ownerData != null) {
        fullNameController.text = ownerData['fullName'] ?? '';
        emailController.text = ownerData['email'] ?? '';
        mobileController.text = ownerData['phoneNumber'] ?? '';
        addressController.text = ownerData['address'] ?? '';
        organizationNameController.text = ownerData['organizationName'] ?? '';
        _profileImageUrl = ownerData['profileImageUrl'] as String?;
        final createdAt = ownerData['createdAt'];
        if (createdAt != null) {
          DateTime? date;
          if (createdAt.runtimeType.toString() == 'Timestamp') {
            date = (createdAt as dynamic).toDate();
          } else if (createdAt is String && createdAt.isNotEmpty) {
            try {
              date = DateTime.parse(createdAt);
            } catch (_) {}
          }
          if (date != null) {
            setState(() {
              joinedDate = 'Joined ${_formatDate(date!)}';
            });
          }
        }
      }
    } catch (e) {
      // Optionally show error
    }
    if (mounted) {
      setState(() {
        _hasChanges = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (image != null) {
        if (mounted) {
          setState(() {
            _profileImage = File(image.path);
            _hasChanges = true;
          });
        }
      } else {
        if (mounted) {
          ErrorSnackbar.show(context: context, message: 'No image selected.');
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorSnackbar.show(
          context: context,
          message: 'Failed to pick image. $e',
        );
      }
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    addressController.dispose();
    organizationNameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfileChanges() async {
    if (!mounted) return;
    
    setState(() {
      _isSaving = true;
    });

    String? uploadedImageUrl;
    if (_profileImage != null) {
      try {
        uploadedImageUrl = await ImageUploadService.uploadProfileImage(
          _profileImage!,
        );
        if (uploadedImageUrl == null) {
          if (mounted) {
            ErrorSnackbar.show(
              context: context,
              message: 'Failed to upload image.',
            );
          }
          setState(() {
            _isSaving = false;
          });
          return;
        }
      } catch (e) {
        if (mounted) {
          ErrorSnackbar.show(
            context: context,
            message: 'Failed to upload image. $e',
          );
        }
        setState(() {
          _isSaving = false;
        });
        return;
      }
    }

    final Map<String, dynamic> dataToUpdate = {
      'fullName': fullNameController.text.trim(),
      'email': emailController.text.trim(),
      'phoneNumber': mobileController.text.trim(),
      'address': addressController.text.trim(),
      'organizationName': organizationNameController.text.trim(),
    };
    
    if (uploadedImageUrl != null) {
      dataToUpdate['profileImageUrl'] = uploadedImageUrl;
    }

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final uid = authService.user?.uid;
      if (uid == null) throw Exception('User not found');
      // Update users collection instead of car_owners
      await FirebaseFirestore.instance.collection('users').doc(uid).update(dataToUpdate);
      
      if (mounted) {
        SuccessSnackbar.show(
          context: context,
          message: 'Profile updated successfully!',
        );
        setState(() {
          _hasChanges = false;
          if (uploadedImageUrl != null) {
            _profileImageUrl = uploadedImageUrl;
            _profileImage = null;
          }
        });
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ErrorSnackbar.show(
          context: context,
          message: 'Failed to update profile. $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
    int? maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.paleBlue,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(
              color: AppTheme.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            readOnly: readOnly,
            onTap: onTap,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppTheme.paleBlue.withOpacity(0.7)),
              filled: true,
              fillColor: AppTheme.navy.withOpacity(0.12),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: suffixIcon ?? const Icon(
                Icons.edit,
                color: AppTheme.mediumBlue,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/svg/arrow-left.svg',
            colorFilter: ColorFilter.mode(AppTheme.white, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.mediumBlue,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.navy.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(55),
                            child: _profileImage != null
                                ? Image.file(
                                    _profileImage!,
                                    width: 110,
                                    height: 110,
                                    fit: BoxFit.cover,
                                  )
                                : (_profileImageUrl != null &&
                                        _profileImageUrl!.isNotEmpty)
                                    ? Image.network(
                                        _profileImageUrl!,
                                        width: 110,
                                        height: 110,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        color: AppTheme.navy,
                                        child: SvgPicture.asset(
                                          'assets/svg/user.svg',
                                          width: 40,
                                          height: 40,
                                          colorFilter: ColorFilter.mode(
                                            AppTheme.lightBlue,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.mediumBlue,
                              shape: BoxShape.circle,
                            ),
                            child: SvgPicture.asset(
                              'assets/svg/camera.svg',
                              width: 18,
                              height: 18,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildEditableField(
                  label: 'Full Name',
                  controller: fullNameController,
                  hint: 'Enter your full name (must match government ID)',
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 8, left: 4),
                  child: Text(
                    'Note: Your full name must exactly match your government-issued ID for verification purposes.',
                    style: TextStyle(
                      color: AppTheme.paleBlue.withOpacity(0.8),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                _buildEditableField(
                  label: 'Email',
                  controller: emailController,
                  hint: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                ),
                _buildEditableField(
                  label: 'Mobile Number',
                  controller: mobileController,
                  hint: 'Enter your mobile number',
                  keyboardType: TextInputType.phone,
                ),
                _buildEditableField(
                  label: 'Organization Name',
                  controller: organizationNameController,
                  hint: 'Enter your organization name',
                ),
                _buildEditableField(
                  label: 'Address',
                  controller: addressController,
                  hint: 'Enter your address',
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                if (joinedDate != null)
                  Text(
                    joinedDate!,
                    style: TextStyle(
                      color: AppTheme.paleBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                const SizedBox(height: 24),
                if (_hasChanges)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfileChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.mediumBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
