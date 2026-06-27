import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PostsScreen extends StatelessWidget {
  const PostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const emerald500 = Color(0xFF10B981);
    const slate900 = Color(0xFF0F172A);
    const slate600 = Color(0xFF475569);
    const slate100 = Color(0xFFF1F5F9);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bảng tin & Bài viết',
                style: GoogleFonts.inter(fontSize: 24, color: slate900, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Cập nhật kiến thức tập luyện, dinh dưỡng lành mạnh từ chuyên gia.',
                style: GoogleFonts.inter(fontSize: 14, color: slate600),
              ),
              const SizedBox(height: 24),

              // Horizontal Category Tags
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryTag('Tất cả', true),
                    _buildCategoryTag('Dinh dưỡng', false),
                    _buildCategoryTag('Luyện tập', false),
                    _buildCategoryTag('Sức khỏe', false),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Post list
              _buildPostCard(
                category: 'DINH DƯỠNG',
                title: '5 Loại thực phẩm giúp tăng cơ bắp nhanh nhất bạn nên ăn',
                readTime: '5 phút đọc',
                likes: 128,
                imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&auto=format&fit=crop&q=60',
              ),
              const SizedBox(height: 20),
              _buildPostCard(
                category: 'LUYỆN TẬP',
                title: 'Hướng dẫn tập Squat đúng kỹ thuật tránh chấn thương khớp gối',
                readTime: '8 phút đọc',
                likes: 242,
                imageUrl: 'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=500&auto=format&fit=crop&q=60',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTag(String label, bool isActive) {
    const emerald500 = Color(0xFF10B981);
    const slate900 = Color(0xFF0F172A);
    const slate600 = Color(0xFF475569);

    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? slate900 : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: isActive ? Colors.white : slate600,
        ),
      ),
    );
  }

  Widget _buildPostCard({
    required String category,
    required String title,
    required String readTime,
    required int likes,
    required String imageUrl,
  }) {
    const emerald500 = Color(0xFF10B981);
    const slate900 = Color(0xFF0F172A);
    const slate600 = Color(0xFF475569);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post image (Simulated container with color/icon if offline, or network image)
          Container(
            height: 180,
            width: double.infinity,
            color: const Color(0xFFF1F5F9),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Icon(LucideIcons.image, color: const Color(0xFF94A3B8), size: 32),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: emerald500, letterSpacing: 1),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: slate900, height: 1.3),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      readTime,
                      style: GoogleFonts.inter(fontSize: 12, color: slate600),
                    ),
                    Row(
                      children: [
                        Icon(LucideIcons.heart, size: 14, color: Colors.redAccent),
                        const SizedBox(width: 4),
                        Text(
                          '$likes thích',
                          style: GoogleFonts.inter(fontSize: 12, color: slate600, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
