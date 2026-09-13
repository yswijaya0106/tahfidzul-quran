import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/section_header.dart';
import '../../locations/application/location_providers.dart';
import '../application/activity_providers.dart';
import '../domain/activity.dart';
import '../domain/activity_photo.dart';

class ActivityDetailScreen extends ConsumerWidget {
  final String activityId;

  const ActivityDetailScreen({super.key, required this.activityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activity = ref.watch(activityDetailProvider(activityId));
    final photos = ref.watch(activityPhotosProvider(activityId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Kegiatan')),
      body: RefreshIndicator(
        onRefresh: () => Future.wait([
          ref.refresh(activityDetailProvider(activityId).future),
          ref.refresh(activityPhotosProvider(activityId).future),
        ]),
        child: AsyncValueView(
          value: activity,
          onRetry: () => ref.invalidate(activityDetailProvider(activityId)),
          data: (context, activityData) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AppCard(
                padding: const EdgeInsets.all(16),
                child: _ActivityHeader(activity: activityData),
              ),
              const SizedBox(height: 24),
              const SectionHeader(
                icon: Icons.photo_library_rounded,
                title: 'Foto Kegiatan',
                color: AppColors.gold,
              ),
              const SizedBox(height: 12),
              AsyncValueView(
                value: photos,
                onRetry: () => ref.invalidate(activityPhotosProvider(activityId)),
                isEmpty: (result) => result.isEmpty,
                empty: (_) => const Text('Belum ada foto untuk kegiatan ini.'),
                data: (context, result) => AppCard(
                  padding: const EdgeInsets.all(12),
                  child: _ActivityPhotoGrid(photos: result),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityHeader extends ConsumerWidget {
  final Activity activity;

  const _ActivityHeader({required this.activity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref
        .watch(locationDetailProvider(activity.locationId))
        .valueOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          activity.title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: AppColors.navy,
            ),
            const SizedBox(width: 6),
            Text(activity.activityDate),
          ],
        ),
        if (location != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.mosque_outlined,
                size: 16,
                color: AppColors.maroon,
              ),
              const SizedBox(width: 6),
              Expanded(child: Text(location.addressLine)),
            ],
          ),
        ],
        if (activity.description != null &&
            activity.description!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(activity.description!),
        ],
      ],
    );
  }
}

/// Grid of an activity's photos, showing the first [_collapsedCount] by
/// default with a "show more" toggle for the rest.
class _ActivityPhotoGrid extends StatefulWidget {
  final List<ActivityPhoto> photos;

  const _ActivityPhotoGrid({required this.photos});

  @override
  State<_ActivityPhotoGrid> createState() => _ActivityPhotoGridState();
}

class _ActivityPhotoGridState extends State<_ActivityPhotoGrid> {
  static const _collapsedCount = 5;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final sorted = [...widget.photos]
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    final visible = _expanded
        ? sorted
        : sorted.take(_collapsedCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visible.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (context, index) => _PhotoThumbnail(
            photo: visible[index],
            onTap: () => _openViewer(context, sorted, index),
          ),
        ),
        if (sorted.length > _collapsedCount)
          TextButton.icon(
            onPressed: () => setState(() => _expanded = !_expanded),
            icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
            label: Text(
              _expanded
                  ? 'Tampilkan lebih sedikit'
                  : 'Tampilkan lebih banyak (${sorted.length - _collapsedCount})',
            ),
          ),
      ],
    );
  }

  void _openViewer(
    BuildContext context,
    List<ActivityPhoto> photos,
    int initialIndex,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            _PhotoViewerScreen(photos: photos, initialIndex: initialIndex),
      ),
    );
  }
}

class _PhotoThumbnail extends StatelessWidget {
  final ActivityPhoto photo;
  final VoidCallback onTap;

  const _PhotoThumbnail({required this.photo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          photo.url,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Icon(Icons.broken_image_outlined),
          ),
        ),
      ),
    );
  }
}

class _PhotoViewerScreen extends StatefulWidget {
  final List<ActivityPhoto> photos;
  final int initialIndex;

  const _PhotoViewerScreen({required this.photos, required this.initialIndex});

  @override
  State<_PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<_PhotoViewerScreen> {
  late final PageController _controller = PageController(
    initialPage: widget.initialIndex,
  );
  late int _currentIndex = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.photos[_currentIndex];
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_currentIndex + 1} / ${widget.photos.length}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.photos.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) => InteractiveViewer(
                child: Center(
                  child: Image.network(
                    widget.photos[index].url,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white54,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (photo.caption != null && photo.caption!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                photo.caption!,
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
