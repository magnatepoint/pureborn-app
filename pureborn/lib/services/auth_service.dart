import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../utils/logger.dart';
import '../config/app_config.dart';

class AuthService {
  final String baseUrl = AppConfig.apiBaseUrl;
  static const String _tokenKey = 'token';
  static const String _userKey = 'user';

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      AppLogger.info('AuthService: Attempting login for email: $email');
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email, 'password': password}),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Connection timeout'),
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, data['token']);
        await prefs.setString(_userKey, json.encode(data['user']));
        AppLogger.info('AuthService: Login successful');
        return data;
      } else {
        final error = json.decode(response.body)['error'] ?? 'Unknown error';
        AppLogger.error(
          'AuthService: Login failed with status ${response.statusCode}: $error',
        );
        throw Exception(error);
      }
    } catch (e, stackTrace) {
      AppLogger.error('AuthService: Login error', e, stackTrace);
      if (e is Exception) rethrow;
      throw Exception('Failed to login: $e');
    }
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      AppLogger.info('AuthService: Attempting registration for email: $email');
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'name': name,
              'email': email,
              'password': password,
            }),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Connection timeout'),
          );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, data['token']);
        await prefs.setString(_userKey, json.encode(data['user']));
        AppLogger.info('AuthService: Registration successful');
        return data;
      } else {
        final error = json.decode(response.body)['error'] ?? 'Unknown error';
        AppLogger.error(
          'AuthService: Registration failed with status ${response.statusCode}: $error',
        );
        throw Exception(error);
      }
    } catch (e, stackTrace) {
      AppLogger.error('AuthService: Registration error', e, stackTrace);
      if (e is Exception) rethrow;
      throw Exception('Failed to register: $e');
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      AppLogger.info('AuthService: Fetching current user');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      if (token == null) {
        AppLogger.warning('AuthService: No token found');
        throw Exception('No token found');
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/auth/me'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Connection timeout'),
          );

      if (response.statusCode == 200) {
        AppLogger.info('AuthService: Successfully fetched user data');
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body)['error'] ?? 'Unknown error';
        AppLogger.error(
          'AuthService: Failed to get user with status ${response.statusCode}: $error',
        );
        throw Exception(error);
      }
    } catch (e, stackTrace) {
      AppLogger.error('AuthService: Error getting user', e, stackTrace);
      if (e is Exception) rethrow;
      throw Exception('Failed to get user: $e');
    }
  }

  Future<bool> isTokenValid() async {
    try {
      AppLogger.info('AuthService: Checking token validity');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      if (token == null) {
        AppLogger.info('AuthService: No token found');
        return false;
      }

      final isValid = !JwtDecoder.isExpired(token);
      AppLogger.info('AuthService: Token is ${isValid ? 'valid' : 'expired'}');
      return isValid;
    } catch (e, stackTrace) {
      AppLogger.error(
        'AuthService: Error checking token validity',
        e,
        stackTrace,
      );
      return false;
    }
  }

  Future<void> logout() async {
    try {
      AppLogger.info('AuthService: Logging out');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      AppLogger.info('AuthService: Logout successful');
    } catch (e, stackTrace) {
      AppLogger.error('AuthService: Error during logout', e, stackTrace);
      rethrow;
    }
  }

  Future<bool> isAdmin() async {
    try {
      AppLogger.info('AuthService: Checking admin status');
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString(_userKey);
      if (userStr == null) {
        AppLogger.warning('AuthService: No user data found');
        return false;
      }
      final user = json.decode(userStr);
      final isAdmin = user['role'] == 'admin';
      AppLogger.info('AuthService: User is ${isAdmin ? 'admin' : 'not admin'}');
      return isAdmin;
    } catch (e, stackTrace) {
      AppLogger.error(
        'AuthService: Error checking admin status',
        e,
        stackTrace,
      );
      return false;
    }
  }

  Future<void> updateProfile(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null) throw Exception('No token found');
    final response = await http.patch(
      Uri.parse('$baseUrl/auth/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'name': name, 'email': email}),
    );
    if (response.statusCode != 200) {
      final error = json.decode(response.body)['error'] ?? 'Unknown error';
      throw Exception(error);
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null) throw Exception('No token found');
    final response = await http.post(
      Uri.parse('$baseUrl/auth/change-password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }),
    );
    if (response.statusCode != 200) {
      final error = json.decode(response.body)['error'] ?? 'Unknown error';
      throw Exception(error);
    }
  }

  Future<void> deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null) throw Exception('No token found');
    final response = await http.delete(
      Uri.parse('$baseUrl/auth/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      final error = json.decode(response.body)['error'] ?? 'Unknown error';
      throw Exception(error);
    }
  }

  Future<List<String>> getActivityHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null) throw Exception('No token found');
    final response = await http.get(
      Uri.parse('$baseUrl/auth/activity'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch activity');
    }
    final data = json.decode(response.body);
    return List<String>.from(data['activities'] ?? []);
  }
}
