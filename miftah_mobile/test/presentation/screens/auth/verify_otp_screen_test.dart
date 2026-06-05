import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:miftah_mobile/presentation/screens/auth/verify_otp_screen.dart';
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
  bool verifyOtpCalled = false;
  String? verifyEmail;
  String? verifyOtpValue;
  bool returnSuccess = true;

  FakeAuthProvider() : super(authRepository: MockAuthRepository());

  @override
  Future<bool> verifyOtp(String email, String otp) async {
    verifyOtpCalled = true;
    verifyEmail = email;
    verifyOtpValue = otp;
    return returnSuccess;
  }
}

void main() {
  testWidgets('Verify OTP screen verifies code', (WidgetTester tester) async {
    final fakeAuthProvider = FakeAuthProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: fakeAuthProvider),
        ],
        child: const MaterialApp(
          home: VerifyOtpScreen(email: 'test@example.com'),
        ),
      ),
    );

    // Find OTP field
    final otpField = find.byType(TextField).first;
    expect(otpField, findsOneWidget);

    // Enter 6-digit OTP
    await tester.enterText(otpField, '123456');
    await tester.pump();

    // Find and tap Verify Code button
    final verifyButton = find.text('VERIFY CODE');
    expect(verifyButton, findsOneWidget);
    await tester.tap(verifyButton);
    await tester.pumpAndSettle();

    // Verify provider was called
    expect(fakeAuthProvider.verifyOtpCalled, isTrue);
    expect(fakeAuthProvider.verifyEmail, 'test@example.com');
    expect(fakeAuthProvider.verifyOtpValue, '123456');

    // Pump out the toast timer
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('Verify OTP screen shows error on short OTP', (WidgetTester tester) async {
    final fakeAuthProvider = FakeAuthProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: fakeAuthProvider),
        ],
        child: const MaterialApp(
          home: VerifyOtpScreen(email: 'test@example.com'),
        ),
      ),
    );

    final otpField = find.byType(TextField).first;
    
    // Enter 4-digit OTP (invalid)
    await tester.enterText(otpField, '1234');
    await tester.pump();

    final verifyButton = find.text('VERIFY CODE');
    await tester.tap(verifyButton);
    await tester.pumpAndSettle();

    // Verify provider was NOT called
    expect(fakeAuthProvider.verifyOtpCalled, isFalse);

    // Pump out the toast timer
    await tester.pump(const Duration(seconds: 4));
  });
}
