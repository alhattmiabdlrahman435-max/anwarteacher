import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../network/api_client.dart';
import '../network/pusher_service.dart';
import '../utils/constants.dart';
import '../services/badge_service.dart';

part 'auth_provider.g.dart';

enum UserRole { teacher, assistant }

class AuthState {
  final bool isLoggedIn;
  final UserRole? role;
  final String userName;
  final String? userAvatar;
  final String? userId;
  final String? userPhone;
  final String? userAddress;
  final String? userJobId;

  const AuthState({
    this.isLoggedIn = false,
    this.role,
    this.userName = '',
    this.userAvatar,
    this.userId,
    this.userPhone,
    this.userAddress,
    this.userJobId,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    UserRole? role,
    String? userName,
    String? userAvatar,
    String? userId,
    String? userPhone,
    String? userAddress,
    String? userJobId,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      role: role ?? this.role,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      userId: userId ?? this.userId,
      userPhone: userPhone ?? this.userPhone,
      userAddress: userAddress ?? this.userAddress,
      userJobId: userJobId ?? this.userJobId,
    );
  }
}

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  // Single static instance to avoid repeated instantiation overhead.
  static const _storage = FlutterSecureStorage();

  @override
  AuthState build() {
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      _syncToken(fcmToken);
    });
    _loadSession();
    return const AuthState();
  }

  Future<void> _syncToken(String fcmToken) async {
    try {
      final isLoggedIn = state.isLoggedIn;
      if (!isLoggedIn) return;

      final dio = ref.read(apiClientProvider);
      await dio.post('user/fcm-token', data: {
        'fcm_token': fcmToken,
      });
      debugPrint('Teacher/Supervisor FCM Token synced to backend successfully via refresh: $fcmToken');
    } catch (e) {
      debugPrint('Error syncing Teacher/Supervisor FCM Token to backend on refresh: $e');
    }
  }

  Future<void> _loadSession() async {
    final isLoggedInStr = await _storage.read(key: 'isLoggedIn');
    final isLoggedIn = isLoggedInStr == 'true';
    final roleStr = await _storage.read(key: 'userRole');
    final userName = await _storage.read(key: 'userName') ?? '';
    final userAvatar = await _storage.read(key: 'userAvatar');
    final userId = await _storage.read(key: 'userId');
    final userPhone = await _storage.read(key: 'userPhone');
    final userAddress = await _storage.read(key: 'userAddress');
    final userJobId = await _storage.read(key: 'userJobId');

    UserRole? role;
    if (roleStr != null) {
      try {
        role = UserRole.values.firstWhere((r) => r.name == roleStr);
      } catch (_) {
        role = UserRole.teacher;
      }
    }

    state = AuthState(
      isLoggedIn: isLoggedIn,
      role: role,
      userName: userName,
      userAvatar: userAvatar,
      userId: userId,
      userPhone: userPhone,
      userAddress: userAddress,
      userJobId: userJobId,
    );

    if (isLoggedIn) {
      Future.microtask(() => syncFcmToken());
    }
  }

  Future<void> syncFcmToken() async {
    if (!state.isLoggedIn) return;
    try {
      final dio = ref.read(apiClientProvider);
      
      // On iOS, we must ensure APNS token is received before getting FCM token
      String? apnsToken;
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        
        // On iOS simulators or debug configurations, the APNS token is always null.
        // We skip the 5-second retry loop in debug/simulator to avoid slowing down.
        if (apnsToken == null && !kReleaseMode) {
          debugPrint('iOS Simulator/Debug detected: APNS token is null (Push Notifications are only supported on physical iOS devices).');
        } else {
          int retries = 0;
          while (apnsToken == null && retries < 5) {
            await Future.delayed(const Duration(seconds: 1));
            apnsToken = await FirebaseMessaging.instance.getAPNSToken();
            retries++;
          }
        }
      }

      // Only attempt to get FCM token if we are not on iOS, or if we are on iOS and APNS token is available
      if (defaultTargetPlatform == TargetPlatform.iOS && apnsToken == null) {
        debugPrint('Skipped FCM token registration: APNS token is not available.');
        return;
      }

      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await dio.post('user/fcm-token', data: {
          'fcm_token': fcmToken,
        });
        debugPrint('Teacher/Supervisor FCM Token synced to backend successfully: $fcmToken');
      }
    } catch (e) {
      debugPrint('Error syncing Teacher/Supervisor FCM Token to backend: $e');
    }
  }

  Future<void> login(String employeeId, String password, UserRole role) async {
    final dio = ref.read(apiClientProvider);
    
    debugPrint('🔵 LOGIN: Attempting login to ${AppConstants.baseUrl}login');
    debugPrint('🔵 LOGIN: username=$employeeId');
    
    try {
      final response = await dio.post('login', data: {
        'username': employeeId,
        'password': password,
      });
      
      debugPrint('🟢 LOGIN: Response received: ${response.statusCode}');
      
      if (response.data != null && response.data['success'] == true) {
        final token = response.data['token'];
        final userData = response.data['user'];
        
        await _storage.write(key: AppConstants.tokenKey, value: token);
        await _storage.write(key: 'isLoggedIn', value: 'true');
        
        final dbRole = userData['role'];
        UserRole mappedRole = UserRole.teacher;
        if (dbRole == 'preparation_supervisor' || dbRole == 'supervisor') {
          mappedRole = UserRole.assistant;
        }
        
        final displayName = userData['name_ar'] ?? userData['name'] ?? '';
        final displayAvatar = userData['photo'] ?? '';
        final idVal = userData['id']?.toString() ?? '';
        final phoneVal = userData['phone'] ?? '';
        final addressVal = userData['address'] ?? '';
        final jobIdVal = userData['job_id'] ?? '';
        
        await _storage.write(key: 'userRole', value: mappedRole.name);
        await _storage.write(key: 'userName', value: displayName);
        await _storage.write(key: 'userAvatar', value: displayAvatar);
        await _storage.write(key: 'userId', value: idVal);
        await _storage.write(key: 'userPhone', value: phoneVal);
        await _storage.write(key: 'userAddress', value: addressVal);
        await _storage.write(key: 'userJobId', value: jobIdVal);
        
        state = AuthState(
          isLoggedIn: true,
          role: mappedRole,
          userName: displayName,
          userAvatar: displayAvatar,
          userId: idVal,
          userPhone: phoneVal,
          userAddress: addressVal,
          userJobId: jobIdVal,
        );

        Future.microtask(() => syncFcmToken());
      } else {
        throw Exception(response.data?['message'] ?? 'الرقم الوظيفي أو رقم الجوال غير صحيح');
      }
    } on DioException catch (e) {
      debugPrint('🔴 LOGIN DioException: type=${e.type}, message=${e.message}, error=${e.error}');
      debugPrint('🔴 LOGIN DioException: response=${e.response?.statusCode} ${e.response?.data}');
      debugPrint('🔴 LOGIN DioException: requestUrl=${e.requestOptions.uri}');
      final serverMessage = e.response?.data?['message'];
      if (serverMessage != null) {
        throw Exception(serverMessage);
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('تعذر الاتصال بالخادم. يرجى التأكد من تشغيل السيرفر ومن صحة عنوان الـ IP.');
      }
      throw Exception('اسم المستخدم أو كلمة المرور غير صحيحة');
    } catch (e) {
      debugPrint('🔴 LOGIN General Exception: ${e.runtimeType}: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    final token = await _storage.read(key: AppConstants.tokenKey);
    if (token != null) {
      try {
        final dio = ref.read(apiClientProvider);
        final fcmToken = await FirebaseMessaging.instance.getToken();
        final Map<String, dynamic> logoutData = {};
        if (fcmToken != null) {
          logoutData['fcm_token'] = fcmToken;
        }
        await dio.post('logout', data: logoutData);
      } catch (_) {}
    }

    // Clear FCM registration token on the device
    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (e) {
      debugPrint('Error deleting FCM token on logout: $e');
    }

    // Clear cached badge count
    try {
      await BadgeService.clearBadge();
    } catch (e) {
      debugPrint('Error clearing badge: $e');
    }
    
    // Disconnect Pusher to prevent unwanted messages and battery drain
    try {
      PusherService().disconnect();
    } catch (e) {
      debugPrint('Error disconnecting Pusher on logout: $e');
    }

    await _storage.delete(key: AppConstants.tokenKey);
    await _storage.delete(key: 'isLoggedIn');
    await _storage.delete(key: 'userRole');
    await _storage.delete(key: 'userName');
    await _storage.delete(key: 'userAvatar');
    await _storage.delete(key: 'userId');
    await _storage.delete(key: 'userPhone');
    await _storage.delete(key: 'userAddress');
    await _storage.delete(key: 'userJobId');

    state = const AuthState();
  }

  /// Updates the user's profile info both locally and in storage.
  /// Use this instead of accessing [state] directly from the UI layer.
  Future<void> updateProfile({
    required String name,
    required String phone,
    required String address,
  }) async {
    await _storage.write(key: 'userName', value: name);
    await _storage.write(key: 'userPhone', value: phone);
    await _storage.write(key: 'userAddress', value: address);
    state = state.copyWith(
      userName: name,
      userPhone: phone,
      userAddress: address,
    );
  }

  Future<void> updateAvatar(String newAvatarPath) async {
    // Save locally first for instant UI response
    await _storage.write(key: 'userAvatar', value: newAvatarPath);
    state = state.copyWith(userAvatar: newAvatarPath);

    try {
      final dio = ref.read(apiClientProvider);
      
      final file = await MultipartFile.fromFile(
        newAvatarPath,
        filename: newAvatarPath.split('/').last,
      );
      
      final formData = FormData.fromMap({
        'photo': file,
      });
      
      final response = await dio.post('user/update-photo', data: formData);
      if (response.data != null && response.data['success'] == true) {
        final serverUrl = response.data['photo_url'];
        await _storage.write(key: 'userAvatar', value: serverUrl);
        state = state.copyWith(userAvatar: serverUrl);
      }
    } catch (e) {
      debugPrint('Error uploading profile photo to backend: $e');
    }
  }

  Future<void> updatePassword(String currentPassword, String newPassword) async {
    final dio = ref.read(apiClientProvider);
    final response = await dio.post('user/update-password', data: {
      'current_password': currentPassword,
      'new_password': newPassword,
    });
    if (response.data == null || response.data['success'] != true) {
      throw Exception(response.data?['message'] ?? 'فشل تغيير كلمة المرور');
    }
  }
}
