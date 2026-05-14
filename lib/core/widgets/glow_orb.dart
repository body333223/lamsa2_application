// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

/// Shared decorative glow orb used across screens for background aesthetics.
class GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const GlowOrb({
    super.key,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 100,
            spreadRadius: 50,
          ),
        ],
      ),
    );
  }
}
