import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/async_value_view.dart';
import '../../auth/application/auth_controller.dart';
import '../application/location_providers.dart';
import '../domain/location.dart';

class LocationSelectorScreen extends ConsumerWidget {
  const LocationSelectorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locations = ref.watch(locationListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(locationListProvider.future),
        child: AsyncValueView(
          value: locations,
          onRetry: () => ref.invalidate(locationListProvider),
          isEmpty: (result) => result.data.isEmpty,
          empty: (_) => const _EmptyLocations(),
          data: (context, result) => ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: result.data.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) =>
                _LocationTile(location: result.data[index]),
          ),
        ),
      ),
    );
  }
}

class _LocationTile extends ConsumerWidget {
  final TahfidzLocation location;

  const _LocationTile({required this.location});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        minVerticalPadding: 16,
        title: Text(location.name),
        subtitle: Text(
          location.address,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          ref.read(selectedLocationIdProvider.notifier).state = location.id;
          context.go('/dashboard');
        },
      ),
    );
  }
}

class _EmptyLocations extends StatelessWidget {
  const _EmptyLocations();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text('No locations are assigned to your account yet.'),
      ),
    );
  }
}
