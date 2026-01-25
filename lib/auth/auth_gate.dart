import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: Future.value(FirebaseAuth.instance.currentUser),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        if (user != null) {
          // User is signed in, go to main
          Future.microtask(() => Navigator.pushReplacementNamed(context, '/main'));
        } else {
          // User not signed in, go to welcome
          Future.microtask(() => Navigator.pushReplacementNamed(context, '/welcome'));
        }
        // Show a blank screen while redirecting
        return const Scaffold(body: SizedBox.shrink());
      },
    );
  }
}
