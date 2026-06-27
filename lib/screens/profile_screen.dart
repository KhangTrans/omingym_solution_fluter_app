import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/auth_service.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final data = await AuthService.getUserData();
    if (mounted) {
      setState(() {
        _userData = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    // Show loading indicator
    setState(() => _isLoading = true);

    try {
      await AuthService().logout();
      if (mounted) {
        // Show success toast
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng xuất thành công!', style: GoogleFonts.inter()),
            backgroundColor: const Color(0xFF0F172A),
          ),
        );
        // Navigate back to LoginScreen and clear stack
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng xuất thất bại: $e', style: GoogleFonts.inter()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const emerald500 = Color(0xFF10B981);
    const slate900 = Color(0xFF0F172A);
    const slate600 = Color(0xFF475569);
    const slate50 = Color(0xFFF8FAFC);

    final String fullName = _userData?['full_name'] ?? 'Khách hội viên';
    final String email = _userData?['email'] ?? 'chưa cập nhật email';
    final String role = _userData?['role'] ?? 'Customer';
    final String avatarUrl = _userData?['avatar_url'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: emerald500))
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tài khoản của tôi',
                      style: GoogleFonts.inter(fontSize: 24, color: slate900, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),

                    // User Profile Card
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: emerald500.withOpacity(0.1),
                          backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                          child: avatarUrl.isEmpty
                              ? const Icon(LucideIcons.user, color: emerald500, size: 36)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fullName,
                                style: GoogleFonts.inter(fontSize: 18, color: slate900, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                email,
                                style: GoogleFonts.inter(fontSize: 13, color: slate600),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: emerald500.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  role == 'Customer' ? 'Hội viên' : role,
                                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: emerald500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Settings Group Title
                    Text(
                      'Cài đặt ứng dụng',
                      style: GoogleFonts.inter(fontSize: 14, color: slate600, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 12),

                    // Settings list items
                    _buildSettingItem(icon: LucideIcons.userCheck, label: 'Thông tin cá nhân'),
                    _buildSettingItem(icon: LucideIcons.creditCard, label: 'Lịch sử giao dịch'),
                    _buildSettingItem(icon: LucideIcons.shieldAlert, label: 'Bảo mật & Đổi mật khẩu'),
                    _buildSettingItem(icon: LucideIcons.bellRing, label: 'Thông báo'),
                    _buildSettingItem(icon: LucideIcons.helpCircle, label: 'Trung tâm trợ giúp'),

                    const SizedBox(height: 36),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _logout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFEE2E2), // Light red background
                          foregroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.logOut, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              'ĐĂNG XUẤT',
                              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSettingItem({required IconData icon, required String label}) {
    const slate900 = Color(0xFF0F172A);
    const slate600 = Color(0xFF475569);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: slate600),
      ),
      title: Text(
        label,
        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: slate900),
      ),
      trailing: const Icon(LucideIcons.chevronRight, size: 16, color: Color(0xFF94A3B8)),
      onTap: () {},
    );
  }
}
