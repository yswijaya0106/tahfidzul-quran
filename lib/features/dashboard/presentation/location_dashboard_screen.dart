import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/brand_badge.dart';
import '../../../core/widgets/decorative_header.dart';
import '../../auth/application/auth_controller.dart';
import '../../locations/application/location_providers.dart';
import '../application/dashboard_providers.dart';
import '../domain/location_dashboard.dart';

const double _headerHeight = 210;

class LocationDashboardScreen extends ConsumerWidget {
  const LocationDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationId = ref.watch(selectedLocationIdProvider);
    if (locationId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final dashboard = ref.watch(locationDashboardProvider(locationId));
    final user = ref.watch(authControllerProvider).valueOrNull;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // Transparent, so the DecorativeHeader shows through behind the
        // device's own status bar (CLAUDE.md: "bagian atas transparan").
        title: null,
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.refresh(locationDashboardProvider(locationId).future),
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.white70),
                                  ),
                                  Text(
                                    user?.fullName ?? 'Al-Hisan',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                    overflow: TextOverflow.ellipsis,
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
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -28),
                child: const _QuickJumpBar(),
              ),
            ),
            SliverToBoxAdapter(
              child: AsyncValueView(
                value: dashboard,
                onRetry: () =>
                    ref.invalidate(locationDashboardProvider(locationId)),
                data: (context, data) => _DashboardBody(data: data),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickJumpItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickJumpItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

/// "Quick jump" shortcut row: the fastest path into the actions a
/// teacher/admin repeats most often, surfaced right under the hero header.
class _QuickJumpBar extends StatelessWidget {
  const _QuickJumpBar();

  @override
  Widget build(BuildContext context) {
    final items = [
      _QuickJumpItem(
        icon: Icons.person_add_alt_1_rounded,
        label: 'Tambah\nSiswa',
        onTap: () => context.push('/students/new'),
      ),
      _QuickJumpItem(
        icon: Icons.menu_book_rounded,
        label: 'Setoran\nBaru',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Pilih siswa terlebih dahulu untuk mencatat setoran.',
              ),
            ),
          );
          context.go('/students');
        },
      ),
      _QuickJumpItem(
        icon: Icons.add_a_photo_rounded,
        label: 'Aktivitas\nBaru',
        onTap: () => context.push('/activities/new'),
      ),
      _QuickJumpItem(
        icon: Icons.groups_rounded,
        label: 'Semua\nSiswa',
        onTap: () => context.go('/students'),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items
                .map((item) => _QuickJumpButton(item: item))
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _QuickJumpButton extends StatelessWidget {
  final _QuickJumpItem item;

  const _QuickJumpButton({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  final LocationDashboard data;

  const _DashboardBody({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Range ${data.rangeFrom} — ${data.rangeTo} (${data.timezone})',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            'Updated ${data.lastUpdatedAt}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Active students',
                  value: '${data.activeStudentCount}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Assessments',
                  value: '${data.assessmentCount}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _StatCard(
            label: 'Latest assessment',
            value: data.latestAssessmentDate ?? 'None yet',
          ),
          const SizedBox(height: 24),
          Text(
            'Grade distribution',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...data.distributionByGrade.entries.map(
            (entry) => _BarRow(label: entry.key, value: entry.value),
          ),
          const SizedBox(height: 24),
          Text(
            'Students without a recent assessment',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (data.studentsWithoutRecentAssessment.isEmpty)
            const Text('All active students have a recent assessment.')
          else
            ...data.studentsWithoutRecentAssessment.map(
              (student) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(student.fullName),
                subtitle: Text(student.studentCode),
              ),
            ),
          const SizedBox(height: 24),
          Text(
            'Recent activities',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (data.recentActivities.isEmpty)
            const Text('No activities recorded yet.')
          else
            ...data.recentActivities.map(
              (activity) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(activity.title),
                subtitle: Text(activity.activityDate),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final int value;

  const _BarRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label)),
          Expanded(
            child: LinearProgressIndicator(
              value: value == 0 ? 0 : null,
              minHeight: 8,
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest,
            ),
          ),
          const SizedBox(width: 8),
          Text('$value'),
        ],
      ),
    );
  }
}
