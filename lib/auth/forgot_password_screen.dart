import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:dio/dio.dart';
import 'login_screen.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/password_strength_bar.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  // Controllers
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();

  // State
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isOTPSent = false;
  int _start = 120;
  Timer? _timer;
  int _passwordStrength = 0;

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _start = 120;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  void _checkPasswordStrength(String value) {
    int strength = 0;
    if (value.length >= 8) strength++;
    if (value.contains(RegExp(r'[A-Z]'))) strength++;
    if (value.contains(RegExp(r'[0-9]'))) strength++;
    if (value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    setState(() {
      _passwordStrength = strength;
    });
  }

  Future<void> _requestOTP() async {
    if (_emailController.text.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text)) {
      _showSnackBar('Vui lòng nhập email hợp lệ', Colors.redAccent);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.forgotPassword(_emailController.text);

      setState(() {
        _isOTPSent = true;
        _isLoading = false;
      });
      _startTimer();
      _showSnackBar('Mã khôi phục đã được gửi tới email của bạn', const Color(0xFF10B981));
    } catch (e) {
      setState(() => _isLoading = false);
      String errorMsg = 'Không thể gửi yêu cầu. Vui lòng kiểm tra lại.';
      if (e is DioException && e.response?.data != null) {
        errorMsg = e.response?.data['message'] ?? errorMsg;
      }
      _showSnackBar('Lỗi: $errorMsg', Colors.redAccent);
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isOTPSent) {
      _showSnackBar('Vui lòng gửi yêu cầu OTP trước', Colors.redAccent);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.resetPassword(
        email: _emailController.text,
        otp: _otpController.text,
        newPassword: _passwordController.text,
      );

      setState(() => _isLoading = false);
      _showSnackBar('Khôi phục mật khẩu thành công!', const Color(0xFF10B981));

      // Redirect to login screen after 1.5 seconds
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          }
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      String errorMsg = 'Đặt lại mật khẩu thất bại. Vui lòng kiểm tra lại.';
      if (e is DioException && e.response?.data != null) {
        errorMsg = e.response?.data['message'] ?? errorMsg;
      }
      _showSnackBar('Lỗi: $errorMsg', Colors.redAccent);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter()),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const emerald500 = Color(0xFF10B981);
    const slate900 = Color(0xFF0F172A);
    const slate600 = Color(0xFF475569);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: slate900),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  'Quên mật khẩu',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: slate900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nhập email đã đăng ký để thiết lập lại mật khẩu mới.',
                  style: GoogleFonts.inter(fontSize: 14, color: slate600),
                ),
                const SizedBox(height: 32),

                // Email Field with Send/Resend Button
                Stack(
                  children: [
                    CustomTextField(
                      label: 'Địa chỉ Email',
                      hintText: 'email@example.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: LucideIcons.mail,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Email không được để trống';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Email không hợp lệ';
                        return null;
                      },
                    ),
                    Positioned(
                      right: 4,
                      top: 30, // Adjust based on label height
                      child: TextButton(
                        onPressed: (_start > 0 && _start < 120) ? null : _requestOTP,
                        child: Text(
                          (_start > 0 && _start < 120) ? '${_start}s' : (_isOTPSent ? 'Gửi lại' : 'Gửi mã'),
                          style: GoogleFonts.inter(
                            color: (_start > 0 && _start < 120) ? Colors.grey : emerald500,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // OTP Field - Conditional
                if (_isOTPSent) ...[
                  CustomTextField(
                    label: 'Mã xác thực (OTP)',
                    hintText: '123456',
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    prefixIcon: LucideIcons.shieldCheck,
                    validator: (v) => v!.length != 6 ? 'Nhập mã 6 chữ số' : null,
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  CustomTextField(
                    label: 'Mật khẩu mới',
                    hintText: '••••••••',
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    prefixIcon: LucideIcons.lock,
                    onChanged: _checkPasswordStrength,
                    validator: (v) => v!.length < 8 ? 'Tối thiểu 8 ký tự' : null,
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
                  
                  // Strength Indicator
                  PasswordStrengthBar(strength: _passwordStrength),
                  const SizedBox(height: 32),

                  // Reset Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: emerald500,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              'Đặt lại mật khẩu',
                              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
