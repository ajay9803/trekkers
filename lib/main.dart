import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trekkers/providers/bookings_provider.dart';
import 'package:trekkers/providers/treks_provider.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookingsProvider()),
        ChangeNotifierProvider(create: (_) => TreksProvider()),
      ],
      child: MaterialApp(
        title: 'trekkers',
        theme: ThemeData.dark().copyWith(
          primaryColor: const Color(0xFF2E7D32),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF2E7D32), // Main trekking green
            secondary: Color(0xFF80CBC4), // Teal accent (fresh trail vibe)
            surface: Color(0xFF121212), // App background
          ),
          textTheme: ThemeData.dark().textTheme.apply(
            fontFamily: 'Roboto',
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
        ),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
