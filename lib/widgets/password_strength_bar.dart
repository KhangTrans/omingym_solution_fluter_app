import 'package:flutter/material.dart';

class PasswordStrengthBar extends StatelessWidget {
  final int strength; // 0 to 4

  const PasswordStrengthBar({super.key, required this.strength});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (index) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < 3 ? 4 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: index < strength ? _getColor(strength) : const Color(0xFFE2E8F0), // Slate-200
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Color _getColor(int strength) {
    if (strength <= 1) return Colors.redAccent;
    if (strength == 2) return Colors.orangeAccent;
    if (strength == 3) return Colors.yellow[700]!;
    return const Color(0xFF10B981); // Emerald-500
  }
}
