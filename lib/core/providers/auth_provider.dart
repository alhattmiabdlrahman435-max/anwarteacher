import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
    final name = role == UserRole.teacher ? 'أستاذ أحمد محمد' : 'أ. منى الحربي';
    
    await storage.write(key: 'isLoggedIn', value: 'true');
    await storage.write(key: 'userRole', value: role.name);
    await storage.write(key: 'userName', value: name);
    await storage.write(key: 'userAvatar', value: '');

    state = AuthState(
      isLoggedIn: true,
      role: role,
      userName: name,
      userAvatar: '',
    );
  }

  Future<void> logout() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'isLoggedIn');
    await storage.delete(key: 'userRole');
    await storage.delete(key: 'userName');
    await storage.delete(key: 'userAvatar');

    state = const AuthState();
  }
}
