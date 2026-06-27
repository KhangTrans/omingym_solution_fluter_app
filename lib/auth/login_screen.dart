import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:dio/dio.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../widgets/custom_text_field.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../config/env.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  final Color emerald500 = const Color(0xFF10B981);
  final Color slate900 = const Color(0xFF0F172A);
  final Color slate600 = const Color(0xFF475569);
  final Color slate50 = const Color(0xFFF8FAFC);

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final response = await _authService.login(
        _emailController.text,
        _passwordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chào mừng quay trở lại, ${response.data['user']['full_name']}!'),
            backgroundColor: emerald500,
          ),
        );
        // Chuyển hướng tới HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      String errorMsg = 'Đăng nhập thất bại. Vui lòng kiểm tra lại.';
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          errorMsg = 'Email hoặc mật khẩu không chính xác.';
        } else if (e.response?.statusCode == 404) {
          errorMsg = 'Tài khoản không tồn tại.';
        } else {
          errorMsg = e.response?.data['message'] ?? errorMsg;
        }
      }
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Thông báo'),
            content: Text(errorMsg),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Đóng', style: TextStyle(color: emerald500)),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: Env.googleServerClientId,
        scopes: ['email', 'profile'],
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return; // User cancelled
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Không lấy được ID Token từ Google');
      }

      final response = await _authService.loginWithGoogle(idToken);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chào mừng, ${response.data['user']['full_name']}!'),
            backgroundColor: emerald500,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      String errorMsg = 'Đăng nhập Google thất bại: $e';
      if (e is DioException) {
        if (e.response?.data != null) {
          errorMsg = e.response?.data['message'] ?? e.toString();
        } else {
          errorMsg = 'Lỗi kết nối mạng: ${e.message}';
        }
      }
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Thông báo'),
            content: Text(errorMsg),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Đóng', style: TextStyle(color: emerald500)),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                // Logo or App Name
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: emerald500.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(LucideIcons.dumbbell, size: 48, color: emerald500),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'OMNIGYM',
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: slate900,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                Text(
                  'Đăng nhập',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: slate900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Chào mừng bạn quay trở lại với OmniGym.',
                  style: GoogleFonts.inter(fontSize: 14, color: slate600),
                ),
                const SizedBox(height: 32),

                // Email
                CustomTextField(
                  label: 'Email',
                  hintText: 'email@example.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: LucideIcons.mail,
                  validator: (v) => (v == null || !v.contains('@')) ? 'Email không hợp lệ' : null,
                ),
                const SizedBox(height: 20),

                // Password
                CustomTextField(
                  label: 'Mật khẩu',
                  hintText: '••••••••',
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  prefixIcon: LucideIcons.lock,
                  validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập mật khẩu' : null,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? LucideIcons.eye : LucideIcons.eyeOff,
                      size: 18,
                      color: slate600,
                    ),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                ),

                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _rememberMe,
                            activeColor: emerald500,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            onChanged: (v) => setState(() => _rememberMe = v ?? false),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Ghi nhớ',
                          style: GoogleFonts.inter(fontSize: 14, color: slate600),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                        );
                      },
                      child: Text(
                        'Quên mật khẩu?',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: emerald500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: slate900, // Phong cách mạnh mẽ (Đen/Slate900)
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            'ĐĂNG NHẬP',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Separator "Or"
                Row(
                  children: [
                    const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Hoặc',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: slate600,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                  ],
                ),
                const SizedBox(height: 20),

                // Google Login Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _loginWithGoogle,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: slate900, width: 1.5),
                          ),
                          child: Text(
                            'G',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: slate900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Đăng nhập với Google',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: slate900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Chưa có tài khoản? ',
                      style: GoogleFonts.inter(color: slate600),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: Text(
                        'Đăng ký ngay',
                        style: GoogleFonts.inter(
                          color: emerald500,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
