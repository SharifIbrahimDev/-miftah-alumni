import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:miftah_mobile/presentation/screens/auth/login_screen.dart';
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
  bool loginCalled = false;
  String? loginEmail;
  String? loginPassword;

  FakeAuthProvider() : super(authRepository: MockAuthRepository());

  @override
  Future<void> login(String email, String password) async {
    loginCalled = true;
    loginEmail = email;
    loginPassword = password;
    // Do not set _user here if we just want to test if the method is called.
    // Setting _user would trigger navigation. For now just test if login was triggered.
  }
}

void main() {
  testWidgets('Login screen submits credentials', (WidgetTester tester) async {
    final fakeAuthProvider = FakeAuthProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: fakeAuthProvider),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    final textFields = find.byType(TextField);
    expect(textFields, findsNWidgets(2)); // Email and Password

    final emailField = textFields.first;
    final passwordField = textFields.last;

    await tester.enterText(emailField, 'test@example.com');
    await tester.enterText(passwordField, 'password123');
    await tester.pump();

    final signInButton = find.text('SIGN IN');
    expect(signInButton, findsOneWidget);

    await tester.ensureVisible(signInButton);
    await tester.tap(signInButton);
    await tester.pumpAndSettle();

    expect(fakeAuthProvider.loginCalled, isTrue);
    expect(fakeAuthProvider.loginEmail, 'test@example.com');
    expect(fakeAuthProvider.loginPassword, 'password123');
    
    await tester.pump(const Duration(seconds: 4)); // Pump toast timer
  });

  testWidgets('Login screen validates empty fields', (WidgetTester tester) async {
    final fakeAuthProvider = FakeAuthProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: fakeAuthProvider),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    final signInButton = find.text('SIGN IN');
    await tester.ensureVisible(signInButton);
    await tester.tap(signInButton);
    await tester.pumpAndSettle();

    expect(fakeAuthProvider.loginCalled, isFalse);
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });
}
