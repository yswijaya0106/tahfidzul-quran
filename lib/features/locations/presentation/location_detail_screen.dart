import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/section_header.dart';
import '../application/location_providers.dart';
import '../domain/location.dart';
import 'google_maps_launcher.dart';

const List<Color> _memberColors = [
  AppColors.deepGreen,
  AppColors.gold,
  AppColors.navy,
  AppColors.maroon,
];

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
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      location.name,
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.map_outlined, color: AppColors.navy),
                    tooltip: 'Buka di Google Maps',
                    onPressed: () => openLocationInGoogleMaps(context, location),
                  ),
                ],
              ),
              Text(location.addressLine),
              if (location.phone != null && location.phone!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.phone_outlined,
                      size: 16,
                      color: AppColors.gold,
                    ),
                    const SizedBox(width: 6),
                    Text(location.phone!),
                  ],
                ),
              ],
              if (location.description != null &&
                  location.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(location.description!),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        const SectionHeader(
          icon: Icons.groups_rounded,
          title: 'Struktur Organisasi',
          color: AppColors.deepGreen,
        ),
        const SizedBox(height: 12),
        if (location.organizationMembers.isEmpty)
          const AppCard(child: Text('Belum ada data struktur organisasi.'))
        else
          AppCard(
            padding: EdgeInsets.zero,
            child: Material(
              type: MaterialType.transparency,
              child: Column(
                children: [
                  for (
                    var i = 0;
                    i < location.organizationMembers.length;
                    i++
                  ) ...[
                    if (i > 0) const Divider(height: 1, indent: 68),
                    _MemberTile(
                      member: location.organizationMembers[i],
                      color: _memberColors[i % _memberColors.length],
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _MemberTile extends StatelessWidget {
  final LocationOrganizationMember member;
  final Color color;

  const _MemberTile({required this.member, required this.color});

  @override
  Widget build(BuildContext context) {
    final hasPhone = member.phone != null && member.phone!.isNotEmpty;
    return ListTile(
      minVerticalPadding: 14,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.person_outline, color: color, size: 20),
      ),
      title: Text(
        member.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        hasPhone ? '${member.roleTitle} · ${member.phone}' : member.roleTitle,
      ),
    );
  }
}
