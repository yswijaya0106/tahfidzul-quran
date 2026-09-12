import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/brand_badge.dart';
import '../../../core/widgets/decorative_header.dart';
import '../../auth/application/auth_controller.dart';
import '../../dashboard/application/dashboard_providers.dart';
import '../../dashboard/domain/location_dashboard.dart';
import '../../locations/application/location_providers.dart';

const double _headerHeight = 210;

/// Landing page shown to admins after login, instead of the location
/// picker: cross-location quick actions plus today's per-location
/// submission progress. Location operators never see this screen.
class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    final overview = ref.watch(locationsOverviewProvider);
    final memorizationProgress = ref.watch(memorizationProgressProvider);
    final todayActivityPhotos = ref.watch(todayActivityPhotosProvider);

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
      body: RefreshIndicator(
        onRefresh: () => Future.wait([
          ref.refresh(locationsOverviewProvider.future),
          ref.refresh(memorizationProgressProvider.future),
          ref.refresh(todayActivityPhotosProvider.future),
        ]),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: DecorativeHeader(
                height: _headerHeight,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const BrandBadge(size: 44),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Assalamu'alaikum",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodyMedium
                                        ?.copyWith(color: Colors.white70),
                                  ),
                                  Text(
                                    user?.fullName ?? 'Admin',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.titleMedium
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          'Yayasan Pendidikan Islam',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: AppColors.goldLight),
                        ),
                        Text(
                          'AL-HISAN',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                              ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const _SectionHeader(
                      icon: Icons.grid_view_rounded,
                      title: 'Akses Cepat',
                    ),
                    const SizedBox(height: 12),
                    const _AdminQuickActions(),
                    const SizedBox(height: 28),
                    const _SectionHeader(
                      icon: Icons.today_rounded,
                      title: 'Progress Hari Ini',
                    ),
                    const SizedBox(height: 8),
                    AsyncValueView(
                      value: overview,
                      onRetry: () => ref.invalidate(locationsOverviewProvider),
                      isEmpty: (result) => result.locations.isEmpty,
                      empty: (_) => const _EmptyListMessage(
                        text: 'Belum ada rumah tahfidz yang terdaftar.',
                      ),
                      data: (context, result) => _ShowMoreList(
                        items: result.locations
                            .map<Widget>(
                              (item) => _LocationProgressRow(item: item),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const _SectionHeader(
                      icon: Icons.menu_book_rounded,
                      title: 'Setoran Hafalan Hari Ini',
                    ),
                    const SizedBox(height: 8),
                    AsyncValueView(
                      value: memorizationProgress,
                      onRetry: () => ref.invalidate(memorizationProgressProvider),
                      isEmpty: (result) => result.students.isEmpty,
                      empty: (_) => const _EmptyListMessage(
                        text: 'Belum ada siswa yang setor hafalan baru hari ini.',
                      ),
                      data: (context, result) => _ShowMoreList(
                        items: result.students
                            .map<Widget>(
                              (item) => _MemorizationProgressRow(item: item),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const _SectionHeader(
                      icon: Icons.photo_library_rounded,
                      title: 'Foto Kegiatan Hari Ini',
                    ),
                    const SizedBox(height: 8),
                    AsyncValueView(
                      value: todayActivityPhotos,
                      onRetry: () => ref.invalidate(todayActivityPhotosProvider),
                      isEmpty: (result) => result.photos.isEmpty,
                      empty: (_) => const _EmptyListMessage(
                        text: 'Belum ada foto kegiatan yang diunggah hari ini.',
                      ),
                      data: (context, result) =>
                          _TodayActivityPhotosSection(photos: result.photos),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _AdminQuickActions extends StatelessWidget {
  const _AdminQuickActions();

  @override
  Widget build(BuildContext context) {
    final items = [
      _QuickActionItem(
        icon: Icons.mosque_outlined,
        label: 'Rumah\nTahfidz',
        onTap: () => context.push('/locations?redirect=/dashboard'),
      ),
      _QuickActionItem(
        icon: Icons.manage_accounts_rounded,
        label: 'Kelola\nUsers',
        onTap: () => context.push('/users'),
      ),
      _QuickActionItem(
        icon: Icons.menu_book_rounded,
        label: 'Lihat\nKegiatan',
        onTap: () => context.push('/locations?redirect=/activities'),
      ),
      _QuickActionItem(
        icon: Icons.fact_check_rounded,
        label: 'Setoran\nHarian',
        onTap: () => context.push('/locations?redirect=/dashboard'),
      ),
      _QuickActionItem(
        icon: Icons.groups_2_rounded,
        label: 'Kelola\nAngkatan',
        onTap: () => context.push('/locations?redirect=/angkatan'),
      ),
    ];

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items
              .map((item) => Expanded(child: _QuickActionButton(item: item)))
              .toList(),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final _QuickActionItem item;

  const _QuickActionButton({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.goldLight.withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: AppColors.deepGreen),
            ),
            const SizedBox(height: 6),
            Text(
              item.label,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.deepGreen),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _EmptyListMessage extends StatelessWidget {
  final String text;

  const _EmptyListMessage({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

/// Plain list (no per-item card), showing the first [_collapsedCount] items
/// with a "show more" toggle for the rest.
class _ShowMoreList extends StatefulWidget {
  final List<Widget> items;

  const _ShowMoreList({required this.items});

  @override
  State<_ShowMoreList> createState() => _ShowMoreListState();
}

class _ShowMoreListState extends State<_ShowMoreList> {
  static const _collapsedCount = 5;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final visible = _expanded
        ? widget.items
        : widget.items.take(_collapsedCount).toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < visible.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            visible[i],
          ],
          if (widget.items.length > _collapsedCount)
            TextButton.icon(
              onPressed: () => setState(() => _expanded = !_expanded),
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              label: Text(
                _expanded
                    ? 'Tampilkan lebih sedikit'
                    : 'Tampilkan lebih banyak (${widget.items.length - _collapsedCount})',
              ),
            ),
        ],
      ),
    );
  }
}

class _LocationProgressRow extends ConsumerWidget {
  final LocationOverviewItem item;

  const _LocationProgressRow({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationLine = item.kabKota != null
        ? '${item.locationName} · ${item.kabKota}'
        : item.locationName;

    return InkWell(
      onTap: () {
        ref.read(selectedLocationIdProvider.notifier).state = item.locationId;
        context.go('/dashboard');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    locationLine,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${item.activeStudentCount} siswa aktif',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            _StatusIcon(label: 'Setoran', ok: item.hasSubmittedAssessmentToday),
            const SizedBox(width: 12),
            _StatusIcon(label: 'Kegiatan', ok: item.hasSubmittedActivityToday),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}

class _MemorizationProgressRow extends StatelessWidget {
  final StudentMemorizationProgress item;

  const _MemorizationProgressRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final locationLine = item.kabKota != null
        ? '${item.locationName} · ${item.kabKota}'
        : item.locationName;
    final subtitle = item.dayNumber != null
        ? '$locationLine · Hari ke-${item.dayNumber}'
        : locationLine;

    return InkWell(
      onTap: () => context.push('/students/${item.studentId}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.fullName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            _TargetStatusIcon(status: item.targetStatus),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final String label;
  final bool ok;

  const _StatusIcon({required this.label, required this.ok});

  @override
  Widget build(BuildContext context) {
    final color = ok ? AppColors.deepGreen : AppColors.maroon;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          ok ? Icons.check_circle_rounded : Icons.cancel_rounded,
          color: color,
          size: 18,
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: color),
        ),
      ],
    );
  }
}

/// One admin-visible group of today's activity photos, keyed by location.
class _LocationPhotoGroup {
  final String locationId;
  final String locationLine;
  final List<TodayActivityPhoto> photos;

  const _LocationPhotoGroup({
    required this.locationId,
    required this.locationLine,
    required this.photos,
  });
}

/// Today's activity photos across every location, grouped by location and
/// ordered by upload time (newest first, as returned by the API). Each
/// location group shows 2 photos by default with a "show more" toggle.
class _TodayActivityPhotosSection extends StatelessWidget {
  final List<TodayActivityPhoto> photos;

  const _TodayActivityPhotosSection({required this.photos});

  List<_LocationPhotoGroup> _groupByLocation() {
    final groups = <String, _LocationPhotoGroup>{};
    for (final photo in photos) {
      final existing = groups[photo.locationId];
      if (existing == null) {
        final locationLine = photo.kabKota != null
            ? '${photo.locationName} · ${photo.kabKota}'
            : photo.locationName;
        groups[photo.locationId] = _LocationPhotoGroup(
          locationId: photo.locationId,
          locationLine: locationLine,
          photos: [photo],
        );
      } else {
        existing.photos.add(photo);
      }
    }
    return groups.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groupByLocation();
    return Column(
      children: [
        for (var i = 0; i < groups.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _LocationPhotoGroupCard(group: groups[i]),
        ],
      ],
    );
  }
}

class _LocationPhotoGroupCard extends StatefulWidget {
  final _LocationPhotoGroup group;

  const _LocationPhotoGroupCard({required this.group});

  @override
  State<_LocationPhotoGroupCard> createState() =>
      _LocationPhotoGroupCardState();
}

class _LocationPhotoGroupCardState extends State<_LocationPhotoGroupCard> {
  static const _collapsedCount = 2;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final photos = widget.group.photos;
    final visible = _expanded
        ? photos
        : photos.take(_collapsedCount).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.mosque_outlined,
                size: 16,
                color: AppColors.deepGreen,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.group.locationLine,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: visible
                .map((photo) => _ActivityPhotoTile(photo: photo))
                .toList(),
          ),
          if (photos.length > _collapsedCount)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => setState(() => _expanded = !_expanded),
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                label: Text(
                  _expanded
                      ? 'Tampilkan lebih sedikit'
                      : 'Tampilkan lebih banyak (${photos.length - _collapsedCount})',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ActivityPhotoTile extends StatelessWidget {
  final TodayActivityPhoto photo;

  const _ActivityPhotoTile({required this.photo});

  @override
  Widget build(BuildContext context) {
    const size = 104.0;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => context.push('/activities/${photo.activityId}'),
      child: SizedBox(
        width: size,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                photo.photoUrl,
                width: size,
                height: size,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return SizedBox(
                    width: size,
                    height: size,
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  width: size,
                  height: size,
                  color: AppColors.goldLight.withValues(alpha: 0.35),
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.deepGreen,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              photo.activityTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _TargetStatusIcon extends StatelessWidget {
  final TargetStatus status;

  const _TargetStatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = switch (status) {
      TargetStatus.reached => (
        Icons.check_circle_rounded,
        AppColors.deepGreen,
        'Tercapai',
      ),
      TargetStatus.notReached => (
        Icons.error_rounded,
        AppColors.maroon,
        'Belum',
      ),
      TargetStatus.noTargetData => (
        Icons.help_rounded,
        Theme.of(context).colorScheme.outline,
        'Tanpa target',
      ),
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: color),
        ),
      ],
    );
  }
}
