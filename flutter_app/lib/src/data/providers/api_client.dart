// src/data/providers/api_client.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio dio;

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
  }
}
