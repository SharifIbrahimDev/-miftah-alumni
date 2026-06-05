import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/utils/toast_service.dart';
import '../../../core/services/biometric_service.dart';
import '../../providers/auth_provider.dart';
import '../main_layout.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _hasBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final creds = await BiometricService.getCredentials();
    final canAuth = await BiometricService.isBiometricAvailable();
    if (creds != null && canAuth && mounted) {
      setState(() {
        _hasBiometrics = true;
      });
    }
  }

  Future<void> _biometricLogin() async {
    HapticFeedback.lightImpact();
    final authenticated = await BiometricService.authenticate();
    if (authenticated) {
      final creds = await BiometricService.getCredentials();
      if (creds != null) {
        _emailController.text = creds['email']!;
        _passwordController.text = creds['password']!;
        await _login();
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    HapticFeedback.lightImpact();
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (authProvider.isAuthenticated) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainLayout()),
      );
    } else {
      if (!mounted) return;
      ToastService.showError(context, authProvider.error ?? 'Login failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Gradient to prevent white gaps
          Container(color: AppColors.primary),
          
          SingleChildScrollView(
            child: Stack(
              children: [
                _buildHeader(),
                Padding(
                  padding: const EdgeInsets.only(top: 320, left: 20, right: 20),
                  child: _buildLoginForm(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        Container(
          height: 480,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.primary,
            image: DecorationImage(
              image: AssetImage('assets/images/miftah_bg.png'),
              fit: BoxFit.cover,
              opacity: 0.15,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.98),
                  const Color(0xFF023E23).withOpacity(0.95),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
          ),
        ),
        
        // Logo and Title Content
        SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                    ],
                    border: Border.all(color: AppColors.accent.withOpacity(0.6), width: 2),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/app_icon.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'MIFTAH ALUMNI HUB',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.5,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return GlassCard(
      opacity: 0.98,
      padding: const EdgeInsets.all(32),
      border: Border.all(color: Colors.white, width: 2),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Access your alumni executive dashboard',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 36),
            CustomTextField(
              controller: _emailController,
              label: 'Email Address',
              hint: 'name@example.com',
              prefixIcon: Icons.alternate_email_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: (val) => val == null || val.isEmpty ? 'Email is required' : null,
            ),
            const SizedBox(height: 24),
            CustomTextField(
              controller: _passwordController,
              label: 'Password',
              hint: '••••••••',
              isPassword: _obscurePassword,
              prefixIcon: Icons.lock_person_outlined,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (val) => val == null || val.isEmpty ? 'Password is required' : null,
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                  );
                },
                child: Text(
                  'Recovery Link?',
                  style: GoogleFonts.inter(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                return Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Sign In',
                        isLoading: auth.isLoading,
                        onPressed: _login,
                      ),
                    ),
                    if (_hasBiometrics) ...[
                      const SizedBox(width: 16),
                      Container(
                        height: 56,
                        width: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.fingerprint_rounded, color: AppColors.primary, size: 28),
                          onPressed: _biometricLogin,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "New here? ",
                  style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                  child: Text(
                    'Request Access',
                    style: GoogleFonts.inter(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
