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

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _profileImage;
  String? _profileImageUrl;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emergencyController = TextEditingController();

  bool _hasChanges = false;
  bool _isSaving = false;
  String? joinedDate;

  void _setupChangeListeners() {
    for (final controller in [
      fullNameController,
      emailController,
      mobileController,
      dobController,
      addressController,
      emergencyController,
    ]) {
      controller.addListener(() {
        setState(() {
          _hasChanges = true;
        });
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
    final userData = Provider.of<AuthService>(context, listen: false).userData;
    fullNameController.text = userData?['fullName'] ?? '';
    emailController.text = userData?['email'] ?? '';
    mobileController.text = userData?['phoneNumber'] ?? '';
    dobController.text = userData?['dob'] ?? '';
    addressController.text = userData?['address'] ?? '';
    emergencyController.text = userData?['emergencyContact'] ?? '';
    _profileImageUrl = userData?['profileImageUrl'] as String?;
    final createdAt = userData?['createdAt'];
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
        joinedDate = 'Joined ${_formatDate(date)}';
      } else {
        joinedDate = null;
      }
    }
    _hasChanges = false;
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
        setState(() {
          _profileImage = File(image.path);
          _hasChanges = true; // Mark changes when image is picked
        });
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
    dobController.dispose();
    addressController.dispose();
    emergencyController.dispose();
    super.dispose();
  }

  Future<void> _saveProfileChanges() async {
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
      'dob': dobController.text.trim(),
      'address': addressController.text.trim(),
      'emergencyContact': emergencyController.text.trim(),
    };
    if (uploadedImageUrl != null) {
      dataToUpdate['profileImageUrl'] = uploadedImageUrl;
    }

    try {
      await Provider.of<AuthService>(
        context,
        listen: false,
      ).updateUserProfileData(dataToUpdate);
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
                borderRadius: BorderRadius.circular(22),
                borderSide: BorderSide.none,
              ),
              suffixIcon: Icon(
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                const SizedBox(height: 16),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.white,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child:
                              _profileImage != null
                                  ? Image.file(
                                    _profileImage!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  )
                                  : (_profileImageUrl != null &&
                                      _profileImageUrl!.isNotEmpty)
                                  ? Image.network(
                                    _profileImageUrl!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  )
                                  : Container(
                                    color: AppTheme.navy,
                                    child: const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: AppTheme.paleBlue,
                                    ),
                                  ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.navy,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildEditableField(
                  label: 'Full Name',
                  controller: fullNameController,
                  hint: 'Enter your full name',
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
                  label: 'Date of Birth',
                  controller: dobController,
                  hint: 'DD.MM.YYYY',
                  readOnly: true,
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate:
                          DateTime.tryParse(_parseDate(dobController.text)) ??
                          DateTime(2000, 1, 1),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      dobController.text = _formatDate(picked);
                      setState(() {
                        _hasChanges = true;
                      });
                    }
                  },
                ),
                _buildEditableField(
                  label: 'Address',
                  controller: addressController,
                  hint: 'Enter your address',
                ),
                _buildEditableField(
                  label: 'Emergency Contact',
                  controller: emergencyController,
                  hint: 'Enter emergency contact',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                if (joinedDate != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      joinedDate!,
                      style: TextStyle(
                        color: AppTheme.paleBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          _isSaving
                              ? const SizedBox(
                                height: 20,
                                width: 20,
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
                const SizedBox(height: 16),
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

  String _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('.');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day).toIso8601String();
      }
    } catch (_) {}
    return DateTime(2000, 1, 1).toIso8601String();
  }
}
