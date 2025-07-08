import 'package:flutter/material.dart';
import 'package:car_rental_app/config/theme.dart';
import 'package:car_rental_app/shared/common_widgets/snackbars/validation_snackbar.dart';
import 'package:car_rental_app/shared/common_widgets/snackbars/app_snackbar.dart';
import 'package:car_rental_app/core/authentication/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _isSubmitting = false;
  final _organizationNameController = TextEditingController();

  Future<void> _registerUser() async {
    // Validate all fields first
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ValidationSnackbar.showFieldValidationError(context);
      return;
    }

    if (_selectedRole == 'Car Owner' &&
        _organizationNameController.text.isEmpty) {
      AppSnackbar.error(
        context: context,
        message: 'Please enter your organization name.',
      );
      return;
    }

    if (!_passwordsMatch) {
      ValidationSnackbar.showPasswordMismatchError(context);
      return;
    }

    if (!_hasMinLength ||
        !_hasUppercase ||
        !_hasLowercase ||
        !_hasNumber ||
        !_hasSpecialChar) {
      ValidationSnackbar.showPasswordStrengthError(context);
      return;
    }

    // Validate email format
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      AppSnackbar.error(
        context: context,
        message: 'Please enter a valid email address.',
      );
      return;
    }

    // Validate phone number (PH format, must be 10 digits, starts with 9)
    final phone = _phoneController.text.trim();
    if (!RegExp(r'^9\d{9}$').hasMatch(phone)) {
      AppSnackbar.error(
        context: context,
        message:
            'Please enter a valid 10-digit PH mobile number (e.g., 9123456789).',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      // Use the AuthService to register the user
      final success = await authService.signUpWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
        _phoneController.text.trim(),
        _selectedRole, // Now all user info (including car_owner) is saved in users collection only
        organizationName: _selectedRole == 'Car Owner'
            ? _organizationNameController.text.trim()
            : null,
      );

      if (success) {
        // Email verification is now sent automatically in the AuthService
        _showSignupConfirmation();
      } else {
        // If there was an error in the AuthService
        String? errorMsg = authService.errorMessage;
        AppSnackbar.error(
          context: context,
          message: errorMsg ?? 'Registration failed.',
        );
      }
    } catch (e) {
      AppSnackbar.error(
        context: context,
        message: 'An unexpected error occurred: ${e.toString()}',
      );
      print('Error during registration: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // User role selection
  String _selectedRole = 'Customer';

  // Password strength variables
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;
  bool _showPassword = false;

  // Check if passwords match
  bool _passwordsMatch = false;

  void _checkPasswordStrength(String password) {
    setState(() {
      _hasMinLength = password.length >= 6;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  void _checkPasswordsMatch() {
    setState(() {
      _passwordsMatch =
          _passwordController.text == _confirmPasswordController.text;
    });
  }

  // Show signup confirmation dialog
  void _showSignupConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppTheme.navy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.mark_email_read_rounded,
                      color: AppTheme.lightBlue,
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Verify Your Email',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Thank you for registering, ${_nameController.text}! We\'ve sent a verification link to ${_emailController.text}. Please check your inbox or spam folder and verify your account before logging in.',
                  style: TextStyle(color: AppTheme.paleBlue, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lightBlue,
                      foregroundColor: AppTheme.navy,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Redirect to login screen
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: const Text('Okay'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _organizationNameController.dispose();
    super.dispose();
  }

  // Build password requirement indicator
  Widget _buildPasswordRequirement(String requirement, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.cancel,
            color: isMet ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            requirement,
            style: TextStyle(
              color: isMet ? Colors.green : Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.navy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Title
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),

                const SizedBox(height: 10),

                // Instruction text
                Text(
                  'Please fill the input below here',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppTheme.paleBlue),
                ),

                const SizedBox(height: 30),

                // Full name field
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: SvgPicture.asset(
                        'assets/svg/user.svg',
                        color: AppTheme.lightBlue,
                        width: 20,
                        height: 20,
                      ),
                    ),
                    hintText: 'Full Name',
                    hintStyle: TextStyle(
                      color: AppTheme.lightBlue.withOpacity(0.7),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Phone field (PH format)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.navy.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.lightBlue.withOpacity(0.5),
                        ),
                      ),
                      child: const Text(
                        '+63',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: '9123456789',
                          hintStyle: TextStyle(
                            color: AppTheme.lightBlue.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Email field
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: SvgPicture.asset(
                        'assets/svg/mail.svg',
                        color: AppTheme.lightBlue,
                        width: 20,
                        height: 20,
                      ),
                    ),
                    hintText: 'Email',
                    hintStyle: TextStyle(
                      color: AppTheme.lightBlue.withOpacity(0.7),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_showPassword,
                  onChanged: (value) {
                    _checkPasswordStrength(value);
                    _checkPasswordsMatch();
                  },
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: AppTheme.lightBlue),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: SvgPicture.asset(
                        'assets/svg/lock.svg',
                        color: AppTheme.lightBlue,
                        width: 20,
                        height: 20,
                      ),
                    ),
                    hintText: 'Enter your password',
                    hintStyle: TextStyle(
                      color: AppTheme.lightBlue.withOpacity(0.7),
                    ),
                  ),
                ),

                // Show password requirements only if not all are met and typing started
                if (_passwordController.text.isNotEmpty &&
                    (!(_hasMinLength &&
                        _hasUppercase &&
                        _hasLowercase &&
                        _hasNumber &&
                        _hasSpecialChar)))
                  Column(
                    children: [
                      const SizedBox(height: 10),
                      _buildPasswordRequirement(
                        'At least 6 characters',
                        _hasMinLength,
                      ),
                      _buildPasswordRequirement(
                        'At least 1 uppercase letter',
                        _hasUppercase,
                      ),
                      _buildPasswordRequirement(
                        'At least 1 lowercase letter',
                        _hasLowercase,
                      ),
                      _buildPasswordRequirement(
                        'At least 1 number',
                        _hasNumber,
                      ),
                      _buildPasswordRequirement(
                        'At least 1 special character',
                        _hasSpecialChar,
                      ),
                    ],
                  ),

                const SizedBox(height: 20),

                // Confirm Password field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_showPassword,
                  onChanged: (value) {
                    _checkPasswordsMatch();
                  },
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    labelStyle: TextStyle(color: AppTheme.lightBlue),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: SvgPicture.asset(
                        'assets/svg/lock.svg',
                        color: AppTheme.lightBlue,
                        width: 20,
                        height: 20,
                      ),
                    ),
                    hintText: 'Confirm your password',
                    hintStyle: TextStyle(
                      color: AppTheme.lightBlue.withOpacity(0.7),
                    ),
                    errorText: _passwordsMatch ||
                            _confirmPasswordController.text.isEmpty
                        ? null
                        : 'Passwords do not match',
                  ),
                ),

                const SizedBox(height: 10),

                // Show Password Checkbox
                Row(
                  children: [
                    Theme(
                      data: ThemeData(
                        unselectedWidgetColor: AppTheme.lightBlue,
                      ),
                      child: Checkbox(
                        value: _showPassword,
                        onChanged: (value) {
                          setState(() {
                            _showPassword = value!;
                          });
                        },
                        checkColor: AppTheme.navy,
                        activeColor: AppTheme.lightBlue,
                      ),
                    ),
                    Text(
                      'Show Password',
                      style: TextStyle(color: AppTheme.paleBlue),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // User role selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'I am a',
                      style: TextStyle(
                        color: AppTheme.paleBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedRole = 'Customer';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedRole == 'Customer'
                                    ? AppTheme.mediumBlue
                                    : AppTheme.navy,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _selectedRole == 'Customer'
                                      ? AppTheme.mediumBlue
                                      : AppTheme.lightBlue,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Customer',
                                  style: TextStyle(
                                    color: _selectedRole == 'Customer'
                                        ? Colors.white
                                        : AppTheme.lightBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedRole = 'Car Owner';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedRole == 'Car Owner'
                                    ? AppTheme.mediumBlue
                                    : AppTheme.navy,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _selectedRole == 'Car Owner'
                                      ? AppTheme.mediumBlue
                                      : AppTheme.lightBlue,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Car Owner',
                                  style: TextStyle(
                                    color: _selectedRole == 'Car Owner'
                                        ? Colors.white
                                        : AppTheme.lightBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SizeTransition(
                          sizeFactor: animation,
                          axis: Axis.vertical,
                          child: child,
                        ),
                      );
                    },
                    child: _selectedRole == 'Car Owner'
                        ? Padding(
                            key: const ValueKey('organization-field'),
                            padding: const EdgeInsets.only(top: 20.0),
                            child: TextFormField(
                              controller: _organizationNameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Organization Name',
                                labelStyle: TextStyle(color: AppTheme.lightBlue),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: SvgPicture.asset(
                                    'assets/svg/users.svg',
                                    color: AppTheme.lightBlue,
                                    width: 20,
                                    height: 20,
                                  ),
                                ),
                                hintText: 'Enter your organization name',
                                hintStyle: TextStyle(
                                  color: AppTheme.lightBlue.withOpacity(0.7),
                                ),
                              ),
                              validator: (value) {
                                if (_selectedRole == 'Car Owner' &&
                                    (value == null || value.isEmpty)) {
                                  return 'Organization name is required for Car Owners';
                                }
                                return null;
                              },
                            ),
                          )
                        : const SizedBox.shrink(key: ValueKey('empty')),
                  ),
                ),

                const SizedBox(height: 30),

                // Sign Up button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _registerUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lightBlue,
                      foregroundColor: AppTheme.navy,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text(
                      'SIGN UP',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Already have an account section
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(color: AppTheme.paleBlue),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Sign in',
                        style: TextStyle(
                          color: Colors.lightBlueAccent,
                          fontWeight: FontWeight.bold,
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
  }
}
