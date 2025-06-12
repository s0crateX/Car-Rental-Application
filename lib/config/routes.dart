import 'package:flutter/material.dart';
import 'package:car_rental_app/features/presentation/screens/Login%20and%20Signup/login_screen.dart';
import 'package:car_rental_app/features/presentation/screens/Login%20and%20Signup/signup_screen.dart';
import 'package:car_rental_app/features/presentation/screens/Login%20and%20Signup/forgot_password_screen.dart';
import 'package:car_rental_app/features/presentation/screens/Scout/scout_screen.dart';
import 'package:car_rental_app/features/presentation/screens/Home/home_screen.dart';

class AppRoutes {
  static const String login = '/';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String scout = '/scout';
  static const String home = '/home';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case scout:
        return MaterialPageRoute(builder: (_) => const ScoutScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
        );
    }
  }
}
