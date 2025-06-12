import 'package:flutter/material.dart';
import 'package:car_rental_app/config/theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isSubmitting = false;
  bool _resetEmailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendResetEmail() {
    // Validate email
    if (_emailController.text.trim().isEmpty || !_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isSubmitting = false;
        _resetEmailSent = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
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
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  'Forgot Password',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
                
                const SizedBox(height: 10),
                
                // Instruction text
                Text(
                  _resetEmailSent 
                      ? 'Password reset email sent! Check your inbox.'
                      : 'Enter your email address to receive a password reset link',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.paleBlue,
                  ),
                ),
                
                const SizedBox(height: 40),

                if (!_resetEmailSent) ...[
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
                  
                  const SizedBox(height: 40),
                  
                  // Reset Password button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _sendResetEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.lightBlue,
                        foregroundColor: AppTheme.navy,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'SEND RESET LINK',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ] else ...[
                  // Success icon
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.mediumBlue.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle,
                        size: 60,
                        color: AppTheme.lightBlue,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Return to login button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.lightBlue,
                        foregroundColor: AppTheme.navy,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text(
                        'RETURN TO LOGIN',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: 20),
                
                // Help text
                if (!_resetEmailSent)
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Back to Login',
                        style: TextStyle(
                          color: AppTheme.paleBlue,
                        ),
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
}
