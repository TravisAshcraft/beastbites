// lib/screens/sign_up_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController    = TextEditingController();
  final _emailController   = TextEditingController();
  final _pinController     = TextEditingController();
  final _confirmPinController = TextEditingController();

  bool _isLoading = false;

  Future<void> _attemptSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    final name  = _nameController.text.trim();
    final email = _emailController.text.trim();
    final pin   = _pinController.text.trim();

    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('parentName', name);
    await prefs.setString('parentEmail', email);
    await prefs.setString('parentPin', pin);
    await prefs.setBool('isSignedUp', true);

    setState(() => _isLoading = false);

    // Navigate to the login screen (replace current route)
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an email.';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  String? _validatePin(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter a 4-digit PIN.';
    }
    if (value.length != 4 || !RegExp(r'^\d{4}$').hasMatch(value)) {
      return 'PIN must be exactly 4 digits.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Parent Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Parent Name',
                      prefixIcon: Icon(Icons.person),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Please enter your name.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Parent Email
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 16),

                  // PIN
                  TextFormField(
                    controller: _pinController,
                    decoration: const InputDecoration(
                      labelText: 'Choose 4-digit PIN',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    textInputAction: TextInputAction.next,
                    validator: _validatePin,
                  ),
                  const SizedBox(height: 8),

                  // Confirm PIN
                  TextFormField(
                    controller: _confirmPinController,
                    decoration: const InputDecoration(
                      labelText: 'Confirm PIN',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      final err = _validatePin(value);
                      if (err != null) return err;
                      if (value!.trim() != _pinController.text.trim()) {
                        return 'PINs do not match.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Sign Up button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _attemptSignUp,
                      child: _isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                          : const Text('Sign Up', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
