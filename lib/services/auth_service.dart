import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

class AuthService {
  late Dio _dio;
  late PersistCookieJar _cookieJar;

  AuthService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'http://10.0.2.2:3000',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    _initPersistentSession();
  }

  /// Khởi tạo quản lý Cookie để duy trì Session từ Express
  Future<void> _initPersistentSession() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final String cookiePath = "${appDocDir.path}/.cookies/";
    final dir = Directory(cookiePath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    
    _cookieJar = PersistCookieJar(storage: FileStorage(cookiePath));
    _dio.interceptors.add(CookieManager(_cookieJar));
  }

  /// Đăng nhập
  Future<Response> login(String email, String password) async {
    try {
      final response = await _dio.post('/api/auth/login', data: {
        'identifier': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        // Lưu thông tin user vào SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(response.data['user']));
        await prefs.setBool('is_logged_in', true);
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Gửi yêu cầu mã OTP qua email
  Future<Response> requestOTP(String email) async {
    try {
      return await _dio.post('/api/auth/request-otp', data: {'identifier': email});
    } catch (e) {
      rethrow;
    }
  }

  /// Gửi yêu cầu đăng ký tài khoản
  Future<Response> register({
    required String email,
    required String otp,
    required String password,
    required String fullName,
  }) async {
    try {
      final data = {
        "identifier": email,
        "otp": otp,
        "password": password,
        "personalInfo": {"full_name": fullName}
      };

      return await _dio.post('/api/auth/register', data: data);
    } catch (e) {
      rethrow;
    }
  }

  /// Đăng xuất
  Future<void> logout() async {
    try {
      await _dio.post('/api/auth/logout');
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await _cookieJar.deleteAll();
    }
  }

  /// Kiểm tra trạng thái đăng nhập
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }
}
