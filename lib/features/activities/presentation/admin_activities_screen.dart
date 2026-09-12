import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../locations/application/location_providers.dart';
import '../../locations/domain/location.dart';
import '../application/activity_providers.dart';
import '../domain/activity.dart';
import '../domain/activity_photo.dart';

/// "Kegiatan" tab: every Rumah Tahfidz, collapsed by default. Expanding one
/// fetches its activities (and photos, per activity) only at that point, so
/// browsing the list doesn't load every location's photos up front.
class AdminActivitiesScreen extends ConsumerWidget {
  const AdminActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locations = ref.watch(locationListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kegiatan')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(locationListProvider.future),
        child: AsyncValueView(
          value: locations,
          onRetry: () => ref.invalidate(locationListProvider),
          isEmpty: (result) => result.data.isEmpty,
          empty: (_) => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('Belum ada rumah tahfidz yang terdaftar.'),
            ),
          ),
          data: (context, result) => ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            itemCount: result.data.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) =>
                _LocationActivitiesTile(location: result.data[index]),
          ),
        ),
      ),
    );
  }
}

class _LocationActivitiesTile extends StatefulWidget {
  final TahfidzLocation location;

  const _LocationActivitiesTile({required this.location});

  @override
  State<_LocationActivitiesTile> createState() =>
      _LocationActivitiesTileState();
}

class _LocationActivitiesTileState extends State<_LocationActivitiesTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.deepGreen.withValues(alpha: 0.1),
              child: const Icon(
                Icons.mosque_outlined,
                color: AppColors.deepGreen,
              ),
            ),
            title: Text(
              widget.location.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              widget.location.address,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
            onTap: () => setState(() => _expanded = !_expanded),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: _ActivitiesForLocation(locationId: widget.location.id),
            ),
        ],
      ),
    );
  }
}

class _ActivitiesForLocation extends ConsumerWidget {
  final String locationId;

  const _ActivitiesForLocation({required this.locationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(activityListProvider(locationId));

    return AsyncValueView(
      value: activities,
      onRetry: () => ref.invalidate(activityListProvider(locationId)),
      isEmpty: (result) => result.data.isEmpty,
      empty: (_) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text('Belum ada kegiatan di lokasi ini.'),
      ),
      data: (context, result) => Column(
        children: [
          for (final activity in result.data) _ActivityRow(activity: activity),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatefulWidget {
  final Activity activity;

  const _ActivityRow({required this.activity});

  @override
  State<_ActivityRow> createState() => _ActivityRowState();
}

class _ActivityRowState extends State<_ActivityRow> {
  bool _showPhotos = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.activity.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                widget.activity.activityDate,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (widget.activity.description != null &&
                  widget.activity.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(widget.activity.description!),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() => _showPhotos = !_showPhotos),
                  icon: Icon(
                    _showPhotos
                        ? Icons.visibility_off_outlined
                        : Icons.photo_library_outlined,
                    size: 18,
                  ),
                  label: Text(_showPhotos ? 'Sembunyikan Foto' : 'Lihat Foto'),
                ),
              ),
              if (_showPhotos) _ActivityPhotosRow(activityId: widget.activity.id),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityPhotosRow extends ConsumerWidget {
  final String activityId;

  const _ActivityPhotosRow({required this.activityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = ref.watch(activityPhotosProvider(activityId));

    return AsyncValueView(
      value: photos,
      onRetry: () => ref.invalidate(activityPhotosProvider(activityId)),
      isEmpty: (result) => result.isEmpty,
      empty: (_) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text('Belum ada foto untuk kegiatan ini.'),
      ),
      data: (context, result) => SizedBox(
        height: 88,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: result.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) => _PhotoThumbnail(photo: result[index]),
        ),
      ),
    );
  }
}

class _PhotoThumbnail extends StatelessWidget {
  final ActivityPhoto photo;

  const _PhotoThumbnail({required this.photo});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        photo.url,
        width: 88,
        height: 88,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const SizedBox(
            width: 88,
            height: 88,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => Container(
          width: 88,
          height: 88,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Icon(Icons.broken_image_outlined),
        ),
      ),
    );
  }
}
