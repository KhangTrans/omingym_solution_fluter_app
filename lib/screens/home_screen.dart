import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../widgets/notification_helper.dart';

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

  void _showCheckInBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CheckInBottomSheet(userData: _userData),
    );
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
                    const SizedBox(height: 20),

                    // Quick Check-in Card
                    GestureDetector(
                      onTap: () => _showCheckInBottomSheet(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: emerald500.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: emerald500.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: emerald500,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(LucideIcons.qrCode, color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Check-in tại phòng tập',
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: slate900,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Bấm để quét QR hoặc xuất trình thẻ thành viên',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: slate600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(LucideIcons.chevronRight, color: emerald500, size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

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

class _CheckInBottomSheet extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const _CheckInBottomSheet({this.userData});

  @override
  State<_CheckInBottomSheet> createState() => _CheckInBottomSheetState();
}

class _CheckInBottomSheetState extends State<_CheckInBottomSheet> with SingleTickerProviderStateMixin {
  int _activeTab = 0; // 0 = My QR, 1 = Scan Gym QR
  bool _scanSuccess = false;
  late AnimationController _animationController;

  bool _isProcessingScan = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleQrScanned(String qrCodeValue) async {
    if (_isProcessingScan || _scanSuccess) return;
    setState(() {
      _isProcessingScan = true;
    });

    try {
      int branchId = 1;
      String? dynamicToken;

      if (qrCodeValue.contains(':')) {
        final parts = qrCodeValue.split(':');
        branchId = int.tryParse(parts[0]) ?? 1;
        dynamicToken = qrCodeValue;
      } else {
        branchId = int.tryParse(qrCodeValue) ?? 1;
      }

      await AuthService().customerCheckIn(
        branchId: branchId,
        dynamicQrToken: dynamicToken,
      );

      if (mounted) {
        setState(() {
          _scanSuccess = true;
        });
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = 'Check-in thất bại';
        if (e is DioException && e.response?.data != null) {
          errorMsg = e.response?.data['message'] ?? errorMsg;
        } else {
          errorMsg = e.toString();
        }

        NotificationHelper.showErrorSnackBar(context, errorMsg);
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingScan = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const emerald500 = Color(0xFF10B981);
    const slate900 = Color(0xFF0F172A);
    const slate600 = Color(0xFF475569);

    final String fullName = widget.userData?['full_name'] ?? 'Khách hội viên';
    final String email = widget.userData?['email'] ?? 'chưa cập nhật email';

    return Container(
      height: 520,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _activeTab = 0;
                          _scanSuccess = false;
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _activeTab == 0 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _activeTab == 0
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Text(
                          'Mã QR của tôi',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _activeTab == 0 ? slate900 : slate600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _activeTab = 1;
                          _scanSuccess = false;
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _activeTab == 1 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _activeTab == 1
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Text(
                          'Quét mã phòng tập',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _activeTab == 1 ? slate900 : slate600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _activeTab == 0
                ? _buildMyQrTab(fullName, email, emerald500, slate900, slate600)
                : _buildScanTab(emerald500, slate900, slate600),
          ),
        ],
      ),
    );
  }

  Widget _buildMyQrTab(String name, String email, Color primary, Color dark, Color gray) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                CustomPaint(
                  size: const Size(160, 160),
                  painter: MockQrPainter(),
                ),
                const SizedBox(height: 16),
                Text(
                  name.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: dark,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Thành viên Premium - VIP08912',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Hãy xuất trình mã này trước máy quét tại quầy lễ tân để check-in tự động khi vào phòng tập.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: gray,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildScanTab(Color primary, Color dark, Color gray) {
    if (_scanSuccess) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFD1FAE5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.check, color: Color(0xFF059669), size: 48),
              ),
              const SizedBox(height: 24),
              Text(
                'Check-in thành công!',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: dark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hệ thống đã ghi nhận lịch tập của bạn ngày hôm nay. Chúc bạn tập luyện đạt hiệu quả cao!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: gray,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: dark,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(120, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Đóng', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: MobileScanner(
                      onDetect: (capture) {
                        final List<Barcode> barcodes = capture.barcodes;
                        for (final barcode in barcodes) {
                          final String? rawValue = barcode.rawValue;
                          if (rawValue != null) {
                            _handleQrScanned(rawValue);
                            break;
                          }
                        }
                      },
                    ),
                  ),
                ),
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    border: Border.all(color: primary, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    final double verticalOffset = (_animationController.value * 180) - 90;
                    return Positioned(
                      top: 130 + verticalOffset,
                      child: Container(
                        width: 180,
                        height: 2,
                        decoration: BoxDecoration(
                          color: primary,
                          boxShadow: [
                            BoxShadow(
                              color: primary.withOpacity(0.8),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 12,
                  child: TextButton(
                    onPressed: () => _handleQrScanned("1:mock_token"),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black54,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Simulate Scan (Debug)'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Hãy di chuyển camera đến trước mã QR tại phòng tập của OmniGym để check-in.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: gray,
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class MockQrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF0F172A);
    final double cellSize = size.width / 15;

    void drawBlock(double r, double c, double width, double height) {
      canvas.drawRect(
        Rect.fromLTWH(r * cellSize, c * cellSize, width * cellSize, height * cellSize),
        paint,
      );
    }

    void drawAlignmentPattern(double r, double c) {
      drawBlock(r, c, 7, 7);
      final whitePaint = Paint()..color = Colors.white;
      canvas.drawRect(
        Rect.fromLTWH((r + 1) * cellSize, (c + 1) * cellSize, 5 * cellSize, 5 * cellSize),
        whitePaint,
      );
      canvas.drawRect(
        Rect.fromLTWH((r + 2) * cellSize, (c + 2) * cellSize, 3 * cellSize, 3 * cellSize),
        paint,
      );
    }

    drawAlignmentPattern(0, 0);
    drawAlignmentPattern(8, 0);
    drawAlignmentPattern(0, 8);

    for (int y = 0; y < 15; y++) {
      for (int x = 0; x < 15; x++) {
        if ((x < 8 && y < 8) || (x > 7 && y < 8) || (x < 8 && y > 7)) continue;
        if ((x * y + (x + y)) % 3 == 0 || (x + y * 2) % 5 == 0) {
          drawBlock(x.toDouble(), y.toDouble(), 1, 1);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
