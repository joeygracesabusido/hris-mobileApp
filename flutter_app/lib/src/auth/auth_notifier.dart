// src/auth/auth_notifier.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/providers/api_client.dart';
import 'auth_state.dart';

class AuthNotifier extends Notifier<AuthState> {
  late final Future<void> _initFuture;

  Future<void> _writeSecure(String key, String value) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } else {
      const storage = FlutterSecureStorage();
      await storage.write(key: key, value: value);
    }
  }

  Future<String?> _readSecure(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } else {
      const storage = FlutterSecureStorage();
      return await storage.read(key: key);
    }
  }

  Future<void> _deleteSecure(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } else {
      const storage = FlutterSecureStorage();
      await storage.delete(key: key);
    }
  }

  @override
  AuthState build() {
    _initFuture = _init();
    return const AuthState.initial();
  }

  Future<void> _init() async {
    try {
      final userData = await _readSecure('user_data');
      if (userData != null && userData.isNotEmpty) {
        final user = jsonDecode(userData) as Map<String, dynamic>;
        state = AuthState.authenticated(user);
        return;
      }
    } catch (_) {}
    state = const AuthState.unauthenticated();
  }

  Future<void> login(String username, String password) async {
    await _initFuture;
    state = const AuthState.loading();

    try {
      final response = await ApiClient.instance.dio.post(
        '/login',
        data: {'username': username, 'password': password},
      );

      final user = response.data['user'] as Map<String, dynamic>?;
      if (user == null) {
        state = const AuthState.error('Invalid response from server');
        return;
      }

      await _writeSecure('user_data', jsonEncode(user));
      state = AuthState.authenticated(user);
    } on DioException catch (e) {
      final message = e.response?.data?['error'] as String? ??
          e.message ??
          'Login failed. Please try again.';
      state = AuthState.error(message);
    } catch (e) {
      state = const AuthState.error('An unexpected error occurred');
    }
  }

  Future<void> logout() async {
    await _deleteSecure('user_data');
    state = const AuthState.unauthenticated();
  }
}
