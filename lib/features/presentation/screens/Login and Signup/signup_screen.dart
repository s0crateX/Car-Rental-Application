import 'package:flutter/material.dart';
import 'package:car_rental_app/config/theme.dart';
import 'package:car_rental_app/shared/common_widgets/snackbars/validation_snackbar.dart';
import 'package:car_rental_app/shared/common_widgets/snackbars/app_snackbar.dart';
import 'package:car_rental_app/core/authentication/auth_service.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _isSubmitting = false;

  Future<void> _registerUser() async {
    setState(() {
      _isSubmitting = true;
    });
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // Convert role to lowercase for consistency in the database
      String userRole = _selectedRole.toLowerCase();
      if (userRole == 'car owner') {
        userRole = 'car_owner';
      }
      
      // Use the AuthService to register the user
      final success = await authService.signUpWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
        _phoneController.text.trim(),
        userRole,
      );
      
      if (success) {
        // Send email verification
        await authService.sendEmailVerification();
        _showSignupConfirmation();
      } else {
        // If there was an error in the AuthService
        String? errorMsg = authService.errorMessage;
        AppSnackbar.error(context: context, message: errorMsg ?? 'Registration failed.');
      }
    } catch (e) {
      AppSnackbar.error(context: context, message: 'An unexpected error occurred.');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
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
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
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
      _passwordsMatch = _passwordController.text == _confirmPasswordController.text;
    });
  }
  
  // Show signup confirmation dialog
  void _showSignupConfirmation() {
    AppSnackbar.success(
      context: context,
      message: 'We\'ve sent a verification link to ${_emailController.text}. Please check your email to complete registration.',
      duration: const Duration(seconds: 6),
    );
    
    // Navigate back to login after a delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.paleBlue,
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Full name field
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person_outline, color: AppTheme.lightBlue),
                    hintText: 'Full Name',
                    hintStyle: TextStyle(color: AppTheme.lightBlue.withOpacity(0.7)),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Phone field
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.phone_android, color: AppTheme.lightBlue),
                    hintText: 'Phone',
                    hintStyle: TextStyle(color: AppTheme.lightBlue.withOpacity(0.7)),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Email field
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email_outlined, color: AppTheme.lightBlue),
                    hintText: 'Email',
                    hintStyle: TextStyle(color: AppTheme.lightBlue.withOpacity(0.7)),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  onChanged: (value) {
                    _checkPasswordStrength(value);
                    _checkPasswordsMatch();
                  },
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: AppTheme.lightBlue),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: AppTheme.lightBlue,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                
                // Show password requirements only when typing starts
                if (_passwordController.text.isNotEmpty)
                  Column(
                    children: [
                      const SizedBox(height: 10),
                      _buildPasswordRequirement('At least 6 characters', _hasMinLength),
                      _buildPasswordRequirement('At least 1 uppercase letter', _hasUppercase),
                      _buildPasswordRequirement('At least 1 lowercase letter', _hasLowercase),
                      _buildPasswordRequirement('At least 1 number', _hasNumber),
                      _buildPasswordRequirement('At least 1 special character', _hasSpecialChar),
                    ],
                  ),
                
                const SizedBox(height: 20),
                
                // Confirm Password field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  onChanged: (value) => _checkPasswordsMatch(),
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    labelStyle: TextStyle(color: AppTheme.lightBlue),
                    suffixIcon: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_confirmPasswordController.text.isNotEmpty)
                          Icon(
                            _passwordsMatch ? Icons.check : Icons.close,
                            color: _passwordsMatch ? Colors.green : Colors.red,
                            size: 20,
                          ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
                
                if (_confirmPasswordController.text.isNotEmpty && !_passwordsMatch)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Passwords do not match',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                
                const SizedBox(height: 25),
                
                // User role selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'I want to register as:',
                      style: TextStyle(
                        color: AppTheme.paleBlue,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // Role selection buttons
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
                
                const SizedBox(height: 30),
                
                // Sign Up button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Validate all fields
                      if (_nameController.text.isEmpty ||
                          _emailController.text.isEmpty ||
                          _phoneController.text.isEmpty ||
                          _passwordController.text.isEmpty ||
                          _confirmPasswordController.text.isEmpty) {
                        ValidationSnackbar.showFieldValidationError(context);
                        return;
                      }
                      
                      if (!_passwordsMatch) {
                        ValidationSnackbar.showPasswordMismatchError(context);
                        return;
                      }
                      
                      if (!_hasMinLength || !_hasUppercase || !_hasLowercase || !_hasNumber || !_hasSpecialChar) {
                        ValidationSnackbar.showPasswordStrengthError(context);
                        return;
                      }
                      
                      // Implement actual signup functionality
                      _registerUser();
                    },
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
