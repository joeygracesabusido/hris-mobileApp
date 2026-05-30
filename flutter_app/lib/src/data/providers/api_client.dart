// src/data/providers/api_client.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio dio;

  /// Auth headers injected on every request so the backend can identify
  /// the user without relying on cookies (which can't be set on web).
  static Map<String, String>? _authHeaders;

  static set authHeaders(Map<String, String>? value) => _authHeaders = value;

  static ApiClient get instance => _instance;

  factory ApiClient() => _instance;

  ApiClient._internal() {
    var baseUrl = dotenv.env['API_BASE_URL'] ?? 'https://hris-carigara-project.vercel.app/api/';
    if (!baseUrl.endsWith('/')) baseUrl += '/';
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_authHeaders != null) {
          options.headers.addAll(_authHeaders!);
        }
        handler.next(options);
      },
    ));
  }
}
