// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _pinController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;

  Future<void> _attemptLogin() async {
    final enteredPin = _pinController.text.trim();
    if (enteredPin.length != 4 || !RegExp(r'^\d{4}$').hasMatch(enteredPin)) {
      setState(() => _errorText = 'Enter a valid 4-digit PIN.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString('parentPin');

    await Future.delayed(const Duration(milliseconds: 300)); // simulate small delay

    if (savedPin != null && enteredPin == savedPin) {
      // PIN correct → navigate to Parent Home (or Child Home, depending on your logic).
      // Here assuming only parent login for simplicity:
      Navigator.of(context).pushReplacementNamed('/parentHome');
    } else {
      setState(() {
        _errorText = 'Incorrect PIN. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter PIN'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter your 4-digit PIN to continue',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _pinController,
                decoration: InputDecoration(
                  labelText: 'PIN',
                  errorText: _errorText,
                  prefixIcon: const Icon(Icons.lock_open),
                ),
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                onSubmitted: (_) => _attemptLogin(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _attemptLogin,
                  child: _isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                      : const Text('Log In', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
