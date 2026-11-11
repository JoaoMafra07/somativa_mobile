import 'package:flutter/material.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 92});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Logo Feira Otaku',
      image: true,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.3),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFA726), Color(0xFFEF6C00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEF6C00).withValues(alpha: 0.24),
              blurRadius: size * 0.24,
              offset: Offset(0, size * 0.09),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(size * 0.12),
          child: Image.asset(
            'lib/assets/logo.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
