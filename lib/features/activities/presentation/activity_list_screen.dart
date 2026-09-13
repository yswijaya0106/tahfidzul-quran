import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../locations/application/location_providers.dart';
import '../application/activity_providers.dart';
import '../domain/activity.dart';

class ActivityListScreen extends ConsumerWidget {
  const ActivityListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationId = ref.watch(selectedLocationIdProvider);
    if (locationId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final activities = ref.watch(activityListProvider(locationId));

    return Scaffold(
      appBar: AppBar(title: const Text('Kegiatan')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/activities/new'),
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Kegiatan Baru'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(activityListProvider(locationId).future),
        child: AsyncValueView(
          value: activities,
          onRetry: () => ref.invalidate(activityListProvider(locationId)),
          isEmpty: (result) => result.data.isEmpty,
          empty: (_) =>
              const Center(child: Text('Belum ada kegiatan yang tercatat.')),
          data: (context, result) => ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: result.data.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) => _ActivityTile(
              activity: result.data[index],
              iconColor: _rowColors[index % _rowColors.length],
            ),
          ),
        ),
      ),
    );
  }
}

const _rowColors = [
  AppColors.deepGreen,
  AppColors.gold,
  AppColors.navy,
  AppColors.maroon,
];

class _ActivityTile extends StatelessWidget {
  final Activity activity;
  final Color iconColor;

  const _ActivityTile({required this.activity, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: AppIconTile(
        icon: Icons.photo_library_rounded,
        iconColor: iconColor,
        title: activity.title,
        subtitle:
            '${activity.activityDate}${activity.description != null ? '\n${activity.description}' : ''}',
      ),
    );
  }
}
