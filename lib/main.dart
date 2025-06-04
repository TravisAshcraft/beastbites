// lib/main.dart

import 'package:beast_bites/screens/confirmation_screen.dart';
import 'package:beast_bites/screens/splash_screen.dart';
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

  await Supabase.initialize(
    url: 'https://jyrznslsxjkxsetusxrf.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp5cnpuc2xzeGpreHNldHVzeHJmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg4OTUzOTksImV4cCI6MjA2NDQ3MTM5OX0.dCU3CdYIS5LsF-K7HutFuj2u4whRNaikina50NQqCMA',
  );

  // Setup local services
  await DBHelper().database;
  await NotificationService().init(navigatorKey);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChildProvider()),
        ChangeNotifierProvider(create: (_) => ChoreProvider()),
        ChangeNotifierProvider(create: (_) => RewardProvider()),
        ChangeNotifierProvider(create: (_) => PointsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beast Bites (Chore App)',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(), // 🎯 start here now
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/signup': (_) => const SignUpScreen(),
        '/login': (_) => const LoginScreen(),
        '/parentHome': (_) => const ParentHomeScreen(),
        '/childHome': (_) => const ChildHomeScreen(),
        '/childRewards': (_) => const ChildRewardsScreen(),
        '/addChore': (_) => const AddChoreScreen(),
        '/addReward': (_) => const AddRewardScreen(),
        '/childProgress': (_) => const ChildProgressScreen(),
        '/confirm-email': (_) => const ConfirmEmailScreen(),
      },
    );
  }
}
