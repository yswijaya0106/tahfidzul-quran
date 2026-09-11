import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Circular logo badge. Renders `assets/images/logo_7.png` when present in
/// the bundle; falls back to a book glyph on the brand gradient otherwise so
/// the UI never breaks while the real asset is being added.
class BrandBadge extends StatelessWidget {
  final double size;

  const BrandBadge({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(color: Colors.white),
        child: Image.asset(
          'assets/images/logo_7.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.gold, AppColors.goldLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(
              Icons.menu_book_rounded,
              color: AppColors.deepGreenDark,
              size: size * 0.55,
            ),
          ),
        ),
      ),
    );
  }
}
