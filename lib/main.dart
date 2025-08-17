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
        theme: ThemeData(primarySwatch: Colors.green),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
