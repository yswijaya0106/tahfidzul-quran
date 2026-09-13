import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/brand_badge.dart';
import '../../../core/widgets/decorative_header.dart';
import '../../../core/widgets/section_header.dart';
import '../../auth/application/auth_controller.dart';
import '../../dashboard/application/dashboard_providers.dart';
import '../../dashboard/domain/location_dashboard.dart';
import '../../dashboard/presentation/daily_activity_section.dart';
import '../../dashboard/presentation/leaderboard_section.dart';
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
        onRefresh: () => ref.refresh(locationsOverviewProvider.future),
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
                    const SectionHeader(
                      icon: Icons.grid_view_rounded,
                      title: 'Akses Cepat',
                      color: AppColors.deepGreen,
                    ),
                    const SizedBox(height: 12),
                    const _AdminQuickActions(),
                    const SizedBox(height: 28),
                    const SectionHeader(
                      icon: Icons.leaderboard_rounded,
                      title: 'Papan Peringkat Hafalan',
                      color: AppColors.gold,
                    ),
                    const SizedBox(height: 12),
                    const LeaderboardSection(),
                    const SizedBox(height: 28),
                    const SectionHeader(
                      icon: Icons.today_rounded,
                      title: 'Progress Hari Ini',
                      color: AppColors.navy,
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
                    const DailyActivitySection(),
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
  final Color color;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.color,
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
        color: AppColors.navy,
        onTap: () => context.push('/locations?redirect=/dashboard'),
      ),
      _QuickActionItem(
        icon: Icons.manage_accounts_rounded,
        label: 'Kelola\nUsers',
        color: AppColors.maroon,
        onTap: () => context.push('/users'),
      ),
      _QuickActionItem(
        icon: Icons.menu_book_rounded,
        label: 'Lihat\nKegiatan',
        color: AppColors.gold,
        onTap: () => context.push('/locations?redirect=/activities'),
      ),
      _QuickActionItem(
        icon: Icons.fact_check_rounded,
        label: 'Setoran\nHarian',
        color: AppColors.deepGreen,
        onTap: () => context.push('/locations?redirect=/dashboard'),
      ),
      _QuickActionItem(
        icon: Icons.groups_2_rounded,
        label: 'Kelola\nAngkatan',
        color: AppColors.navy,
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
                color: item.color.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: item.color),
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

/// Ranks students school-wide by how far their achieved Quran position
/// exceeds (or trails) their daily target, with a toggle between the
/// cumulative ("since program start") and today-only rankings.
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
        // push, not go: go() replaces the whole navigation stack, leaving
        // no page to pop back to — the hardware back button would close
        // the app instead of returning here to the admin dashboard.
        context.push('/dashboard');
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

