import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

/// Centralized Dio client configured from environment variables.
///
/// - Reads `API_BASE_URL` and `API_KEY` from `.env` (loaded in `main.dart`).
/// - Sets sensible timeouts and default headers (Content-Type + API key).
/// - Exposes convenience methods and the underlying `Dio` for advanced use.
class DioClient {
  static final DioClient _instance = DioClient._internal();
  final Dio _dio;

  factory DioClient() => _instance;

  DioClient._internal()
      : _dio = Dio(BaseOptions(
          // Use API_BASE_URL only if it is set and non-empty; otherwise fall back to localhost for dev
          baseUrl: (() {
            final value = dotenv.env['API_BASE_URL']?.trim() ?? '';
            return value.isNotEmpty ? value : 'http://localhost:3000';
          })(),
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
          headers: {
            'Content-Type': 'application/json',
            // API key is sent using X-API-Key; Authorization Bearer is also set for convenience
            'X-API-Key': dotenv.env['API_KEY'] ?? '',
            'Authorization': 'Bearer ${dotenv.env['API_KEY'] ?? ''}',
          },
        )) {
    // Add an interceptor to log the baseUrl (temporary debug verification)
    _dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      if (kDebugMode) {
        // Print once per request so we can verify baseUrl at runtime in logs
        debugPrint('Dio request -> baseUrl: ${_dio.options.baseUrl}, path: ${options.path}');
      }
      return handler.next(options);
    }));

    if (kDebugMode) {
      debugPrint('DioClient initialized with baseUrl: ${_dio.options.baseUrl}');
    }
  }

  Dio get dio => _dio;

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(String path, {Object? data, Map<String, dynamic>? queryParameters}) async {
    return await _dio.post<T>(path, data: data, queryParameters: queryParameters);
  }

  Future<Response<T>> patch<T>(String path, {Object? data}) async {
    return await _dio.patch<T>(path, data: data);
  }

  Future<Response<T>> delete<T>(String path) async {
    return await _dio.delete<T>(path);
  }
}
