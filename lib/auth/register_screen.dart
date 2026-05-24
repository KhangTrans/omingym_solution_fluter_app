import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:dio/dio.dart';
import 'login_screen.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/password_strength_bar.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  // Controllers
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();

  // State
  bool _isPasswordVisible = false;
  bool _agreedToTerms = false;
  bool _isLoading = false;
  bool _isOTPSent = false;
  int _start = 120;
  Timer? _timer;
  int _passwordStrength = 0;

  @override
  void dispose() {
    _timer?.cancel();
    _lastNameController.dispose();
    _firstNameController.dispose();
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
      await _authService.requestOTP(_emailController.text);

      setState(() {
        _isOTPSent = true;
        _isLoading = false;
      });
      _startTimer();
      _showSnackBar('Mã xác thực đã được gửi tới email của bạn', const Color(0xFF10B981));
    } catch (e) {
      setState(() => _isLoading = false);
      String errorMsg = 'Không thể gửi OTP. Vui lòng thử lại.';
      if (e is DioException && e.response?.data != null) {
        errorMsg = e.response?.data['message'] ?? errorMsg;
      }
      _showSnackBar('Lỗi: $errorMsg', Colors.redAccent);
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      _showSnackBar('Bạn cần đồng ý với điều khoản dịch vụ', Colors.redAccent);
      return;
    }
    if (!_isOTPSent) {
      _showSnackBar('Vui lòng xác thực email trước', Colors.redAccent);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.register(
        email: _emailController.text,
        otp: _otpController.text,
        password: _passwordController.text,
        fullName: "${_lastNameController.text} ${_firstNameController.text}".trim(),
      );

      setState(() => _isLoading = false);
      _showSnackBar('Đăng ký tài khoản thành công!', const Color(0xFF10B981));
      // Navigate to login or home
    } catch (e) {
      setState(() => _isLoading = false);
      String errorMsg = 'Đăng ký thất bại. Vui lòng kiểm tra lại.';
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
                Text(
                  'Tạo tài khoản',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: slate900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bắt đầu hành trình tập luyện của bạn ngay hôm nay.',
                  style: GoogleFonts.inter(fontSize: 14, color: slate600),
                ),
                const SizedBox(height: 32),

                // Name Row
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Họ',
                        hintText: 'Nguyễn',
                        controller: _lastNameController,
                        validator: (v) => v!.isEmpty ? 'Yêu cầu' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        label: 'Tên',
                        hintText: 'Văn A',
                        controller: _firstNameController,
                        validator: (v) => v!.isEmpty ? 'Yêu cầu' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Email Field with Verify Button
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
                          (_start > 0 && _start < 120) ? '${_start}s' : 'Xác thực',
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
                ],

                // Password Field
                CustomTextField(
                  label: 'Mật khẩu',
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
                const SizedBox(height: 24),

                // Terms Checkbox
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _agreedToTerms,
                        activeColor: emerald500,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tôi đồng ý với các Điều khoản và Chính sách',
                        style: GoogleFonts.inter(fontSize: 13, color: slate600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
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
                            'Tạo tài khoản',
                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 40),
                // Login Link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Đã có tài khoản? ',
                        style: GoogleFonts.inter(color: slate600),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        child: Text(
                          'Đăng nhập ngay',
                          style: GoogleFonts.inter(
                            color: emerald500,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

