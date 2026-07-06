import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../network/api_client.dart';
import '../utils/constants.dart';

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
  @override
  AuthState build() {
    _loadSession();
    return const AuthState();
  }

  Future<void> _loadSession() async {
    const storage = FlutterSecureStorage();
    final isLoggedInStr = await storage.read(key: 'isLoggedIn');
    final isLoggedIn = isLoggedInStr == 'true';
    final roleStr = await storage.read(key: 'userRole');
    final userName = await storage.read(key: 'userName') ?? '';
    final userAvatar = await storage.read(key: 'userAvatar');
    final userId = await storage.read(key: 'userId');
    final userPhone = await storage.read(key: 'userPhone');
    final userAddress = await storage.read(key: 'userAddress');
    final userJobId = await storage.read(key: 'userJobId');

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
    try {
      final dio = ref.read(apiClientProvider);
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
    const storage = FlutterSecureStorage();
    final dio = ref.read(apiClientProvider);
    
    final response = await dio.post('login', data: {
      'username': employeeId,
      'password': password,
    });
    
    if (response.data != null && response.data['success'] == true) {
      final token = response.data['token'];
      final userData = response.data['user'];
      
      await storage.write(key: AppConstants.tokenKey, value: token);
      await storage.write(key: 'isLoggedIn', value: 'true');
      
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
      
      await storage.write(key: 'userRole', value: mappedRole.name);
      await storage.write(key: 'userName', value: displayName);
      await storage.write(key: 'userAvatar', value: displayAvatar);
      await storage.write(key: 'userId', value: idVal);
      await storage.write(key: 'userPhone', value: phoneVal);
      await storage.write(key: 'userAddress', value: addressVal);
      await storage.write(key: 'userJobId', value: jobIdVal);
      
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
  }

  Future<void> logout() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: AppConstants.tokenKey);
    if (token != null) {
      try {
        final dio = ref.read(apiClientProvider);
        await dio.post('logout');
      } catch (_) {}
    }
    await storage.delete(key: AppConstants.tokenKey);
    await storage.delete(key: 'isLoggedIn');
    await storage.delete(key: 'userRole');
    await storage.delete(key: 'userName');
    await storage.delete(key: 'userAvatar');
    await storage.delete(key: 'userId');
    await storage.delete(key: 'userPhone');
    await storage.delete(key: 'userAddress');
    await storage.delete(key: 'userJobId');

    state = const AuthState();
  }

  Future<void> updateAvatar(String newAvatarPath) async {
    const storage = FlutterSecureStorage();
    
    // Save locally first for instant UI response
    await storage.write(key: 'userAvatar', value: newAvatarPath);
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
        await storage.write(key: 'userAvatar', value: serverUrl);
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
