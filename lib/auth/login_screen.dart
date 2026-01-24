import 'package:flutter/material.dart';
import 'auth_service.dart';

class LoginScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.login),
          label: const Text('Sign in with Google'),
          onPressed: () async {
            final user = await _authService.signInWithGoogle();
            if (user != null) {
              Navigator.pushReplacementNamed(context, '/partner');
            } else {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Sign in failed')));
            }
          },
        ),
      ),
    );
  }
}
