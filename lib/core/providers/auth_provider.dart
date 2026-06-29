import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../utils/constants.dart';

part 'auth_provider.g.dart';

enum UserRole { teacher, assistant }

class AuthState {
  final bool isLoggedIn;
  final UserRole? role;
  final String userName;
  final String? userAvatar;

  const AuthState({
    this.isLoggedIn = false,
    this.role,
    this.userName = '',
    this.userAvatar,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    UserRole? role,
    String? userName,
    String? userAvatar,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      role: role ?? this.role,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
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
    );
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
      if (dbRole == 'preparation_supervisor') {
        mappedRole = UserRole.assistant;
      }
      
      final displayName = userData['name_ar'] ?? userData['name'] ?? '';
      final displayAvatar = userData['photo'] ?? '';
      
      await storage.write(key: 'userRole', value: mappedRole.name);
      await storage.write(key: 'userName', value: displayName);
      await storage.write(key: 'userAvatar', value: displayAvatar);
      
      state = AuthState(
        isLoggedIn: true,
        role: mappedRole,
        userName: displayName,
        userAvatar: displayAvatar,
      );
    } else {
      throw Exception(response.data?['message'] ?? 'اسم المستخدم أو كلمة المرور غير صحيحة');
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
      print('Error uploading profile photo to backend: $e');
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
