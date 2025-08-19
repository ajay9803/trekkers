import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();

  DateTime? _dob;
  File? _profileImage;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _dob = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Date of Birth')),
      );
      return;
    }

    if (DateTime.now().year - _dob!.year < 13) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be at least 13 years old')),
      );
      return;
    }

    if (_profileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a profile image')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Provider.of<AuthProvider>(context, listen: false).signUpWithDetails(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        address: _addressController.text.trim(),
        dob: _dob!,
        profileImage: _profileImage,
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Signup failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.greenAccent, Colors.lightGreen],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Profile Image
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.green.shade100,
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : null,
                          child: _profileImage == null
                              ? const Icon(
                                  Icons.camera_alt,
                                  size: 40,
                                  color: Colors.black54,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Username
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person),
                          labelText: "Username",
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) => val == null || val.isEmpty
                            ? 'Enter username'
                            : null,
                      ),
                      const SizedBox(height: 15),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.email),
                          labelText: "Email",
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Enter email';
                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          if (!emailRegex.hasMatch(val))
                            return 'Enter valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.lock),
                          labelText: "Password",
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (val) => val == null || val.length < 6
                            ? 'Min 6 characters'
                            : null,
                      ),
                      const SizedBox(height: 15),

                      // Address
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.home),
                          labelText: "Address",
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Enter address' : null,
                      ),
                      const SizedBox(height: 15),

                      // DOB
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _dob == null
                                  ? "Select Date of Birth"
                                  : "DOB: ${DateFormat('yyyy-MM-dd').format(_dob!)}",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _pickDate,
                            icon: const Icon(Icons.calendar_today),
                            label: const Text("Pick Date"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),

                      // Submit Button
                      _isLoading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _submit,
                                child: const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
