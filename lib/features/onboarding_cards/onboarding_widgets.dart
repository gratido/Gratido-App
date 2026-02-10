import 'package:flutter/material.dart';

Widget polaroidImage(String asset) {
  return Transform.rotate(
    angle: -0.05,
    child: Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.asset(
          asset,
          width: 180,
          height: 180,
          fit: BoxFit.cover,
        ),
      ),
    ),
  );
}

Widget circleIcon(
  IconData icon,
  Color color,
  double size, {
  bool glow = false,
}) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color:
              glow ? color.withOpacity(0.25) : Colors.black.withOpacity(0.12),
          blurRadius: glow ? 24 : 14,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Icon(icon, size: size * 0.5, color: color),
  );
}
