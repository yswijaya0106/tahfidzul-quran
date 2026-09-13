import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/async_value_view.dart';
import '../application/dashboard_providers.dart';
import '../domain/location_dashboard.dart';

/// Ranks students by how far their achieved Quran position exceeds (or
/// trails) their daily target, with a toggle between the cumulative ("since
/// program start") and today-only rankings. Pass [locationId] to scope this
/// to one rumah tahfidz (its own operator may view it); omit it for the
/// admin-only, school-wide leaderboard.
class LeaderboardSection extends ConsumerStatefulWidget {
  final String? locationId;

  const LeaderboardSection({super.key, this.locationId});

  @override
  ConsumerState<LeaderboardSection> createState() => _LeaderboardSectionState();
}

class _LeaderboardSectionState extends ConsumerState<LeaderboardSection> {
  LeaderboardScope _scope = LeaderboardScope.aggregate;

  @override
  Widget build(BuildContext context) {
    final params = (scope: _scope, locationId: widget.locationId);
    final leaderboard = ref.watch(leaderboardProvider(params));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ScopeToggle(scope: _scope, onChanged: (scope) => setState(() => _scope = scope)),
        const SizedBox(height: 12),
        AsyncValueView(
          value: leaderboard,
          onRetry: () => ref.invalidate(leaderboardProvider(params)),
          isEmpty: (result) => result.items.isEmpty,
          empty: (_) => const _EmptyMessage(
            text: 'Belum ada data pencapaian untuk ditampilkan.',
          ),
          data: (context, result) => _LeaderboardList(items: result.items),
        ),
      ],
    );
  }
}

/// Rounded two-way pill toggle. Replaces [SegmentedButton], whose segments
/// don't stretch evenly and let long labels wrap onto a second line inside a
/// narrow segment — this always splits the full width 50/50.
class _ScopeToggle extends StatelessWidget {
  final LeaderboardScope scope;
  final ValueChanged<LeaderboardScope> onChanged;

  const _ScopeToggle({required this.scope, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ScopeButton(
              icon: Icons.trending_up_rounded,
              label: 'Sejak Awal',
              selected: scope == LeaderboardScope.aggregate,
              onTap: () => onChanged(LeaderboardScope.aggregate),
            ),
          ),
          Expanded(
            child: _ScopeButton(
              icon: Icons.today_rounded,
              label: 'Hari Ini',
              selected: scope == LeaderboardScope.daily,
              onTap: () => onChanged(LeaderboardScope.daily),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScopeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ScopeButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.gold : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: selected ? Colors.white : Colors.grey.shade600),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Plain rounded card listing the first few items with a "show more" toggle
/// for the rest — mirrors the other dashboard list sections' styling.
class _LeaderboardList extends StatefulWidget {
  final List<LeaderboardItem> items;

  const _LeaderboardList({required this.items});

  @override
  State<_LeaderboardList> createState() => _LeaderboardListState();
}

class _LeaderboardListState extends State<_LeaderboardList> {
  static const _collapsedCount = 5;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final visible = _expanded ? widget.items : widget.items.take(_collapsedCount).toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < visible.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            _LeaderboardRow(item: visible[i]),
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

class _LeaderboardRow extends StatelessWidget {
  final LeaderboardItem item;

  const _LeaderboardRow({required this.item});

  Color get _rankColor => switch (item.rank) {
    1 => AppColors.gold,
    2 => const Color(0xFF9AA0A6),
    3 => const Color(0xFFB0672D),
    _ => AppColors.deepGreen.withValues(alpha: 0.5),
  };

  @override
  Widget build(BuildContext context) {
    final deltaColor = item.isAhead ? AppColors.deepGreen : AppColors.maroon;
    final locationLine = item.kabKota != null
        ? '${item.locationName} · ${item.kabKota}'
        : item.locationName;

    return InkWell(
      onTap: () => context.push('/students/${item.studentId}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: _rankColor, shape: BoxShape.circle),
              child: Text(
                '${item.rank}',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.fullName, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(
                    '$locationLine · Hari ke-${item.dayNumber}',
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.isAhead ? '+${item.deltaVerses} ayat' : '${item.deltaVerses} ayat',
                  style: TextStyle(color: deltaColor, fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const Icon(Icons.chevron_right_rounded, size: 16, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  final String text;

  const _EmptyMessage({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}
