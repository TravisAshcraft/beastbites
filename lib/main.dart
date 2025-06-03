import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Initialize local DB (if still used) and local notifications
  await DBHelper().database;
  await NotificationService().init(navigatorKey);

  // Load onboarding and signup status from SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
  final isSignedUp = prefs.getBool('isSignedUp') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChildProvider()),
        ChangeNotifierProvider(create: (_) => ChoreProvider()),
        ChangeNotifierProvider(create: (_) => RewardProvider()),
        ChangeNotifierProvider(create: (_) => PointsProvider()),
      ],
      child: MyApp(
        seenOnboarding: seenOnboarding,
        isSignedUp: isSignedUp,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool seenOnboarding;
  final bool isSignedUp;

  const MyApp({
    super.key,
    required this.seenOnboarding,
    required this.isSignedUp,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the initial screen
    final Widget initialScreen = !seenOnboarding
        ? const OnboardingScreen()
        : !isSignedUp
        ? const SignUpScreen()
        : const LoginScreen();

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
