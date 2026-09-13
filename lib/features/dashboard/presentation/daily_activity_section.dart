import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/photo_viewer_screen.dart';
import '../../../core/widgets/section_header.dart';
import '../application/dashboard_providers.dart';
import '../domain/location_dashboard.dart';

final _dateFormat = DateFormat('d MMMM yyyy', 'id_ID');
final _apiDateFormat = DateFormat('yyyy-MM-dd');

/// "Setoran Hafalan" and "Foto Kegiatan" for a date the user picks (default
/// today), either school-wide or scoped to one rumah tahfidz. Pass
/// [locationId] to scope it (open to that location's own operator); omit it
/// for the admin-only, school-wide view.
class DailyActivitySection extends ConsumerStatefulWidget {
  final String? locationId;

  const DailyActivitySection({super.key, this.locationId});

  @override
  ConsumerState<DailyActivitySection> createState() => _DailyActivitySectionState();
}

class _DailyActivitySectionState extends ConsumerState<DailyActivitySection> {
  DateTime _selectedDate = DateTime.now();

  bool get _isToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final dateParam = _apiDateFormat.format(_selectedDate);
    final params = (date: dateParam, locationId: widget.locationId);
    final memorizationProgress = ref.watch(memorizationProgressProvider(params));
    final todayActivityPhotos = ref.watch(todayActivityPhotosProvider(params));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DatePickerChip(
          label: _isToday ? 'Hari ini · ${_dateFormat.format(_selectedDate)}' : _dateFormat.format(_selectedDate),
          onTap: _pickDate,
        ),
        const SizedBox(height: 20),
        SectionHeader(
          icon: Icons.menu_book_rounded,
          title: _isToday ? 'Setoran Hafalan Hari Ini' : 'Setoran Hafalan',
          color: AppColors.gold,
        ),
        const SizedBox(height: 8),
        AsyncValueView(
          value: memorizationProgress,
          onRetry: () => ref.invalidate(memorizationProgressProvider(params)),
          isEmpty: (result) => result.students.isEmpty,
          empty: (_) => _EmptyMessage(
            text: _isToday
                ? 'Belum ada siswa yang setor hafalan baru hari ini.'
                : 'Tidak ada setoran hafalan baru pada tanggal ini.',
          ),
          data: (context, result) => _ShowMoreList(
            items: result.students
                .map<Widget>((item) => _MemorizationProgressRow(item: item))
                .toList(),
          ),
        ),
        const SizedBox(height: 28),
        SectionHeader(
          icon: Icons.photo_library_rounded,
          title: _isToday ? 'Foto Kegiatan Hari Ini' : 'Foto Kegiatan',
          color: AppColors.maroon,
        ),
        const SizedBox(height: 8),
        AsyncValueView(
          value: todayActivityPhotos,
          onRetry: () => ref.invalidate(todayActivityPhotosProvider(params)),
          isEmpty: (result) => result.photos.isEmpty,
          empty: (_) => _EmptyMessage(
            text: _isToday
                ? 'Belum ada foto kegiatan yang diunggah hari ini.'
                : 'Tidak ada foto kegiatan pada tanggal ini.',
          ),
          data: (context, result) => _ActivityPhotosSection(photos: result.photos),
        ),
      ],
    );
  }
}

class _DatePickerChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DatePickerChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_month_rounded, size: 16, color: AppColors.deepGreen),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.expand_more_rounded, size: 16, color: Colors.grey),
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

/// Plain rounded card listing the first few items with a "show more" toggle.
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

class _MemorizationProgressRow extends StatelessWidget {
  final StudentMemorizationProgress item;

  const _MemorizationProgressRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final locationLine = item.kabKota != null ? '${item.locationName} · ${item.kabKota}' : item.locationName;
    final subtitle = item.dayNumber != null ? '$locationLine · Hari ke-${item.dayNumber}' : locationLine;

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
                  Text(item.fullName, style: const TextStyle(fontWeight: FontWeight.w700)),
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

class _TargetStatusIcon extends StatelessWidget {
  final TargetStatus status;

  const _TargetStatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = switch (status) {
      TargetStatus.reached => (Icons.check_circle_rounded, AppColors.deepGreen, 'Tercapai'),
      TargetStatus.notReached => (Icons.error_rounded, AppColors.maroon, 'Belum'),
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
        Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color)),
      ],
    );
  }
}

/// One group of activity photos, keyed by location.
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

/// Activity photos, grouped by location (a single group when scoped to one
/// rumah tahfidz) and ordered by upload time (newest first, as returned by
/// the API).
class _ActivityPhotosSection extends StatelessWidget {
  final List<TodayActivityPhoto> photos;

  const _ActivityPhotosSection({required this.photos});

  List<_LocationPhotoGroup> _groupByLocation() {
    final groups = <String, _LocationPhotoGroup>{};
    for (final photo in photos) {
      final existing = groups[photo.locationId];
      if (existing == null) {
        final locationLine =
            photo.kabKota != null ? '${photo.locationName} · ${photo.kabKota}' : photo.locationName;
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
  State<_LocationPhotoGroupCard> createState() => _LocationPhotoGroupCardState();
}

class _LocationPhotoGroupCardState extends State<_LocationPhotoGroupCard> {
  static const _collapsedCount = 2;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final photos = widget.group.photos;
    final visible = _expanded ? photos : photos.take(_collapsedCount).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.mosque_outlined, size: 16, color: AppColors.deepGreen),
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
            children: [
              for (var i = 0; i < visible.length; i++)
                _ActivityPhotoTile(photo: visible[i], allPhotos: visible, index: i),
            ],
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
  final List<TodayActivityPhoto> allPhotos;
  final int index;

  const _ActivityPhotoTile({required this.photo, required this.allPhotos, required this.index});

  @override
  Widget build(BuildContext context) {
    const size = 104.0;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PhotoViewerScreen(
            photoUrls: allPhotos.map((p) => p.photoUrl).toList(),
            captions: allPhotos.map((p) => p.activityTitle).toList(),
            initialIndex: index,
          ),
        ),
      ),
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
                  child: const Icon(Icons.broken_image_outlined, color: AppColors.deepGreen),
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
