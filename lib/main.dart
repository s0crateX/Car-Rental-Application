import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:car_rental_app/config/routes.dart';
import 'package:car_rental_app/config/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations and system UI overlay style
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Rental App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
