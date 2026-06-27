import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  @override
  Widget build(BuildContext context) {
    const emerald500 = Color(0xFF10B981);
    const slate900 = Color(0xFF0F172A);
    const slate600 = Color(0xFF475569);
    const slate100 = Color(0xFFF1F5F9);

    final String fullName = _userData?['full_name'] ?? 'Khách hội viên';
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
                    // Header: Greeting & Profile Avatar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Xin chào, 👋',
                              style: GoogleFonts.inter(fontSize: 14, color: slate600, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              fullName,
                              style: GoogleFonts.inter(fontSize: 22, color: slate900, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: emerald500.withOpacity(0.1),
                          backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                          child: avatarUrl.isEmpty
                              ? const Icon(LucideIcons.user, color: emerald500, size: 26)
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Active Package Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [slate900, Color(0xFF1E293B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: slate900.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: emerald500.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: emerald500.withOpacity(0.5)),
                                ),
                                child: Text(
                                  'GÓI TẬP HOẠT ĐỘNG',
                                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: emerald500),
                                ),
                              ),
                              Icon(LucideIcons.dumbbell, color: emerald500.withOpacity(0.8), size: 24),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'OmniGym Premium VIP',
                            style: GoogleFonts.inter(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Hạn sử dụng: Còn 45 ngày (hết hạn ngày 15/08/2026)',
                            style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Quick Stats Title
                    Text(
                      'Thống kê hôm nay',
                      style: GoogleFonts.inter(fontSize: 18, color: slate900, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // Stats Grid
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: LucideIcons.flame,
                            iconColor: Colors.orangeAccent,
                            label: 'Lượng Calo',
                            value: '420 kcal',
                            bg: slate100,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            icon: LucideIcons.timer,
                            iconColor: emerald500,
                            label: 'Thời gian',
                            value: '45 phút',
                            bg: slate100,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Workouts Highlights
                    Text(
                      'Gợi ý bài tập',
                      style: GoogleFonts.inter(fontSize: 18, color: slate900, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    _buildWorkoutItem(
                      title: 'Full Body HIIT',
                      level: 'Trung bình',
                      duration: '30 phút',
                      image: 'HIIT',
                      color: Colors.amber,
                    ),
                    const SizedBox(height: 12),
                    _buildWorkoutItem(
                      title: 'Strength Training',
                      level: 'Nâng cao',
                      duration: '45 phút',
                      image: 'Cơ bắp',
                      color: Colors.redAccent,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 18, color: const Color(0xFF0F172A), fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF475569)),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutItem({
    required String title,
    required String level,
    required String duration,
    required String image,
    required Color color,
  }) {
    const slate900 = Color(0xFF0F172A);
    const slate600 = Color(0xFF475569);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(LucideIcons.play, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: slate900),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      level,
                      style: GoogleFonts.inter(fontSize: 12, color: slate600),
                    ),
                    const SizedBox(width: 8),
                    const Text('•', style: TextStyle(color: Colors.grey)),
                    const SizedBox(width: 8),
                    Text(
                      duration,
                      style: GoogleFonts.inter(fontSize: 12, color: slate600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(LucideIcons.chevronRight, color: Color(0xFF94A3B8), size: 18),
        ],
      ),
    );
  }
}
