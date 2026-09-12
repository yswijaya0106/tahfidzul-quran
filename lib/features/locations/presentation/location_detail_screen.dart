import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/async_value_view.dart';
import '../application/location_providers.dart';
import '../domain/location.dart';

/// Read-only view of a location's info and organizational structure
/// (Ketua, Sekretaris, Bendahara, ...). Open to any authenticated role —
/// editing the structure remains admin-only via [LocationFormScreen].
class LocationDetailScreen extends ConsumerWidget {
  final String locationId;

  const LocationDetailScreen({super.key, required this.locationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationAsync = ref.watch(locationDetailProvider(locationId));

    return Scaffold(
      appBar: AppBar(title: const Text('Struktur Organisasi')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(locationDetailProvider(locationId).future),
        child: AsyncValueView(
          value: locationAsync,
          onRetry: () => ref.invalidate(locationDetailProvider(locationId)),
          data: (context, location) => _LocationDetailBody(location: location),
        ),
      ),
    );
  }
}

class _LocationDetailBody extends StatelessWidget {
  final TahfidzLocation location;

  const _LocationDetailBody({required this.location});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          location.name,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(location.addressLine),
        if (location.phone != null && location.phone!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.phone_outlined, size: 16, color: AppColors.ink),
              const SizedBox(width: 6),
              Text(location.phone!),
            ],
          ),
        ],
        if (location.description != null && location.description!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(location.description!),
        ],
        const SizedBox(height: 24),
        Row(
          children: [
            const Icon(Icons.groups_rounded, size: 20, color: AppColors.deepGreen),
            const SizedBox(width: 8),
            Text(
              'Struktur Organisasi',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (location.organizationMembers.isEmpty)
          Container(
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
            child: const Text('Belum ada data struktur organisasi.'),
          )
        else
          Container(
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
            child: Column(
              children: [
                for (var i = 0; i < location.organizationMembers.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  _MemberTile(member: location.organizationMembers[i]),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _MemberTile extends StatelessWidget {
  final LocationOrganizationMember member;

  const _MemberTile({required this.member});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.deepGreen.withValues(alpha: 0.1),
        child: const Icon(Icons.person_outline, color: AppColors.deepGreen),
      ),
      title: Text(member.name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        member.phone != null && member.phone!.isNotEmpty
            ? '${member.roleTitle} · ${member.phone}'
            : member.roleTitle,
      ),
    );
  }
}
