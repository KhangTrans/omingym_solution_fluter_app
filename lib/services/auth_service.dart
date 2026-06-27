import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import '../config/env.dart';
import '../config/api_endpoints.dart';

class AuthService {
  late Dio _dio;
  late PersistCookieJar _cookieJar;

  AuthService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Env.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    _initPersistentSession();
    _initAuthInterceptor();
  }

  /// Cấu hình Interceptor để tự động gắn Bearer Token vào header mỗi request
  void _initAuthInterceptor() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
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
      final response = await _dio.post(ApiEndpoints.login, data: {
        'identifier': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        // Lưu thông tin user và token vào SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final token = response.data['token'];
        if (token != null) {
          await prefs.setString('auth_token', token);
        }
        await prefs.setString('user_data', jsonEncode(response.data['user']));
        await prefs.setBool('is_logged_in', true);
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Đăng nhập bằng Google
  Future<Response> loginWithGoogle(String idToken) async {
    try {
      final response = await _dio.post(ApiEndpoints.googleLogin, data: {
        'idToken': idToken,
      });

      if (response.statusCode == 200) {
        // Lưu thông tin user và token vào SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final token = response.data['token'];
        if (token != null) {
          await prefs.setString('auth_token', token);
        }
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
      return await _dio.post(ApiEndpoints.requestOtp, data: {'identifier': email});
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
    int roleId = 3, // Mặc định 3 là Customer (Khách hàng)
  }) async {
    try {
      final data = {
        "identifier": email,
        "otp": otp,
        "password": password,
        "role_id": roleId,
        "personalInfo": {"full_name": fullName}
      };

      return await _dio.post(ApiEndpoints.register, data: data);
    } catch (e) {
      rethrow;
    }
  }

  /// Đăng xuất
  Future<void> logout() async {
    try {
      await _dio.post(ApiEndpoints.logout);
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

  /// Lấy thông tin user đã lưu
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userStr = prefs.getString('user_data');
    if (userStr != null) {
      return jsonDecode(userStr) as Map<String, dynamic>;
    }
    return null;
  }

  /// Lấy token xác thực đã lưu
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Yêu cầu khôi phục mật khẩu (Gửi OTP)
  Future<Response> forgotPassword(String email) async {
    try {
      return await _dio.post(ApiEndpoints.forgotPassword, data: {'email': email});
    } catch (e) {
      rethrow;
    }
  }

  /// Đặt lại mật khẩu mới bằng OTP
  Future<Response> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final data = {
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      };
      return await _dio.post(ApiEndpoints.resetPassword, data: data);
    } catch (e) {
      rethrow;
    }
  }

  /// Thực hiện check-in cho khách hàng
  Future<Response> customerCheckIn({required int branchId, String? dynamicQrToken}) async {
    try {
      final data = {
        'branch_id': branchId,
        if (dynamicQrToken != null) 'dynamic_qr_token': dynamicQrToken,
      };
      return await _dio.post(ApiEndpoints.checkIn, data: data);
    } catch (e) {
      rethrow;
    }
  }
}
