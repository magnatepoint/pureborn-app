import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/logger.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isAuthenticated = false;
  bool _isAdmin = false;
  Map<String, dynamic>? _user;

  bool get isAuthenticated => _isAuthenticated;
  bool get isAdmin => _isAdmin;
  Map<String, dynamic>? get user => _user;

  Future<void> checkAuthStatus() async {
    try {
      AppLogger.info('AuthProvider: Starting token validity check...');
      final isValid = await _authService.isTokenValid();
      AppLogger.info('AuthProvider: Token validity check result: $isValid');

      if (isValid) {
        AppLogger.info('AuthProvider: Token is valid, fetching user data...');
        _isAuthenticated = true;
        _isAdmin = await _authService.isAdmin();
        _user = await _authService.getCurrentUser();
        AppLogger.info(
          'AuthProvider: User authenticated successfully. isAdmin: $_isAdmin',
        );
      } else {
        AppLogger.info('AuthProvider: Token is invalid, clearing user data');
        _isAuthenticated = false;
        _isAdmin = false;
        _user = null;
      }
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error(
        'AuthProvider: Error checking auth status',
        e,
        stackTrace,
      );
      _isAuthenticated = false;
      _isAdmin = false;
      _user = null;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      AppLogger.info('AuthProvider: Attempting login for email: $email');
      final response = await _authService.login(email, password);
      _user = response['user'];
      _isAuthenticated = true;
      _isAdmin = _user?['role'] == 'admin';
      AppLogger.info('AuthProvider: Login successful. isAdmin: $_isAdmin');
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error('AuthProvider: Login failed', e, stackTrace);
      rethrow;
    }
  }

  Future<void> register(String name, String email, String password) async {
    try {
      AppLogger.info('AuthProvider: Attempting registration for email: $email');
      final response = await _authService.register(name, email, password);
      _user = response['user'];
      _isAuthenticated = true;
      _isAdmin = _user?['role'] == 'admin';
      AppLogger.info(
        'AuthProvider: Registration successful. isAdmin: $_isAdmin',
      );
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error('AuthProvider: Registration failed', e, stackTrace);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      AppLogger.info('AuthProvider: Attempting logout');
      await _authService.logout();
      _isAuthenticated = false;
      _isAdmin = false;
      _user = null;
      AppLogger.info('AuthProvider: Logout successful');
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error('AuthProvider: Logout failed', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateProfile(String name, String email) async {
    await _authService.updateProfile(name, email);
    _user = await _authService.getCurrentUser();
    notifyListeners();
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _authService.changePassword(oldPassword, newPassword);
  }

  Future<void> deleteAccount() async {
    await _authService.deleteAccount();
    _isAuthenticated = false;
    _isAdmin = false;
    _user = null;
    notifyListeners();
  }

  Future<List<String>> getActivityHistory() async {
    return await _authService.getActivityHistory();
  }
}
