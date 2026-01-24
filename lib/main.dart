import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth/auth_service.dart';
import 'auth/login_screen.dart';
import 'partner/partner_screen.dart';
import 'preferences/preferences_screen.dart';
import 'suggestions/suggestions_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(body: Center(child: Text('Firebase init error'))),
          );
        }
        return MaterialApp(
          title: 'Couples Date Planner',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => LoginScreen(),
            '/partner': (context) => PartnerScreen(),
            '/preferences': (context) => PreferencesScreen(),
            '/suggestions': (context) => SuggestionsScreen(),
          },
        );
      },
    );
  }
}
