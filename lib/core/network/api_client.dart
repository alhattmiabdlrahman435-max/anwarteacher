import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../utils/constants.dart';
import '../providers/server_error_provider.dart';
import '../providers/auth_provider.dart';

part 'api_client.g.dart';

@Riverpod(keepAlive: true)
Dio apiClient(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Auth token interceptor: attaches Bearer token, handles connectivity/server error states, and session expiry.
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: AppConstants.tokenKey);
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
    onResponse: (response, handler) {
      // Clear server error state if a response is successfully received
      ref.read(serverErrorProvider.notifier).setHasError(false);
      return handler.next(response);
    },
    onError: (DioException e, handler) {
      // If error is connection timeout, connection error, or 5xx server status
      final isConnectionError = e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionError;
      
      final isServerError = e.response != null && e.response!.statusCode != null && e.response!.statusCode! >= 500;
      
      if (isConnectionError || isServerError) {
        ref.read(serverErrorProvider.notifier).setHasError(true);
      } else {
        // Clear if it's another client-side error (like 400, 422, etc.) meaning server is reachable
        ref.read(serverErrorProvider.notifier).setHasError(false);
      }

      final hasAuthHeader = e.requestOptions.headers.containsKey('Authorization') &&
          e.requestOptions.headers['Authorization'] != null &&
          (e.requestOptions.headers['Authorization'] as String).isNotEmpty;

      if (e.response?.statusCode == 401 &&
          hasAuthHeader &&
          !e.requestOptions.path.contains('login') &&
          !e.requestOptions.path.contains('logout')) {
        ref.read(authProvider.notifier).logout();
        return handler.reject(
          DioException(
            requestOptions: e.requestOptions,
            type: DioExceptionType.badResponse,
            error: 'Session expired. Please login again.',
          ),
        );
      }
      return handler.next(e);
    },
  ));

  // Request/response logging in debug mode only — never in production.
  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  }

  return dio;
}
