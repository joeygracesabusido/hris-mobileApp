// src/auth/auth_notifier.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/providers/api_client.dart';
import 'auth_state.dart';

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _init();
    return const AuthState.initial();
  }

  Future<void> _init() async {
    const storage = FlutterSecureStorage();
    try {
      final token = await storage.read(key: 'auth_token');
      if (token != null && token.isNotEmpty) {
        state = AuthState.authenticated(token);
        return;
      }
    } catch (_) {}
    state = const AuthState.unauthenticated();
  }

  Future<void> login(String email, String password) async {
    state = const AuthState.loading();

    try {
      final response = await ApiClient.instance.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final token = response.data['auth_token'] as String?;
      if (token == null || token.isEmpty) {
        state = const AuthState.error('Invalid response from server');
        return;
      }

      const storage = FlutterSecureStorage();
      await storage.write(key: 'auth_token', value: token);
      state = AuthState.authenticated(token);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] as String? ??
          e.message ??
          'Login failed. Please try again.';
      state = AuthState.error(message);
    } catch (e) {
      state = const AuthState.error('An unexpected error occurred');
    }
  }

  Future<void> logout() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'auth_token');
    state = const AuthState.unauthenticated();
  }
}
