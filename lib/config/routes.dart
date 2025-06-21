import 'package:flutter/material.dart';
import 'package:car_rental_app/presentation/screens/Login%20and%20Signup/login_screen.dart';
import 'package:car_rental_app/presentation/screens/Login%20and%20Signup/signup_screen.dart';
import 'package:car_rental_app/presentation/screens/Login%20and%20Signup/forgot_password_screen.dart';
import 'package:car_rental_app/presentation/screens/customer/customer_screen.dart';
import 'package:car_rental_app/presentation/screens/Car%20Owner/car_owner_screen.dart';
import 'package:car_rental_app/presentation/screens/Car%20Owner/my_cars/add_new_car_screen.dart';

class AppRoutes {
  static const String login = '/';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String carOwner = '/car-owner';
  static const String addNewCar = '/add-new-car';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const CustomerScreen());
      case carOwner:
        return MaterialPageRoute(builder: (_) => const CarOwnerScreen());
      case addNewCar:
        return MaterialPageRoute(builder: (_) => const AddNewCarScreen());
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
