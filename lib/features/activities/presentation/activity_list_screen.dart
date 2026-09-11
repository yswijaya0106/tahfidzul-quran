import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/async_value_view.dart';
import '../application/activity_providers.dart';
import '../domain/activity.dart';

class ActivityListScreen extends ConsumerWidget {
  final String locationId;

  const ActivityListScreen({super.key, required this.locationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(activityListProvider(locationId));

    return Scaffold(
      appBar: AppBar(title: const Text('Activities')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/locations/$locationId/activities/new'),
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('New activity'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(activityListProvider(locationId).future),
        child: AsyncValueView(
          value: activities,
          onRetry: () => ref.invalidate(activityListProvider(locationId)),
          isEmpty: (result) => result.data.isEmpty,
          empty: (_) =>
              const Center(child: Text('No activities recorded yet.')),
          data: (context, result) => ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: result.data.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) =>
                _ActivityTile(activity: result.data[index]),
          ),
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final Activity activity;

  const _ActivityTile({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        minVerticalPadding: 16,
        title: Text(activity.title),
        subtitle: Text(
          '${activity.activityDate}${activity.description != null ? '\n${activity.description}' : ''}',
        ),
        isThreeLine: activity.description != null,
      ),
    );
  }
}
