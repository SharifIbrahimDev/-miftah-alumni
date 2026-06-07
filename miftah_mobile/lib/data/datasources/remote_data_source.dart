import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/utils/secure_storage_manager.dart';

class RemoteDataSource {
  final String baseUrl = 'https://miftah-api.daynapp.com/api';

  Future<Map<String, String>> _getHeaders() async {
    final token = await SecureStorageManager.getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
      headers['X-Authorization'] = 'Bearer $token'; // Bypasses strict cPanel Apache/LiteSpeed blocks
    }
    return headers;
  }

  static final List<Map<String, dynamic>> _mockClaims = [];
  static int _mockClaimIdCounter = 1;

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    if (endpoint == '/payment-claims') {
      await Future.delayed(const Duration(seconds: 1));
      final newClaim = {
        'id': _mockClaimIdCounter++,
        'user_id': body['user_id'],
        'user': {'name': 'Mock User'}, // Ideally would use real name, but good enough for mock
        'amount': body['amount'],
        'type': body['type'],
        'reference_id': body['reference_id'],
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      };
      _mockClaims.add(newClaim);
      return http.Response(jsonEncode(newClaim), 201);
    }

    final headers = await _getHeaders();
    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 10));
  }

  Future<http.Response> get(String endpoint) async {
    if (endpoint == '/payment-claims') {
      await Future.delayed(const Duration(seconds: 1));
      return http.Response(jsonEncode(_mockClaims), 200);
    }

    final headers = await _getHeaders();
    return await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    ).timeout(const Duration(seconds: 10));
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    if (endpoint.startsWith('/payment-claims/')) {
      await Future.delayed(const Duration(seconds: 1));
      final id = int.parse(endpoint.split('/').last);
      final index = _mockClaims.indexWhere((c) => c['id'] == id);
      if (index != -1) {
        _mockClaims[index]['status'] = body['status'];
        return http.Response(jsonEncode(_mockClaims[index]), 200);
      }
      return http.Response('Not found', 404);
    }

    final headers = await _getHeaders();
    return await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 10));
  }

  Future<http.Response> delete(String endpoint) async {
    final headers = await _getHeaders();
    return await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    ).timeout(const Duration(seconds: 10));
  }
}
