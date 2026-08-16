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
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Upload timeout interceptor: extend timeouts for multipart (file upload) requests.
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      final isMultipart = options.data is FormData;
      if (isMultipart) {
        options.receiveTimeout = const Duration(seconds: 120);
        options.sendTimeout    = const Duration(seconds: 120);
      }
      handler.next(options);
    },
  ));

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
      final isConnectionError = e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionError;
      
      final isServerError = e.response != null && e.response!.statusCode != null && e.response!.statusCode! >= 500;
      final isGetRequest  = e.requestOptions.method.toUpperCase() == 'GET';
      
      // Only show full-screen server error overlay for data-fetching GET requests.
      // Form actions (POST/PUT/DELETE) should fail gracefully to let screen-level error handlers display a toast.
      if (isGetRequest && (isConnectionError || isServerError)) {
        ref.read(serverErrorProvider.notifier).setHasError(true);
      } else {
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

extension DioExceptionHelper on DioException {
  String get userFriendlyMessage {
    if (response?.data != null && response!.data is Map && response!.data['message'] != null) {
      return response!.data['message'].toString();
    }
    if (type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.receiveTimeout ||
        type == DioExceptionType.sendTimeout ||
        type == DioExceptionType.connectionError) {
      return 'تعذر الاتصال بالخادم، يرجى التحقق من اتصال الإنترنت والمحاولة مجدداً.';
    }
    return 'حدث خطأ أثناء معالجة الطلب، يرجى المحاولة مرة أخرى.';
  }
}

