import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/brand_badge.dart';
import '../../../core/widgets/decorative_header.dart';
import '../../../core/widgets/section_header.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/domain/user.dart';
import '../../locations/application/location_providers.dart';
import '../application/dashboard_providers.dart';
import '../domain/location_dashboard.dart';
import 'daily_activity_section.dart';
import 'leaderboard_section.dart';

const double _headerHeight = 230;

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
    final location = ref.watch(locationDetailProvider(locationId)).valueOrNull;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // Transparent, so the DecorativeHeader shows through behind the
        // device's own status bar (CLAUDE.md: "bagian atas transparan").
        // Overrides the app-wide solid AppBarTheme deliberately.
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: null,
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded),
            tooltip: 'Ganti lokasi',
            onPressed: () {
              final isAdmin = user?.role == UserRole.admin;
              ref.read(selectedLocationIdProvider.notifier).state = null;
              context.go(isAdmin ? '/admin/home' : '/locations');
            },
          ),
        ],
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
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.white70),
                                  ),
                                  Text(
                                    user?.fullName ?? 'Al-Hisan',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
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
                          location?.name ?? 'Memuat lokasi...',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                              ),
                        ),
                        if (location != null)
                          Text(
                            location.addressLine,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(color: AppColors.goldLight),
                          ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 16),
                child: _QuickJumpBar(),
              ),
            ),
            SliverToBoxAdapter(
              child: AsyncValueView(
                value: dashboard,
                onRetry: () =>
                    ref.invalidate(locationDashboardProvider(locationId)),
                data: (context, data) =>
                    _DashboardBody(data: data, locationId: locationId),
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
  final Color color;
  final VoidCallback onTap;

  const _QuickJumpItem({
    required this.icon,
    required this.label,
    required this.color,
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
        color: AppColors.deepGreen,
        onTap: () => context.push('/students/new'),
      ),
      _QuickJumpItem(
        icon: Icons.menu_book_rounded,
        label: 'Setoran\nBaru',
        color: AppColors.gold,
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
        color: AppColors.maroon,
        onTap: () => context.push('/activities/new'),
      ),
      _QuickJumpItem(
        icon: Icons.groups_rounded,
        label: 'Semua\nSiswa',
        color: AppColors.navy,
        onTap: () => context.go('/students'),
      ),
      _QuickJumpItem(
        icon: Icons.groups_2_rounded,
        label: 'Kelola\nAngkatan',
        color: AppColors.deepGreen,
        onTap: () => context.go('/angkatan'),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
          child: Row(
            children: items
                .map((item) => Expanded(child: _QuickJumpButton(item: item)))
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
                color: item.color.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: item.color),
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

const Map<String, Color> _gradeColors = {
  'MUMTAZ': AppColors.deepGreen,
  'JAYYID_JIDDAN': AppColors.gold,
  'JAYYID': AppColors.goldLight,
  'MAQBUL': AppColors.navy,
  'RASIB': AppColors.maroon,
};

const Map<String, String> _gradeLabels = {
  'MUMTAZ': 'Mumtaz',
  'JAYYID_JIDDAN': 'Jayyid Jiddan',
  'JAYYID': 'Jayyid',
  'MAQBUL': 'Maqbul',
  'RASIB': 'Rasib',
};

class _DashboardBody extends StatelessWidget {
  final LocationDashboard data;
  final String locationId;

  const _DashboardBody({required this.data, required this.locationId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Periode ${data.rangeFrom} — ${data.rangeTo}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.groups_rounded,
                  color: AppColors.deepGreen,
                  label: 'Siswa aktif',
                  value: '${data.activeStudentCount}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.fact_check_rounded,
                  color: AppColors.gold,
                  label: 'Setoran',
                  value: '${data.assessmentCount}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SectionHeader(
            icon: Icons.leaderboard_rounded,
            title: 'Papan Peringkat Hafalan',
            color: AppColors.navy,
          ),
          const SizedBox(height: 12),
          LeaderboardSection(locationId: locationId),
          const SizedBox(height: 24),
          DailyActivitySection(locationId: locationId),
          const SizedBox(height: 24),
          const SectionHeader(
            icon: Icons.pie_chart_rounded,
            title: 'Distribusi Nilai',
            color: AppColors.gold,
          ),
          const SizedBox(height: 12),
          _GradeDistributionCard(distribution: data.distributionByGrade),
          const SizedBox(height: 24),
          const SectionHeader(
            icon: Icons.emoji_events_rounded,
            title: '10 Siswa Teraktif',
            color: AppColors.navy,
          ),
          const SizedBox(height: 12),
          _TopStudentsCard(students: data.topStudents),
          const SizedBox(height: 24),
          const SectionHeader(
            icon: Icons.notification_important_rounded,
            title: 'Belum Ada Setoran Terbaru',
            color: AppColors.maroon,
          ),
          const SizedBox(height: 12),
          _InactiveStudentsCard(students: data.studentsWithoutRecentAssessment),
          const SizedBox(height: 24),
          const SectionHeader(
            icon: Icons.photo_library_rounded,
            title: 'Aktivitas Terbaru',
            color: AppColors.deepGreen,
          ),
          const SizedBox(height: 12),
          _RecentActivitiesCard(activities: data.recentActivities),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final Widget child;

  const _DashboardCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: child,
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _GradeDistributionCard extends StatelessWidget {
  final Map<String, int> distribution;

  const _GradeDistributionCard({required this.distribution});

  @override
  Widget build(BuildContext context) {
    final total = distribution.values.fold(0, (sum, v) => sum + v);
    final maxValue = distribution.values.isEmpty
        ? 0
        : distribution.values.reduce((a, b) => a > b ? a : b);

    return _DashboardCard(
      child: total == 0
          ? const Text('Belum ada data penilaian pada periode ini.')
          : Column(
              children: distribution.entries
                  .map(
                    (entry) => _GradeBar(
                      label: _gradeLabels[entry.key] ?? entry.key,
                      color: _gradeColors[entry.key] ?? AppColors.ink,
                      value: entry.value,
                      maxValue: maxValue == 0 ? 1 : maxValue,
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _GradeBar extends StatelessWidget {
  final String label;
  final Color color;
  final int value;
  final int maxValue;

  const _GradeBar({
    required this.label,
    required this.color,
    required this.value,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = value / maxValue;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LayoutBuilder(
                builder: (context, constraints) => Stack(
                  children: [
                    Container(height: 10, color: color.withValues(alpha: 0.12)),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      height: 10,
                      width: constraints.maxWidth * fraction,
                      color: color,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 24,
            child: Text(
              '$value',
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopStudentsCard extends StatefulWidget {
  final List<TopStudent> students;

  const _TopStudentsCard({required this.students});

  @override
  State<_TopStudentsCard> createState() => _TopStudentsCardState();
}

class _TopStudentsCardState extends State<_TopStudentsCard> {
  bool _expanded = false;

  static const _collapsedCount = 5;

  static const _rankColors = [
    Color(0xFFD4AF37),
    Color(0xFFA8A8A8),
    Color(0xFFB0742A),
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.students.isEmpty) {
      return const _DashboardCard(
        child: Text('Belum ada setoran pada periode ini.'),
      );
    }

    final visible = _expanded
        ? widget.students
        : widget.students.take(_collapsedCount).toList();

    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...visible.asMap().entries.map(
            (entry) =>
                _TopStudentTile(rank: entry.key + 1, student: entry.value),
          ),
          if (widget.students.length > _collapsedCount)
            Center(
              child: TextButton.icon(
                onPressed: () => setState(() => _expanded = !_expanded),
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                label: Text(
                  _expanded
                      ? 'Tampilkan lebih sedikit'
                      : 'Tampilkan lebih banyak',
                ),
              ),
            ),
          const Divider(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.go('/students'),
              child: const Text('Lihat semua siswa →'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopStudentTile extends StatelessWidget {
  final int rank;
  final TopStudent student;

  const _TopStudentTile({required this.rank, required this.student});

  @override
  Widget build(BuildContext context) {
    final medalColor = rank <= 3
        ? _TopStudentsCardState._rankColors[rank - 1]
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: medalColor ?? AppColors.goldLight.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$rank',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: medalColor != null ? Colors.white : AppColors.ink,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.fullName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  student.studentCode,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Chip(
            label: Text('${student.assessmentCount}x'),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

class _InactiveStudentsCard extends StatelessWidget {
  final List<InactiveStudent> students;

  const _InactiveStudentsCard({required this.students});

  @override
  Widget build(BuildContext context) {
    if (students.isEmpty) {
      return const _DashboardCard(
        child: Text('Semua siswa aktif sudah ada setoran terbaru.'),
      );
    }

    return _DashboardCard(
      child: Column(
        children: students
            .map(
              (student) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.maroon,
                ),
                title: Text(student.fullName),
                subtitle: Text(student.studentCode),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _RecentActivitiesCard extends StatelessWidget {
  final List<RecentActivity> activities;

  const _RecentActivitiesCard({required this.activities});

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const _DashboardCard(
        child: Text('Belum ada aktivitas yang dicatat.'),
      );
    }

    return _DashboardCard(
      child: Column(
        children: activities
            .map(
              (activity) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: _ActivityThumbnail(url: activity.thumbnailUrl),
                title: Text(activity.title),
                subtitle: Text(activity.activityDate),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ActivityThumbnail extends StatelessWidget {
  final String? url;

  const _ActivityThumbnail({required this.url});

  @override
  Widget build(BuildContext context) {
    const fallback = Icon(Icons.photo_camera_back_outlined, color: AppColors.gold);
    final thumbnailUrl = url;
    if (thumbnailUrl == null) return fallback;

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(
        thumbnailUrl,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => fallback,
      ),
    );
  }
}
