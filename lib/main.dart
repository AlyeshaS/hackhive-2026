import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth/login_screen.dart';
import 'partner/partner_screen.dart';
import 'preferences/preferences_screen.dart';
import 'suggestions/suggestions_screen.dart';
import 'welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final customColorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: const Color(0xFF96616B), // mauve
      onPrimary: const Color(0xFFFFFFFF),
      secondary: const Color(0xFF96616B), // unified mauve
      onSecondary: const Color(0xFFFFFFFF),
      background: const Color(0xFFFFEAD0), // soft peach
      onBackground: const Color(0xFF220C10), // deep burgundy
      surface: const Color(0xFFFFEAD0),
      onSurface: const Color(0xFF220C10),
      error: Colors.red,
      onError: Colors.white,
      primaryContainer: Color(0x3396616B), // 20% opacity mauve
      onPrimaryContainer: const Color(0xFF220C10),
      secondaryContainer: Color(0x3396616B), // 20% opacity mauve
      onSecondaryContainer: const Color(0xFF220C10),
      surfaceVariant: Color(0x1996616B), // 10% opacity mauve
      onSurfaceVariant: const Color(0xFF220C10),
      outline: const Color(0xFF96616B),
      outlineVariant: const Color(0xFF96616B),
      scrim: const Color(0xFF220C10),
      inverseSurface: const Color(0xFF96616B),
      onInverseSurface: const Color(0xFFFFEAD0),
      inversePrimary: const Color(0xFF96616B),
    );
    return MaterialApp(
      title: 'Closr',
      theme: ThemeData(
        colorScheme: customColorScheme,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/main': (context) => const MainPage(),
        '/partner': (context) => PartnerScreen(),
        '/preferences': (context) => PreferencesScreen(),
        '/suggestions': (context) => SuggestionsScreen(),
      },
    );
  }
}
