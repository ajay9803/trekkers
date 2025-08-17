import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trekkers/screens/main_screen.dart';
import 'package:trekkers/screens/register_screen.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Email field
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            // Password field
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            // Login with Email/Password
            ElevatedButton(
              onPressed: () async {
                try {
                  await auth.signInWithEmail(
                    _emailController.text,
                    _passwordController.text,
                  );
                  if (auth.isLoggedIn) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const MainTabsScreen()),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
                }
              },
              child: const Text('Login with Email'),
            ),
            const SizedBox(height: 8),
            // Go to Signup
            TextButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const SignupScreen()));
              },
              child: const Text('Create New Account'),
            ),
            const SizedBox(height: 16),
            // Social login buttons
            // ElevatedButton.icon(
            //   onPressed: () async {
            //     try {
            //       await auth.signInWithGoogle();
            //       if (auth.isLoggedIn) {
            //         Navigator.of(context).pushReplacement(
            //             MaterialPageRoute(builder: (_) => const HomeScreen()));
            //       }
            //     } catch (e) {
            //       ScaffoldMessenger.of(context).showSnackBar(
            //           SnackBar(content: Text('Google login failed: $e')));
            //     }
            //   },
            //   icon: const Icon(Icons.login),
            //   label: const Text('Login with Google'),
            // ),
            // const SizedBox(height: 16),
            // ElevatedButton.icon(
            //   onPressed: () async {
            //     try {
            //       await auth.signInWithFacebook();
            //       if (auth.isLoggedIn) {
            //         Navigator.of(context).pushReplacement(
            //             MaterialPageRoute(builder: (_) => const HomeScreen()));
            //       }
            //     } catch (e) {
            //       ScaffoldMessenger.of(context).showSnackBar(
            //           SnackBar(content: Text('Facebook login failed: $e')));
            //     }
            //   },
            //   icon: const Icon(Icons.login),
            //   label: const Text('Login with Facebook'),
            // ),
          ],
        ),
      ),
    );
  }
}
