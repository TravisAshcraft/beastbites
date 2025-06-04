import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _determineStartScreen();
  }

  Future<void> _determineStartScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
    final isSignedUp = prefs.getBool('isSignedUp') ?? false;
    final session = supabase.auth.currentSession;

    print('💡 Splash: seenOnboarding=$seenOnboarding, isSignedUp=$isSignedUp');
    print('💡 Splash: session=${session != null}, user=${session?.user?.id}');

    if (!seenOnboarding) {
      print('➡️ Navigating to /onboarding');
      _navigateTo('/onboarding');
      return;
    }

    if (session != null && session.user != null) {
      final userId = session.user!.id;
      print('🔍 Checking Supabase for user with ID: $userId');

      try {
        final response = await supabase
            .from('users') // Replace with your correct table if needed
            .select()
            .eq('id', userId)
            .maybeSingle();

        print('🔁 Supabase user lookup response: $response');

        if (response == null) {
          // User was deleted in Supabase, so clear all state and restart signup
          print('❌ User not found in Supabase — signing out and clearing prefs');
          await supabase.auth.signOut();
          await prefs.clear();
          _navigateTo('/signup');
          return;
        }

        print('✅ Valid user found. Navigating to /parentHome');
        _navigateTo('/parentHome');
        return;
      } catch (e) {
        print('🔥 Error checking Supabase: $e');
        await supabase.auth.signOut();
        await prefs.clear();
        _navigateTo('/signup');
        return;
      }
    }

    // No session — check local signup status
    print('👤 No valid session found.');
    if (isSignedUp) {
      print('❌ Stale signup flag — clearing prefs and going to /signup');
      await prefs.clear(); // remove bad token path
      _navigateTo('/signup');
    } else {
      print('➡️ Navigating to /signup');
      _navigateTo('/signup');
    }
  }

  void _navigateTo(String route) {
    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlutterLogo(size: 80), // Replace with your logo
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}