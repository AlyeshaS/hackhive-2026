import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth/auth_service.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Closr Logo
              Image.asset(
                'assets/closr_logo.png',
                height: 150,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome to Closr',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Making together feel easier',
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.login),
                label: const Text('Sign in with Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () async {
                  await authService.signOut();
                  String? partnerEmail;
                  // Prompt for partner email before sign in
                  await showDialog(
                    context: context,
                    builder: (context) {
                      final controller = TextEditingController();
                      return AlertDialog(
                        title: const Text('Enter Partner Email (optional)'),
                        content: TextField(
                          controller: controller,
                          decoration: const InputDecoration(
                            hintText: 'Partner Email',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              partnerEmail = controller.text.trim();
                              Navigator.of(context).pop();
                            },
                            child: const Text('Continue'),
                          ),
                        ],
                      );
                    },
                  );
                  final user = await authService.signInWithGoogle(
                    partnerEmail: partnerEmail,
                  );
                  if (user != null) {
                    Navigator.pushReplacementNamed(context, '/main');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sign in failed')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
