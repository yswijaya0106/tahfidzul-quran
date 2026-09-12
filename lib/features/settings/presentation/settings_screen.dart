import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_settings.dart';
import '../../../core/theme/app_settings_controller.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/domain/user.dart';
import '../../locations/application/location_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    final settings = ref.watch(appSettingsProvider).valueOrNull ?? AppSettings.defaults;
    final settingsController = ref.read(appSettingsProvider.notifier);
    final selectedLocationId = ref.watch(selectedLocationIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          if (user != null)
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(user.fullName),
              subtitle: Text(user.email ?? user.phone ?? ''),
            ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'Tampilan',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: const Text('Tema'),
            subtitle: Text(settings.themeMode.label),
            onTap: () => _showThemePicker(context, settings, settingsController),
          ),
          ListTile(
            leading: const Icon(Icons.format_size_rounded),
            title: const Text('Ukuran Font'),
            subtitle: Text(settings.fontScale.label),
            onTap: () => _showFontScalePicker(context, settings, settingsController),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.swap_horiz_rounded),
            title: const Text('Ganti lokasi'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ref.read(selectedLocationIdProvider.notifier).state = null;
              context.go('/locations');
            },
          ),
          if (selectedLocationId != null)
            ListTile(
              leading: const Icon(Icons.groups_rounded),
              title: const Text('Struktur Organisasi'),
              subtitle: const Text('Lihat pengurus lokasi ini'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/locations/$selectedLocationId'),
            ),
          if (user?.role == UserRole.admin) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.manage_accounts_outlined),
              title: const Text('Kelola Pengguna'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/users'),
            ),
            ListTile(
              leading: const Icon(Icons.groups_outlined),
              title: const Text('Kelola Angkatan'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/angkatan'),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: const Text('Kelola Target Harian'),
              subtitle: const Text('Jadwal target hafalan 300 hari'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/daily-targets'),
            ),
          ],
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Keluar dari perangkat ini'),
            onTap: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout_outlined),
            title: const Text('Keluar dari semua perangkat'),
            onTap: () async {
              await ref
                  .read(authControllerProvider.notifier)
                  .logoutAllDevices();
              if (context.mounted) context.go('/login');
            },
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
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Tema', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
            for (final mode in AppThemeMode.values)
              RadioListTile<AppThemeMode>(
                value: mode,
                groupValue: settings.themeMode,
                title: Text(mode.label),
                onChanged: (value) {
                  if (value != null) controller.setThemeMode(value);
                  Navigator.of(sheetContext).pop();
                },
              ),
            const SizedBox(height: 8),
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
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Ukuran Font',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            for (final scale in AppFontScale.values)
              RadioListTile<AppFontScale>(
                value: scale,
                groupValue: settings.fontScale,
                title: Text(
                  scale.label,
                  style: TextStyle(fontSize: 14 * scale.scaleFactor),
                ),
                onChanged: (value) {
                  if (value != null) controller.setFontScale(value);
                  Navigator.of(sheetContext).pop();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
