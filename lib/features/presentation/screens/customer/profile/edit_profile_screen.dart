import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../config/theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController fullNameController = TextEditingController(
    text: 'Dave Cruz',
  );
  final TextEditingController emailController = TextEditingController(
    text: 'davecruz@gmail.com',
  );
  final TextEditingController mobileController = TextEditingController(
    text: '+63 912 345 6789',
  );
  final TextEditingController dobController = TextEditingController(
    text: '14.03.2001',
  );
  final TextEditingController addressController = TextEditingController(
    text: '123 Main St, Quezon City, PH',
  );
  final TextEditingController emergencyController = TextEditingController(
    text: 'Jane Cruz - +63 923 456 7890',
  );

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                const Text('Edit Profile', style: TextStyle(fontSize: 22)),
                const SizedBox(height: 16),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.mediumBlue,
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: Container(
                          color: AppTheme.navy,
                          child: SvgPicture.asset(
                            'assets/svg/user.svg',
                            width: 80,
                            height: 80,
                            colorFilter: const ColorFilter.mode(
                              AppTheme.paleBlue,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.mediumBlue,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(6),
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
                  ],
                ),
                const SizedBox(height: 24),
                const SizedBox(height: 16),
                _buildEditableField(
                  label: 'Full Name (must match IDs)',
                  controller: fullNameController,
                  hint: 'Enter your full name',
                ),
                _buildEditableField(
                  label: 'Email Address',
                  controller: emailController,
                  hint: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                ),
                _buildEditableField(
                  label: 'Mobile Number (+63)',
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
                    dobController.text = _formatDate(picked!);
                  },
                ),
                _buildEditableField(
                  label: 'Home Address',
                  controller: addressController,
                  hint: 'Enter your home address',
                ),
                _buildEditableField(
                  label: 'Emergency Contact Info',
                  controller: emergencyController,
                  hint: 'Name - Phone Number',
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Joined 04 March 2025',
                    style: TextStyle(
                      color: AppTheme.paleBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
