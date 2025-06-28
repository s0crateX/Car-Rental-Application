import 'package:flutter/material.dart';
import 'package:car_rental_app/config/routes.dart';
import 'package:car_rental_app/config/theme.dart';
import 'package:car_rental_app/shared/common_widgets/snackbars/validation_snackbar.dart';
import 'package:car_rental_app/shared/common_widgets/snackbars/success_snackbar.dart';
import 'package:car_rental_app/shared/common_widgets/snackbars/error_snackbar.dart';
import 'package:car_rental_app/shared/common_widgets/snackbars/app_snackbar.dart';
import 'package:car_rental_app/core/authentication/auth_service.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  // Show a dialog for email verification
  void _showVerificationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppTheme.navy,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(Icons.mark_email_read_rounded, color: AppTheme.lightBlue, size: 28),
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
                  'Please verify your email before logging in. Check your inbox for a verification link or spam folder if not found.',
                  style: TextStyle(color: AppTheme.paleBlue, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.mediumBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: () async {
                          Navigator.of(context).pop();
                          final authService = Provider.of<AuthService>(context, listen: false);
                          final success = await authService.sendEmailVerification();
                          if (success) {
                            AppSnackbar.success(
                              context: context,
                              message: 'Verification email sent! Please check your inbox.',
                            );
                          } else {
                            AppSnackbar.error(
                              context: context,
                              message: authService.errorMessage ?? 'Failed to send verification email.',
                            );
                          }
                        },
                        child: const Text('Resend'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.lightBlue,
                          foregroundColor: AppTheme.navy,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Okay'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App logo section
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppTheme.navy,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // This is a placeholder for the car logo
                        Icon(
                          Icons.directions_car,
                          size: 60,
                          color: AppTheme.lightBlue,
                        ),
                        // Additional graphic elements similar to the design
                        Positioned(
                          top: 20,
                          left: 20,
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              color: AppTheme.mediumBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 15,
                          right: 15,
                          child: Container(
                            height: 20,
                            width: 20,
                            decoration: BoxDecoration(
                              color: AppTheme.lightBlue.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Login text
                Text(
                  'Login',
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
                
                const SizedBox(height: 40),
                
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
                
                const SizedBox(height: 20),
                
                // Password field
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock_outline, color: AppTheme.lightBlue),
                    hintText: 'Password',
                    hintStyle: TextStyle(color: AppTheme.lightBlue.withOpacity(0.7)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: AppTheme.lightBlue,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Login button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () async {
                      // Validate email format
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (_emailController.text.isEmpty || !emailRegex.hasMatch(_emailController.text.trim())) {
                        ValidationSnackbar.showFieldValidationError(context);
                        return;
                      }

                      // Validate password
                      if (_passwordController.text.isEmpty) {
                        ValidationSnackbar.showFieldValidationError(context);
                        return;
                      }

                      setState(() {
                        _isLoading = true;
                      });

                      try {
                        final authService = Provider.of<AuthService>(context, listen: false);
                        
                        // Attempt to sign in
                        final success = await authService.signInWithEmailAndPassword(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        );
                        
                        if (success) {
                          // Force check if email is verified with the latest data
                          bool isVerified = await authService.checkEmailVerified();
                          
                          if (!isVerified && !authService.isEmailVerified) {
                            // Show verification dialog
                            _showVerificationDialog(context);
                            // Sign out since email is not verified
                            await authService.signOut();
                          } else {
                            // Email is verified, proceed with login
                            SuccessSnackbar.showLoginSuccess(context: context);
                            
                            // Get user role for navigation
                            String? userRole = authService.getUserRole();
                            
                            // Navigate based on user role
                            Future.delayed(const Duration(seconds: 1), () {
                              if (mounted) {
                                if (userRole == 'car_owner') {
                                  Navigator.pushReplacementNamed(context, AppRoutes.carOwner);
                                } else if (userRole == 'customer') {
                                  Navigator.pushReplacementNamed(context, AppRoutes.home);
                                } else {
                                  // Default fallback: go to home
                                  Navigator.pushReplacementNamed(context, AppRoutes.home);
                                }
                              }
                            });
                          }
                        } else {
                          // Login failed
                          ErrorSnackbar.showAuthError(
                            context: context,
                            customMessage: authService.errorMessage ?? 'Invalid email or password',
                          );
                        }
                      } catch (e) {
                        print('Login error: $e');
                        ErrorSnackbar.showAuthError(
                          context: context,
                          customMessage: 'An unexpected error occurred: ${e.toString()}',
                        );
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
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
                      'LOGIN',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Forgot password
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.forgotPassword);
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: AppTheme.paleBlue,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Don't have an account section
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: AppTheme.paleBlue),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.signup);
                      },
                      child: const Text(
                        'Sign up',
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
