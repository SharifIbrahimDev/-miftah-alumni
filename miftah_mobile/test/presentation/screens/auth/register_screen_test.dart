import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:miftah_mobile/presentation/screens/auth/register_screen.dart';
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
  bool registerCalled = false;
  String? regName;
  String? regEmail;
  String? regPhone;
  String? regGender;
  String? regPassword;
  bool returnSuccess = true;

  FakeAuthProvider() : super(authRepository: MockAuthRepository());

  @override
  Future<void> register(String name, String email, String phone, String gender, String password) async {
    registerCalled = true;
    regName = name;
    regEmail = email;
    regPhone = phone;
    regGender = gender;
    regPassword = password;
    if (!returnSuccess) {
      // Simulate error
      // The parent class uses _error, so we can mock the property if needed.
    }
  }
}

void main() {
  testWidgets('Register screen submits data', (WidgetTester tester) async {
    final fakeAuthProvider = FakeAuthProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: fakeAuthProvider),
        ],
        child: const MaterialApp(
          home: RegisterScreen(),
        ),
      ),
    );

    final textFields = find.byType(TextField);
    expect(textFields, findsNWidgets(5));

    final nameField = textFields.at(0);
    final emailField = textFields.at(1);
    final phoneField = textFields.at(2);
    final passwordField = textFields.at(3);
    final confirmPasswordField = textFields.at(4);

    await tester.enterText(nameField, 'Jane Doe');
    await tester.enterText(emailField, 'jane@example.com');
    await tester.enterText(phoneField, '1234567890');
    await tester.enterText(passwordField, 'password123');
    await tester.enterText(confirmPasswordField, 'password123');
    await tester.pump();

    // The gender dropdown defaults to 'male', we can just use the default.

    final submitButton = find.text('SUBMIT ENROLLMENT REQUEST');
    
    // We need to scroll to the submit button because SingleChildScrollView might not have it in view
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(fakeAuthProvider.registerCalled, isTrue);
    expect(fakeAuthProvider.regName, 'Jane Doe');
    expect(fakeAuthProvider.regEmail, 'jane@example.com');
    expect(fakeAuthProvider.regPhone, '1234567890');
    expect(fakeAuthProvider.regGender, 'male');
    expect(fakeAuthProvider.regPassword, 'password123');

    // Pump to clear the success toast
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('Register screen validates empty fields', (WidgetTester tester) async {
    final fakeAuthProvider = FakeAuthProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: fakeAuthProvider),
        ],
        child: const MaterialApp(
          home: RegisterScreen(),
        ),
      ),
    );

    final submitButton = find.text('SUBMIT ENROLLMENT REQUEST');
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(fakeAuthProvider.registerCalled, isFalse);
    expect(find.text('Name is required'), findsOneWidget);
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Phone number is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    expect(find.text('Please confirm your password'), findsOneWidget);
  });
}
