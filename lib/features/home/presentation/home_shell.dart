import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';

/// Bottom-navigation shell for the four main tabs (Beranda, Siswa,
/// Aktivitas, Pengaturan) once a location is selected. Wraps
/// [StatefulShellRoute.indexedStack] branches so each tab keeps its own
/// navigation stack and scroll position when switching back to it.
class HomeShell extends StatelessWidget {
  final StatefulNavigationShell shell;

  const HomeShell({super.key, required this.shell});

  static const _labels = ['Beranda', 'Siswa', 'Aktivitas', 'Pengaturan'];
  static const _icons = [
    Icons.home_outlined,
    Icons.groups_outlined,
    Icons.photo_library_outlined,
    Icons.settings_outlined,
  ];
  static const _selectedIcons = [
    Icons.home_rounded,
    Icons.groups_rounded,
    Icons.photo_library_rounded,
    Icons.settings_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (index) =>
            shell.goBranch(index, initialLocation: index == shell.currentIndex),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.goldLight.withValues(alpha: 0.55),
        destinations: List.generate(
          _labels.length,
          (i) => NavigationDestination(
            icon: Icon(_icons[i]),
            selectedIcon: Icon(_selectedIcons[i]),
            label: _labels[i],
          ),
        ),
      ),
    );
  }
}
