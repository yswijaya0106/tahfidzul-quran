import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/async_value_view.dart';
import '../application/dashboard_providers.dart';
import '../domain/location_dashboard.dart';

class LocationDashboardScreen extends ConsumerWidget {
  final String locationId;

  const LocationDashboardScreen({super.key, required this.locationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(locationDashboardProvider(locationId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Location dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline),
            tooltip: 'Students',
            onPressed: () => context.push('/locations/$locationId/students'),
          ),
          IconButton(
            icon: const Icon(Icons.photo_library_outlined),
            tooltip: 'Activities',
            onPressed: () => context.push('/locations/$locationId/activities'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.refresh(locationDashboardProvider(locationId).future),
        child: AsyncValueView(
          value: dashboard,
          onRetry: () => ref.invalidate(locationDashboardProvider(locationId)),
          data: (context, data) => _DashboardBody(data: data),
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
    return ListView(
      padding: const EdgeInsets.all(16),
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
