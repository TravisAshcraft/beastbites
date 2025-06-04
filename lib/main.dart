// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Screens
import 'screens/onboarding_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/login_screen.dart';
import 'screens/parent_home_screen.dart';
import 'screens/child_home_screen.dart';
import 'screens/child_rewards_screen.dart';
import 'screens/add_chore_screen.dart';
import 'screens/add_reward_screen.dart';
import 'screens/child_progress_screen.dart';

// Providers
import 'providers/child_provider.dart';
import 'providers/chore_provider.dart';
import 'providers/reward_provider.dart';
import 'providers/points_provider.dart';

// Services
import 'services/db_helper.dart';
import 'services/notification_services.dart';

// Global navigator key (used for notifications or onboarding nav)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Initialize Supabase
  await Supabase.initialize(
    url: 'https://jyrznslsxjkxsetusxrf.supabase.co',
    anonKey:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp5cnpuc2xzeGpreHNldHVzeHJmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg4OTUzOTksImV4cCI6MjA2NDQ3MTM5OX0.dCU3CdYIS5LsF-K7HutFuj2u4whRNaikina50NQqCMA',
  );

  // 2) Listen for OAuth callbacks so that when the Google‐OAuth deep‐link fires,
  //    you save “isSignedUp” and navigate immediately to /parentHome.
  Supabase.instance.client.auth.onAuthStateChange.listen((event) async {
    final session = event.session;
    final user = session?.user;

    if (session != null && user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isSignedUp', true);
      await prefs.setString('parentEmail', user.email ?? '');
      await prefs.setString('parentName', user.userMetadata?['full_name'] ?? '');

      // If you’re already in the middle of onboarding/login, jump to parentHome:
      navigatorKey.currentState?.pushReplacementNamed('/parentHome');
    }
  });

  // 3) Check “already logged in” at startup
  final currentSession = Supabase.instance.client.auth.currentSession;

  // 4) Initialize local DB and notifications
  await DBHelper().database;
  await NotificationService().init(navigatorKey);

  // 5) Load onboarding + signup state from SharedPreferences (old logic)
  final prefs = await SharedPreferences.getInstance();
  final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
  final isSignedUp = prefs.getBool('isSignedUp') ?? false;

  // 6) Determine which screen to show first. If Supabase already has a session,
  //    treat that as “signed up & signed in,” and show ParentHomeScreen right away.
  Widget initialScreen;
  if (!seenOnboarding) {
    initialScreen = const OnboardingScreen();
  } else if (currentSession != null && currentSession.user != null) {
    // **User is already signed in via Google** → go to parentHome
    initialScreen = const ParentHomeScreen();
  } else if (!isSignedUp) {
    // Seen onboarding but not “signed up” yet → show your email‐signup flow
    initialScreen = const SignUpScreen();
  } else {
    // Otherwise, show the login screen (which now does Google‐OAuth)
    initialScreen = const LoginScreen();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChildProvider()),
        ChangeNotifierProvider(create: (_) => ChoreProvider()),
        ChangeNotifierProvider(create: (_) => RewardProvider()),
        ChangeNotifierProvider(create: (_) => PointsProvider()),
      ],
      child: MyApp(initialScreen: initialScreen),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;

  const MyApp({
    Key? key,
    required this.initialScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beast Bites (Chore App)',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: initialScreen,
      routes: {
        '/onboarding': (_) => const OnboardingScreen(),
        '/signup': (_) => const SignUpScreen(),
        '/login': (_) => const LoginScreen(),
        '/parentHome': (_) => const ParentHomeScreen(),
        '/childHome': (_) => const ChildHomeScreen(),
        '/childRewards': (_) => const ChildRewardsScreen(),
        '/addChore': (_) => const AddChoreScreen(),
        '/addReward': (_) => const AddRewardScreen(),
        '/childProgress': (_) => const ChildProgressScreen(),
      },
    );
  }
}
