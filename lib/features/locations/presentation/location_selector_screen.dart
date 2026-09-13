import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/brand_badge.dart';
import '../../../core/widgets/decorative_header.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/domain/user.dart';
import '../application/location_providers.dart';
import '../domain/location.dart';

const List<Color> _locationColors = [
  AppColors.deepGreen,
  AppColors.gold,
  AppColors.navy,
  AppColors.maroon,
];

const double _headerHeight = 168;

class LocationSelectorScreen extends ConsumerWidget {
  /// Shell path to enter once a location is picked. Defaults to the
  /// dashboard tab; admin quick actions pass e.g. '/activities' so picking a
  /// location jumps straight to the view they asked to inspect.
  final String redirectPath;

  const LocationSelectorScreen({super.key, this.redirectPath = '/dashboard'});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locations = ref.watch(locationListProvider);
    final user = ref.watch(authControllerProvider).valueOrNull;
    final isAdmin = user?.role == UserRole.admin;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () async {
                final created = await context.push<bool>('/locations/new');
                if (created == true) ref.invalidate(locationListProvider);
              },
              icon: const Icon(Icons.add_location_alt_outlined),
              label: const Text('Tambah Lokasi'),
            )
          : null,
      body: Column(
        children: [
          DecorativeHeader(
            height: _headerHeight,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    const BrandBadge(size: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pilih Lokasi',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          Text(
                            user?.fullName ??
                                'Yayasan Pendidikan Islam Al-Hisan',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(locationListProvider.future),
              child: AsyncValueView(
                value: locations,
                onRetry: () => ref.invalidate(locationListProvider),
                isEmpty: (result) => result.data.isEmpty,
                empty: (_) => const _EmptyLocations(),
                data: (context, result) => ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                  itemCount: result.data.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) => _LocationTile(
                    location: result.data[index],
                    isAdmin: isAdmin,
                    redirectPath: redirectPath,
                    color: _locationColors[index % _locationColors.length],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationTile extends ConsumerWidget {
  final TahfidzLocation location;
  final bool isAdmin;
  final String redirectPath;
  final Color color;

  const _LocationTile({
    required this.location,
    required this.isAdmin,
    required this.redirectPath,
    required this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInactive = location.status == LocationStatus.inactive;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Material(
        type: MaterialType.transparency,
        child: ListTile(
          contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          minVerticalPadding: 16,
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.mosque_outlined, color: color),
          ),
          title: Text(
            location.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            location.addressLine,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isInactive)
                const Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Chip(
                    label: Text('Nonaktif', style: TextStyle(fontSize: 11)),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.info_outline),
                tooltip: 'Struktur organisasi',
                onPressed: () => context.push('/locations/${location.id}'),
              ),
              if (isAdmin)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit lokasi',
                  onPressed: () async {
                    final changed = await context.push<bool>(
                      '/locations/${location.id}/edit',
                      extra: location,
                    );
                    if (changed == true) ref.invalidate(locationListProvider);
                  },
                ),
              const Icon(Icons.chevron_right),
            ],
          ),
          onTap: () {
            ref.read(selectedLocationIdProvider.notifier).state = location.id;
            context.go(redirectPath);
          },
        ),
      ),
    );
  }
}

class _EmptyLocations extends StatelessWidget {
  const _EmptyLocations();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text('Belum ada lokasi yang ditugaskan ke akun Anda.'),
      ),
    );
  }
}
