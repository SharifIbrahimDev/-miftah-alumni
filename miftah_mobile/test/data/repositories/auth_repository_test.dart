import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:miftah_mobile/data/datasources/remote_data_source.dart';
import 'package:miftah_mobile/data/repositories/auth_repository_impl.dart';

class MockRemoteDataSource implements RemoteDataSource {
  int postStatusCode = 200;
  String postResponseBody = '';
  Map<String, dynamic>? lastPostBody;
  String? lastPostEndpoint;

  @override
  String get baseUrl => 'https://miftah-api.daynapp.com/api';

  @override
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    lastPostEndpoint = endpoint;
    lastPostBody = body;
    return http.Response(postResponseBody, postStatusCode);
  }

  @override
  Future<http.Response> get(String endpoint) async {
    return http.Response('', 200);
  }

  @override
  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    return http.Response('', 200);
  }

  @override
  Future<http.Response> delete(String endpoint) async {
    return http.Response('', 200);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterSecureStorage.setMockInitialValues({});

  late AuthRepositoryImpl authRepository;
  late MockRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    authRepository = AuthRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  group('AuthRepositoryImpl Password Reset', () {
    test('requestPasswordReset returns true on 200', () async {
      mockRemoteDataSource.postStatusCode = 200;
      final result = await authRepository.requestPasswordReset('test@example.com');
      
      expect(result, isTrue);
      expect(mockRemoteDataSource.lastPostEndpoint, '/forgot-password');
      expect(mockRemoteDataSource.lastPostBody?['email'], 'test@example.com');
    });

    test('requestPasswordReset returns false on non-200', () async {
      mockRemoteDataSource.postStatusCode = 400;
      final result = await authRepository.requestPasswordReset('test@example.com');
      
      expect(result, isFalse);
    });

    test('verifyOtp returns true on 200', () async {
      mockRemoteDataSource.postStatusCode = 200;
      final result = await authRepository.verifyOtp('test@example.com', '123456');
      
      expect(result, isTrue);
      expect(mockRemoteDataSource.lastPostEndpoint, '/verify-otp');
      expect(mockRemoteDataSource.lastPostBody?['email'], 'test@example.com');
      expect(mockRemoteDataSource.lastPostBody?['otp'], '123456');
    });

    test('verifyOtp returns false on non-200', () async {
      mockRemoteDataSource.postStatusCode = 400;
      final result = await authRepository.verifyOtp('test@example.com', '123456');
      
      expect(result, isFalse);
    });

    test('resetPassword returns true on 200', () async {
      mockRemoteDataSource.postStatusCode = 200;
      final result = await authRepository.resetPassword('test@example.com', '123456', 'newpass123');
      
      expect(result, isTrue);
      expect(mockRemoteDataSource.lastPostEndpoint, '/reset-password');
      expect(mockRemoteDataSource.lastPostBody?['email'], 'test@example.com');
      expect(mockRemoteDataSource.lastPostBody?['otp'], '123456');
      expect(mockRemoteDataSource.lastPostBody?['password'], 'newpass123');
    });

    test('resetPassword returns false on non-200', () async {
      mockRemoteDataSource.postStatusCode = 400;
      final result = await authRepository.resetPassword('test@example.com', '123456', 'newpass123');
      
      expect(result, isFalse);
    });
  });

  group('AuthRepositoryImpl Login & Register', () {
    test('login returns user on 200', () async {
      mockRemoteDataSource.postStatusCode = 200;
      mockRemoteDataSource.postResponseBody = '''
      {
        "user": {
          "id": 1,
          "name": "John Doe",
          "email": "john@example.com",
          "phone": "123",
          "gender": "male",
          "role": "member"
        },
        "token": "fake_token"
      }
      ''';

      final user = await authRepository.login('john@example.com', 'password123');

      expect(user, isNotNull);
      expect(user!.name, 'John Doe');
      expect(user.role, 'member');
      expect(mockRemoteDataSource.lastPostEndpoint, '/login');
      expect(mockRemoteDataSource.lastPostBody?['email'], 'john@example.com');
      expect(mockRemoteDataSource.lastPostBody?['password'], 'password123');
    });

    test('login returns null on non-200', () async {
      mockRemoteDataSource.postStatusCode = 401;
      mockRemoteDataSource.postResponseBody = '{"message":"Unauthorized"}';

      final user = await authRepository.login('john@example.com', 'wrongpass');

      expect(user, isNull);
    });

    test('register returns true on 201', () async {
      mockRemoteDataSource.postStatusCode = 201;

      final result = await authRepository.register('John Doe', 'john@example.com', '123456789', 'male', 'password123');

      expect(result, isTrue);
      expect(mockRemoteDataSource.lastPostEndpoint, '/register');
      expect(mockRemoteDataSource.lastPostBody?['name'], 'John Doe');
      expect(mockRemoteDataSource.lastPostBody?['email'], 'john@example.com');
    });

    test('register returns false on non-201/200', () async {
      mockRemoteDataSource.postStatusCode = 422;

      final result = await authRepository.register('John Doe', 'john@example.com', '123456789', 'male', 'password123');

      expect(result, isFalse);
    });
  });
}
