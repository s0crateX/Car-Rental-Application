import 'package:flutter/material.dart';
import 'package:car_rental_app/features/presentation/screens/login_screen.dart';
import 'package:car_rental_app/features/presentation/screens/signup_screen.dart';
import 'package:car_rental_app/features/presentation/screens/forgot_password_screen.dart';

class AppRoutes {
  static const String login = '/';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
