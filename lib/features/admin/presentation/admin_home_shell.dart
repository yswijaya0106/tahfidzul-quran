import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';

/// Bottom-navigation shell for the admin's main area: Beranda (the existing
/// admin landing page), Pencarian (search students by name), Profil (the
/// selected student's profile + memorization progress), Kegiatan
/// (per-location activities, expandable on demand), and Angkatan
/// (per-location intake cohorts, expandable on demand).
///
/// Every label is kept to a single word: a two-word label (e.g. the former
/// "Rumah Tahfidz") wraps to two lines while its siblings stay on one,
/// leaving that destination visibly taller and the whole bar looking
/// misaligned.
class AdminHomeShell extends StatelessWidget {
  final StatefulNavigationShell shell;

  const AdminHomeShell({super.key, required this.shell});

  static const _labels = [
    'Beranda',
    'Pencarian',
    'Profil',
    'Kegiatan',
    'Angkatan',
  ];
  static const _icons = [
    Icons.mosque_outlined,
    Icons.search_outlined,
    Icons.person_outline,
    Icons.event_note_outlined,
    Icons.groups_2_outlined,
  ];
  static const _selectedIcons = [
    Icons.mosque_rounded,
    Icons.search_rounded,
    Icons.person_rounded,
    Icons.event_note_rounded,
    Icons.groups_2_rounded,
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
