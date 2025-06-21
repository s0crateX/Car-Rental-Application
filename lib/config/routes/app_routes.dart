import 'package:car_rental_app/presentation/screens/Car%20Owner/car_owner_screen.dart';
import 'package:car_rental_app/presentation/screens/Car%20Owner/my_cars/add_new_car_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String carOwner = '/';
  static const String addNewCar = '/add-new-car';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case carOwner:
        return MaterialPageRoute(builder: (_) => const CarOwnerScreen());
      case addNewCar:
        return MaterialPageRoute(builder: (_) => const AddNewCarScreen());
      // Add other routes here
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
