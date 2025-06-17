import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:car_rental_app/core/authentication/auth_service.dart';
import 'package:car_rental_app/features/presentation/screens/Login and Signup/login_screen.dart';
import 'package:car_rental_app/features/presentation/screens/customer/customer_screen.dart';
// TODO: Add imports for admin and car owner screens if needed

class SessionGate extends StatefulWidget {
  const SessionGate({super.key});

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  bool _loading = true;
  Widget? _targetScreen;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final hasSession = await authService.hasSession();
    if (!mounted) return;
    if (hasSession) {
      final role = await authService.getSavedRole();
      if (role == 'customer') {
        setState(() => _targetScreen = const CustomerScreen());
      } else {
        // TODO: Implement admin/car_owner screen routing
        setState(() => _targetScreen = const CustomerScreen());
      }
    } else {
      setState(() => _targetScreen = const LoginScreen());
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _targetScreen!;
  }
}
