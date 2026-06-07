import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/shared_prefs_manager.dart';
import '../auth/login_screen.dart';
import 'onboarding_screen.dart';
import '../dashboard/dashboard_selector.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    // Start auth check and a minimum timer in parallel
    final results = await Future.wait([
      context.read<AuthProvider>().checkStatus(),
      Future.delayed(const Duration(milliseconds: 1500)), // Reduced from 3s
    ]);

    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();

    final hasSeenOnboarding = SharedPrefsManager.getBool('has_seen_onboarding') ?? false;

    if (authProvider.isAuthenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardSelector()),
      );
    } else if (!hasSeenOnboarding) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/images/miftah_bg.png',
            fit: BoxFit.cover,
          ),
          
          // Gradient Overlay for Better Contrast
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.5),
                  AppColors.primary.withValues(alpha: 0.8),
                ],
              ),
            ),
          ),

          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: AnimateList(
                interval: 200.ms,
                effects: [FadeEffect(duration: 800.ms), ScaleEffect(begin: const Offset(0.9, 0.9))],
                children: [
                  // App Logo
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/app_icon.png',
                        width: 140,
                        height: 140,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scaleXY(begin: 0.98, end: 1.02, duration: 2.seconds),
                  const SizedBox(height: 48),
                  
                  // App Title
                  const Text(
                    'Miftah Alumni Hub',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          offset: Offset(0, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Subtitle
                  const Text(
                    'Miftahul Ulum Al-Islamiyya',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 80),
                  
                  // Loading Indicator
                  const SpinKitPulse(
                    color: AppColors.accent,
                    size: 50.0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
