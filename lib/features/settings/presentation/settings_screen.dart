import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_settings.dart';
import '../../../core/theme/app_settings_controller.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/brand_badge.dart';
import '../../../core/widgets/decorative_header.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/domain/user.dart';
import '../../locations/application/location_providers.dart';

// Generous height with margin: the badge chip below the name/email was
// clipping by a few pixels on some devices at the default font scale, and
// this header's text also scales with the user's "Ukuran Font" preference
// (see main.dart's app-wide TextScaler), so it needs slack for that too.
const double _headerHeight = 244;

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    final settings = ref.watch(appSettingsProvider).valueOrNull ?? AppSettings.defaults;
    final settingsController = ref.read(appSettingsProvider.notifier);
    final selectedLocationId = ref.watch(selectedLocationIdProvider);
    final isAdmin = user?.role == UserRole.admin;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          DecorativeHeader(
            height: _headerHeight,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 36, 20, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const BrandBadge(size: 56),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName ?? 'Pengguna',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            user?.email ?? user?.phone ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.goldLight.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.goldLight.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              isAdmin ? 'Administrator' : 'Operator Lokasi',
                              style: const TextStyle(
                                color: AppColors.goldLight,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                AppSectionCard(
                  title: 'Tampilan',
                  children: [
                    AppIconTile(
                      icon: Icons.brightness_6_rounded,
                      iconColor: AppColors.gold,
                      title: 'Tema',
                      subtitle: settings.themeMode.label,
                      onTap: () => _showThemePicker(context, settings, settingsController),
                    ),
                    AppIconTile(
                      icon: Icons.format_size_rounded,
                      iconColor: AppColors.gold,
                      title: 'Ukuran Font',
                      subtitle: settings.fontScale.label,
                      onTap: () => _showFontScalePicker(context, settings, settingsController),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                AppSectionCard(
                  title: 'Lokasi',
                  children: [
                    AppIconTile(
                      icon: Icons.swap_horiz_rounded,
                      iconColor: AppColors.navy,
                      title: 'Ganti lokasi',
                      onTap: () {
                        ref.read(selectedLocationIdProvider.notifier).state = null;
                        context.go(isAdmin ? '/admin/home' : '/locations');
                      },
                    ),
                    if (selectedLocationId != null)
                      AppIconTile(
                        icon: Icons.groups_rounded,
                        iconColor: AppColors.navy,
                        title: 'Struktur Organisasi',
                        subtitle: 'Lihat pengurus lokasi ini',
                        onTap: () => context.push('/locations/$selectedLocationId'),
                      ),
                  ],
                ),
                if (isAdmin) ...[
                  const SizedBox(height: 20),
                  AppSectionCard(
                    title: 'Administrasi',
                    children: [
                      AppIconTile(
                        icon: Icons.manage_accounts_rounded,
                        iconColor: AppColors.deepGreen,
                        title: 'Kelola Pengguna',
                        onTap: () => context.push('/users'),
                      ),
                      AppIconTile(
                        icon: Icons.groups_rounded,
                        iconColor: AppColors.deepGreen,
                        title: 'Kelola Angkatan',
                        onTap: () => context.push('/angkatan'),
                      ),
                      AppIconTile(
                        icon: Icons.calendar_month_rounded,
                        iconColor: AppColors.deepGreen,
                        title: 'Kelola Target Harian',
                        subtitle: 'Jadwal target hafalan 300 hari',
                        onTap: () => context.push('/daily-targets'),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                AppSectionCard(
                  title: 'Akun',
                  children: [
                    AppIconTile(
                      icon: Icons.logout_rounded,
                      iconColor: AppColors.maroon,
                      title: 'Keluar dari perangkat ini',
                      onTap: () async {
                        await ref.read(authControllerProvider.notifier).logout();
                        if (context.mounted) context.go('/login');
                      },
                    ),
                    AppIconTile(
                      icon: Icons.phonelink_erase_rounded,
                      iconColor: AppColors.maroon,
                      title: 'Keluar dari semua perangkat',
                      onTap: () async {
                        await ref.read(authControllerProvider.notifier).logoutAllDevices();
                        if (context.mounted) context.go('/login');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showThemePicker(
    BuildContext context,
    AppSettings settings,
    AppSettingsController controller,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _PickerSheet(
        title: 'Tema',
        child: Row(
          children: [
            for (final mode in AppThemeMode.values)
              _ThemeOptionCard(
                mode: mode,
                selected: mode == settings.themeMode,
                onTap: () {
                  controller.setThemeMode(mode);
                  Navigator.of(sheetContext).pop();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showFontScalePicker(
    BuildContext context,
    AppSettings settings,
    AppSettingsController controller,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _PickerSheet(
        title: 'Ukuran Font',
        child: Row(
          children: [
            for (final scale in AppFontScale.values)
              _FontScaleOptionCard(
                scale: scale,
                selected: scale == settings.fontScale,
                onTap: () {
                  controller.setFontScale(scale);
                  Navigator.of(sheetContext).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Picker bottom sheet shell
// ─────────────────────────────────────────────────────────────

class _PickerSheet extends StatelessWidget {
  final String title;
  final Widget child;

  const _PickerSheet({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Theme option card
// ─────────────────────────────────────────────────────────────

class _ThemeOptionCard extends StatelessWidget {
  final AppThemeMode mode;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOptionCard({required this.mode, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (Color swatch, IconData icon) = switch (mode) {
      AppThemeMode.system => (AppColors.gold, Icons.brightness_auto_rounded),
      AppThemeMode.light => (AppColors.goldLight, Icons.light_mode_rounded),
      AppThemeMode.dark => (AppColors.navy, Icons.dark_mode_rounded),
    };

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: selected ? AppColors.deepGreen.withValues(alpha: 0.08) : null,
            border: Border.all(
              color: selected ? AppColors.deepGreen : Colors.grey.shade300,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: swatch, shape: BoxShape.circle),
                child: Icon(
                  icon,
                  color: mode == AppThemeMode.dark ? Colors.white : AppColors.ink,
                  size: 22,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                mode.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? AppColors.deepGreen : AppColors.ink,
                ),
              ),
              if (selected) ...[
                const SizedBox(height: 4),
                const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.deepGreen),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Font scale option card
// ─────────────────────────────────────────────────────────────

class _FontScaleOptionCard extends StatelessWidget {
  final AppFontScale scale;
  final bool selected;
  final VoidCallback onTap;

  const _FontScaleOptionCard({required this.scale, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: selected ? AppColors.deepGreen.withValues(alpha: 0.08) : null,
            border: Border.all(
              color: selected ? AppColors.deepGreen : Colors.grey.shade300,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Aa',
                style: TextStyle(
                  fontSize: 15 * scale.scaleFactor,
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.deepGreen : AppColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                scale.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? AppColors.deepGreen : AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
