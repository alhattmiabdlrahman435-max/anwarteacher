import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../utils/constants.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../providers/auth_provider.dart';

part 'api_client.g.dart';

@riverpod
Dio apiClient(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Add interceptors for auth tokens, logging, etc.
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
            error: 'No Internet Connection',
          ),
        );
      }

      const storage = FlutterSecureStorage();
      final token = await storage.read(key: AppConstants.tokenKey);
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
    onError: (DioException e, handler) {
      if (e.response?.statusCode == 401 && !e.requestOptions.path.contains('login')) {
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
  dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));

  return dio;
}
