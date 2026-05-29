// src/data/providers/api_client.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio dio;
  final _secureStorage = const FlutterSecureStorage();

  factory ApiClient() => _instance;

  ApiClient._internal() {
    final baseUrl = dotenv.env['DATABASE_URL']?.replaceAll('mongodb', 'https') ?? '';
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    ))
      ..interceptors.add(InterceptorsWrapper(onRequest: (options, handler) async {
        // Attach auth token if present
        final token = await _secureStorage.read(key: 'auth_token');
        if (token != null) {
          options.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
        }
        return handler.next(options);
      }, onError: (DioError e, handler) {
        // Centralized error handling
        return handler.next(e);
      }));
  }
}
