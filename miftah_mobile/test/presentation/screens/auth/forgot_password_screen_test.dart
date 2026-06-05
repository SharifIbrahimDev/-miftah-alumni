import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:miftah_mobile/presentation/screens/auth/forgot_password_screen.dart';
import 'package:miftah_mobile/presentation/providers/auth_provider.dart';
import 'package:miftah_mobile/domain/repositories/auth_repository.dart';
import 'package:miftah_mobile/domain/entities/user.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<User?> getMe() async => null;
  @override
  Future<User?> login(String email, String password) async => null;
  @override
  Future<void> logout() async {}
  @override
  Future<bool> register(String name, String email, String phone, String gender, String password) async => false;
  @override
  Future<bool> requestPasswordReset(String email) async => true;
  @override
  Future<bool> resetPassword(String email, String otp, String newPassword) async => true;
  @override
  Future<User?> updateProfile({String? name, String? email, String? phone, String? gender, String? oldPassword, String? password, String? passwordConfirmation}) async => null;
  @override
  Future<bool> verifyOtp(String email, String otp) async => true;
}

class FakeAuthProvider extends AuthProvider {
  bool requestPasswordResetCalled = false;
  String? requestedEmail;
  bool returnSuccess = true;

  FakeAuthProvider() : super(authRepository: MockAuthRepository());

  @override
  Future<bool> requestPasswordReset(String email) async {
    requestPasswordResetCalled = true;
    requestedEmail = email;
    return returnSuccess;
  }
}

void main() {
  testWidgets('Forgot password screen sends OTP', (WidgetTester tester) async {
    final fakeAuthProvider = FakeAuthProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: fakeAuthProvider),
        ],
        child: const MaterialApp(
          home: ForgotPasswordScreen(),
        ),
      ),
    );

    // Find email field
    final emailField = find.byType(TextField).first;
    expect(emailField, findsOneWidget);

    // Enter email
    await tester.enterText(emailField, 'test@example.com');
    await tester.pump();

    // Find and tap Send OTP button
    final sendButton = find.text('SEND OTP');
    expect(sendButton, findsOneWidget);
    await tester.tap(sendButton);
    await tester.pumpAndSettle();

    // Verify provider was called
    expect(fakeAuthProvider.requestPasswordResetCalled, isTrue);
    expect(fakeAuthProvider.requestedEmail, 'test@example.com');
    
    // Pump out the toast timer
    await tester.pump(const Duration(seconds: 4));
  });
}
