import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/shared_prefs_manager.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Connect & Network',
      'subtitle': 'Join a powerful network of Miftahul Ulum Al-Islamiyya alumni globally. Forge lifelong bonds and professional connections.',
      'icon': 'people_alt_outlined'
    },
    {
      'title': 'Fund the Future',
      'subtitle': 'Seamlessly contribute your monthly dues and support strategic projects that elevate our beloved alma mater.',
      'icon': 'account_balance_wallet_outlined'
    },
    {
      'title': 'Track Transparency',
      'subtitle': 'Access real-time financial dashboards, monitor project goals, and see exactly where your contributions go.',
      'icon': 'query_stats'
    },
  ];

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'people_alt_outlined': return Icons.people_alt_outlined;
      case 'account_balance_wallet_outlined': return Icons.account_balance_wallet_outlined;
      case 'query_stats': return Icons.query_stats;
      default: return Icons.star;
    }
  }

  void _finishOnboarding() async {
    await SharedPrefsManager.setBool('has_seen_onboarding', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, Color(0xFF002B24)],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _finishOnboarding,
                    child: Text('Skip', style: GoogleFonts.inter(color: Colors.white70, fontWeight: FontWeight.bold)),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemCount: _onboardingData.length,
                    itemBuilder: (context, index) {
                      final data = _onboardingData[index];
                      return Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.accent.withOpacity(0.2)),
                              ),
                              child: Icon(
                                _getIcon(data['icon']!),
                                size: 100,
                                color: AppColors.accent,
                              ),
                            ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack).fadeIn(),
                            const SizedBox(height: 60),
                            Text(
                              data['title']!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ).animate().slideY(begin: 0.5, duration: 400.ms).fadeIn(),
                            const SizedBox(height: 20),
                            Text(
                              data['subtitle']!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: Colors.white70,
                                height: 1.5,
                              ),
                            ).animate().slideY(begin: 0.5, duration: 400.ms, delay: 100.ms).fadeIn(),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(
                          _onboardingData.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 8),
                            height: 8,
                            width: _currentPage == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index ? AppColors.accent : Colors.white24,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      FloatingActionButton(
                        onPressed: () {
                          if (_currentPage == _onboardingData.length - 1) {
                            _finishOnboarding();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        backgroundColor: AppColors.accent,
                        child: Icon(
                          _currentPage == _onboardingData.length - 1 ? Icons.check : Icons.arrow_forward_ios,
                          color: AppColors.primary,
                        ),
                      ).animate(target: _currentPage == _onboardingData.length - 1 ? 1 : 0).scale(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
