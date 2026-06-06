import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../../../core/utils/toast_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      final success = await context.read<AuthProvider>().updateProfile(
            oldPassword: _oldPasswordController.text,
            password: _passwordController.text,
            passwordConfirmation: _confirmPasswordController.text,
          );

      if (mounted) {
        if (success) {
          ToastService.showSuccess(context, 'Password changed successfully');
          Navigator.pop(context);
        } else {
          final error = context.read<AuthProvider>().error;
          ToastService.showError(context, error ?? 'Failed to change password');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Change Password',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Security',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Keep your account secure by using a strong password.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              CustomTextField(
                controller: _oldPasswordController,
                label: 'Current Password',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                validator: (value) => value == null || value.isEmpty ? 'Please enter your current password' : null,
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _passwordController,
                label: 'New Password',
                prefixIcon: Icons.lock_reset_outlined,
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a new password';
                  if (value.length < 6) return 'Password must be at least 6 characters';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _confirmPasswordController,
                label: 'Confirm New Password',
                prefixIcon: Icons.check_circle_outline,
                isPassword: true,
                validator: (value) {
                  if (value != _passwordController.text) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 48),
              CustomButton(
                text: 'C H A N G E  P A S S W O R D',
                isLoading: isLoading,
                onPressed: _changePassword,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
