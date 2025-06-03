import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  /// Call this when onboarding is finished:
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    // After setting the flag, navigate to PIN login:
    Navigator.of(context).pushReplacementNamed('/signup');
  }

  void _onNextTapped() {
    if (_currentIndex < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Last page: finish onboarding
      _completeOnboarding();
    }
  }

  void _onSkipTapped() {
    _completeOnboarding();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildPage({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 120, color: Theme.of(context).primaryColor),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Get Started'),
        automaticallyImplyLeading: false,
        actions: [
          if (_currentIndex < 2)
            TextButton(
              onPressed: _onSkipTapped,
              child: const Text(
                'Skip',
                style: TextStyle(color: Colors.white),
              ),
            )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (idx) => setState(() => _currentIndex = idx),
              children: [
                _buildPage(
                  icon: Icons.family_restroom,
                  title: 'Welcome to Beast Bites!',
                  subtitle:
                  'A fun way to assign chores, feed your monsters, and earn rewards as a family.',
                ),
                _buildPage(
                  icon: Icons.group_add,
                  title: 'Create Your Family',
                  subtitle:
                  'Add Parent and Child profiles so everyone can track chores and points.',
                ),
                _buildPage(
                  icon: Icons.lock_outline,
                  title: 'Set Your PIN',
                  subtitle:
                  'Choose a 4‐digit PIN that you’ll use to log in each time.',
                ),
              ],
            ),
          ),

          // Dot indicators + Next / Done button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                    (idx) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == idx ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == idx
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onNextTapped,
                child: Text(
                  _currentIndex < 2 ? 'Next' : 'Done',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
