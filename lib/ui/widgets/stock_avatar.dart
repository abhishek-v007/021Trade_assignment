import 'package:flutter/material.dart';

class StockAvatar extends StatelessWidget {
  final String symbol;
  final double size;

  const StockAvatar({
    super.key,
    required this.symbol,
    this.size = 44,
  });

  Color _colorForSymbol(String symbol) {
    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFFF59E0B),
      const Color(0xFF10B981),
      const Color(0xFFEF4444),
      const Color(0xFF06B6D4),
      const Color(0xFFF97316),
    ];
    final index = symbol.codeUnits.fold(0, (a, b) => a + b) % colors.length;
    return colors[index];
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorForSymbol(symbol);
    final initials = symbol.length >= 2 ? symbol.substring(0, 2) : symbol;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: color,
            fontSize: size * 0.32,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
