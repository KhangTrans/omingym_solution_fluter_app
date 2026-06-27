import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

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
                'Lịch tập luyện',
                style: GoogleFonts.inter(fontSize: 24, color: slate900, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Đặt lịch tập với huấn luyện viên hoặc lớp học nhóm.',
                style: GoogleFonts.inter(fontSize: 14, color: slate600),
              ),
              const SizedBox(height: 24),

              // Calendar Strip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCalendarDay('Hai', '27', false),
                  _buildCalendarDay('Ba', '28', true), // Today active
                  _buildCalendarDay('Tư', '29', false),
                  _buildCalendarDay('Năm', '30', false),
                  _buildCalendarDay('Sáu', '31', false),
                  _buildCalendarDay('Bảy', '01', false),
                  _buildCalendarDay('CN', '02', false),
                ],
              ),
              const SizedBox(height: 28),

              // Upcoming Sessions Title
              Text(
                'Lớp học trong ngày',
                style: GoogleFonts.inter(fontSize: 18, color: slate900, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Class List
              _buildClassItem(
                time: '08:00 - 09:30',
                className: 'Lớp Yoga Vinyasa',
                trainer: 'HLV. Thanh Vân',
                spotsLeft: 5,
                color: Colors.purpleAccent,
              ),
              const SizedBox(height: 16),
              _buildClassItem(
                time: '17:30 - 18:30',
                className: 'Lớp Boxing Cardio',
                trainer: 'HLV. Tuấn Anh',
                spotsLeft: 2,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              _buildClassItem(
                time: '19:00 - 20:00',
                className: 'Lớp CrossFit nâng cao',
                trainer: 'HLV. Quốc Huy',
                spotsLeft: 0, // Fully booked
                color: Colors.orangeAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarDay(String dayName, String dayNum, bool isActive) {
    const emerald500 = Color(0xFF10B981);
    const slate900 = Color(0xFF0F172A);
    const slate600 = Color(0xFF475569);

    return Container(
      width: 44,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? emerald500 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isActive ? emerald500 : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Text(
            dayName,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : slate600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            dayNum,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : slate900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassItem({
    required String time,
    required String className,
    required String trainer,
    required int spotsLeft,
    required Color color,
  }) {
    const emerald500 = Color(0xFF10B981);
    const slate900 = Color(0xFF0F172A);
    const slate600 = Color(0xFF475569);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.clock, size: 14, color: slate600),
                  const SizedBox(width: 6),
                  Text(
                    time,
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: slate600),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: spotsLeft > 0 ? emerald500.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  spotsLeft > 0 ? 'Còn $spotsLeft chỗ' : 'Hết chỗ',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: spotsLeft > 0 ? emerald500 : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            className,
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: slate900),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                trainer,
                style: GoogleFonts.inter(fontSize: 13, color: slate600),
              ),
              ElevatedButton(
                onPressed: spotsLeft > 0 ? () {} : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: slate900,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFE2E8F0),
                  disabledForegroundColor: const Color(0xFF94A3B8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: Text(
                  'Đặt chỗ',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
