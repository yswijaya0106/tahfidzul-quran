import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/section_header.dart';
import '../../ref_data/application/ref_data_providers.dart';
import '../application/location_providers.dart';
import '../domain/location.dart';
import 'address_search_field.dart';
import 'location_cover_photo_field.dart';

/// Create/edit form for a Tahfidz location. Pass [location] to edit an
/// existing one (also enables the archive action); omit it to create new.
class LocationFormScreen extends ConsumerStatefulWidget {
  final TahfidzLocation? location;

  const LocationFormScreen({super.key, this.location});

  @override
  ConsumerState<LocationFormScreen> createState() => _LocationFormScreenState();
}

class _LocationFormScreenState extends ConsumerState<LocationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(
    text: widget.location?.name,
  );
  late final _addressController = TextEditingController(
    text: widget.location?.address,
  );
  late final _phoneController = TextEditingController(
    text: widget.location?.phone,
  );
  late final _descriptionController = TextEditingController(
    text: widget.location?.description,
  );
  late final _latitudeController = TextEditingController(
    text: widget.location?.latitude?.toString(),
  );
  late final _longitudeController = TextEditingController(
    text: widget.location?.longitude?.toString(),
  );
  late final _kecamatanController = TextEditingController(
    text: widget.location?.kecamatan,
  );
  late final _kodePosController = TextEditingController(
    text: widget.location?.kodePos,
  );

  int? _provinceId;
  int? _cityId;
  String? _coverPhotoObjectKey;
  String? _coverPhotoUrl;

  final List<_MemberEntry> _members = [];
  bool _membersLoaded = false;

  bool _submitting = false;
  Map<String, String>? _serverFieldErrors;

  @override
  void initState() {
    super.initState();
    _provinceId = widget.location?.provinceId;
    _cityId = widget.location?.cityId;
    _coverPhotoObjectKey = widget.location?.coverPhotoObjectKey;
    _coverPhotoUrl = widget.location?.coverPhotoUrl;
  }

  bool get _isEditing => widget.location != null;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _kecamatanController.dispose();
    _kodePosController.dispose();
    for (final member in _members) {
      member.dispose();
    }
    super.dispose();
  }

  void _seedMembersOnce(List<LocationOrganizationMember> members) {
    if (_membersLoaded) return;
    _membersLoaded = true;
    setState(() {
      _members.addAll(members.map(_MemberEntry.fromExisting));
    });
  }

  void _addMember() {
    setState(() => _members.add(_MemberEntry.empty()));
  }

  void _removeMember(int index) {
    setState(() => _members.removeAt(index).dispose());
  }

  Future<void> _submit() async {
    setState(() => _serverFieldErrors = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);
    try {
      final repository = ref.read(locationRepositoryProvider);
      final latitude = _latitudeController.text.trim().isEmpty
          ? null
          : double.tryParse(_latitudeController.text.trim());
      final longitude = _longitudeController.text.trim().isEmpty
          ? null
          : double.tryParse(_longitudeController.text.trim());
      final organizationMembers = _members
          .where((m) => m.nameController.text.trim().isNotEmpty)
          .map((m) => m.toDomain())
          .toList();

      if (_isEditing) {
        await repository.update(
          widget.location!.id,
          name: _nameController.text.trim(),
          address: _addressController.text.trim(),
          kecamatan: _kecamatanController.text.trim(),
          kodePos: _kodePosController.text.trim(),
          provinceId: _provinceId,
          cityId: _cityId,
          latitude: latitude,
          longitude: longitude,
          phone: _phoneController.text.trim(),
          description: _descriptionController.text.trim(),
          coverPhotoObjectKey: _coverPhotoObjectKey,
          organizationMembers: organizationMembers,
        );
        ref.invalidate(locationDetailProvider(widget.location!.id));
      } else {
        await repository.create(
          name: _nameController.text.trim(),
          address: _addressController.text.trim(),
          kecamatan: _kecamatanController.text.trim(),
          kodePos: _kodePosController.text.trim(),
          provinceId: _provinceId,
          cityId: _cityId,
          latitude: latitude,
          longitude: longitude,
          phone: _phoneController.text.trim(),
          description: _descriptionController.text.trim(),
          coverPhotoObjectKey: _coverPhotoObjectKey,
          organizationMembers: organizationMembers,
        );
      }

      ref.invalidate(locationListProvider);
      if (mounted) context.pop(true);
    } on AppException catch (error) {
      setState(() => _serverFieldErrors = error.fields);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _archive() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Arsipkan lokasi?'),
        content: Text(
          'Lokasi "${widget.location!.name}" akan dinonaktifkan. Tetap bisa dilihat, tapi '
          'tidak bisa lagi dipakai untuk siswa atau kegiatan baru.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => context.pop(true),
            child: const Text('Arsipkan'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _submitting = true);
    try {
      await ref.read(locationRepositoryProvider).archive(widget.location!.id);
      ref.invalidate(locationListProvider);
      if (mounted) context.pop(true);
    } on AppException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing) {
      ref.listen<AsyncValue<TahfidzLocation>>(
        locationDetailProvider(widget.location!.id),
        (previous, next) {
          final loaded = next.valueOrNull;
          if (loaded != null) _seedMembersOnce(loaded.organizationMembers);
        },
      );
      // Trigger the fetch (ref.listen alone doesn't).
      ref.watch(locationDetailProvider(widget.location!.id));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Lokasi' : 'Tambah Lokasi'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.archive_outlined),
              tooltip: 'Arsipkan',
              onPressed: _submitting ? null : _archive,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LocationCoverPhotoField(
                photoUrl: _coverPhotoUrl,
                onUploaded: (uploaded) => setState(() {
                  _coverPhotoObjectKey = uploaded.objectKey;
                  _coverPhotoUrl = null; // show the fresh local preview, not the stale signed URL
                }),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama lokasi',
                  errorText: _serverFieldErrors?['name'],
                  prefixIcon: const Icon(
                    Icons.mosque_outlined,
                    color: AppColors.deepGreen,
                  ),
                ),
                validator: (value) => (value == null || value.trim().length < 2)
                    ? 'Minimal 2 karakter'
                    : null,
              ),
              const SizedBox(height: 16),
              AddressSearchField(
                onSelected: (result) => setState(() {
                  _addressController.text = result.displayName;
                  _latitudeController.text = result.latitude.toString();
                  _longitudeController.text = result.longitude.toString();
                  if (result.kecamatan != null) {
                    _kecamatanController.text = result.kecamatan!;
                  }
                  if (result.kodePos != null) {
                    _kodePosController.text = result.kodePos!;
                  }
                }),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Alamat',
                  errorText: _serverFieldErrors?['address'],
                  prefixIcon: const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.gold,
                  ),
                ),
                maxLines: 2,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),
              _ProvinceCityFields(
                initialProvinceId: _provinceId,
                initialCityId: _cityId,
                onChanged: (provinceId, cityId) => setState(() {
                  _provinceId = provinceId;
                  _cityId = cityId;
                }),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _kecamatanController,
                      decoration: const InputDecoration(labelText: 'Kecamatan (opsional)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _kodePosController,
                      decoration: const InputDecoration(labelText: 'Kode pos (opsional)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telepon (opsional)',
                  prefixIcon: Icon(Icons.phone_outlined, color: AppColors.navy),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitudeController,
                      decoration: const InputDecoration(
                        labelText: 'Latitude (opsional)',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: true,
                        decimal: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _longitudeController,
                      decoration: const InputDecoration(
                        labelText: 'Longitude (opsional)',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: true,
                        decimal: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi (opsional)',
                  prefixIcon: Icon(
                    Icons.notes_rounded,
                    color: AppColors.maroon,
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(
                    child: SectionHeader(
                      icon: Icons.groups_rounded,
                      title: 'Struktur Organisasi',
                      color: AppColors.deepGreen,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _addMember,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Tambah'),
                  ),
                ],
              ),
              if (_isEditing && !_membersLoaded)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else if (_members.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Belum ada anggota. Tap "Tambah" untuk menambahkan.',
                  ),
                )
              else
                for (var i = 0; i < _members.length; i++)
                  _MemberFormRow(
                    entry: _members[i],
                    onRemove: () => _removeMember(i),
                  ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _submitting ? null : _submit,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditing ? 'Simpan perubahan' : 'Simpan lokasi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One editable organization-member row's controllers. Disposed explicitly
/// by the owning [_LocationFormScreenState] since it isn't a Widget/State
/// itself and Flutter won't dispose it automatically.
class _MemberEntry {
  final TextEditingController nameController;
  final TextEditingController roleTitleController;
  final TextEditingController phoneController;

  _MemberEntry({
    required this.nameController,
    required this.roleTitleController,
    required this.phoneController,
  });

  factory _MemberEntry.empty() => _MemberEntry(
    nameController: TextEditingController(),
    roleTitleController: TextEditingController(),
    phoneController: TextEditingController(),
  );

  factory _MemberEntry.fromExisting(LocationOrganizationMember member) =>
      _MemberEntry(
        nameController: TextEditingController(text: member.name),
        roleTitleController: TextEditingController(text: member.roleTitle),
        phoneController: TextEditingController(text: member.phone),
      );

  LocationOrganizationMember toDomain() => LocationOrganizationMember(
    name: nameController.text.trim(),
    roleTitle: roleTitleController.text.trim(),
    phone: phoneController.text.trim().isEmpty
        ? null
        : phoneController.text.trim(),
  );

  void dispose() {
    nameController.dispose();
    roleTitleController.dispose();
    phoneController.dispose();
  }
}

/// Fixed set of organizational roles a rumah tahfidz can assign — mirrors
/// the roles used to seed demo data (backend seedDummyData.ts's
/// ORG_ROLE_TITLES), kept as a static picklist instead of free text so
/// naming stays consistent across locations.
const List<String> kOrganizationRoleTitles = [
  'Ketua',
  'Sekretaris',
  'Bendahara',
  'Pengawas',
  'Bagian Perlengkapan',
  'Bagian Kesiswaan',
  'Pembimbing',
];

class _MemberFormRow extends StatelessWidget {
  final _MemberEntry entry;
  final VoidCallback onRemove;

  const _MemberFormRow({required this.entry, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final currentRole = entry.roleTitleController.text.trim();
    final roleOptions = [
      ...kOrganizationRoleTitles,
      // Preserve an existing custom value (e.g. loaded from data seeded
      // before this picklist existed) instead of silently discarding it.
      if (currentRole.isNotEmpty && !kOrganizationRoleTitles.contains(currentRole))
        currentRole,
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                TextFormField(
                  controller: entry.nameController,
                  decoration: const InputDecoration(labelText: 'Nama'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: currentRole.isEmpty ? null : currentRole,
                        decoration: const InputDecoration(labelText: 'Jabatan'),
                        isExpanded: true,
                        items: [
                          for (final role in roleOptions)
                            DropdownMenuItem(
                              value: role,
                              child: Text(role, overflow: TextOverflow.ellipsis),
                            ),
                        ],
                        onChanged: (value) => entry.roleTitleController.text = value ?? '',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: entry.phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Telepon (opsional)',
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.maroon),
            tooltip: 'Hapus anggota',
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

/// Cascading province/city dropdowns backed by ref_province/ref_city.
/// Picking a province resets the city (its options depend on the province).
class _ProvinceCityFields extends ConsumerStatefulWidget {
  final int? initialProvinceId;
  final int? initialCityId;
  final void Function(int? provinceId, int? cityId) onChanged;

  const _ProvinceCityFields({
    required this.initialProvinceId,
    required this.initialCityId,
    required this.onChanged,
  });

  @override
  ConsumerState<_ProvinceCityFields> createState() => _ProvinceCityFieldsState();
}

class _ProvinceCityFieldsState extends ConsumerState<_ProvinceCityFields> {
  late int? _provinceId = widget.initialProvinceId;
  late int? _cityId = widget.initialCityId;

  @override
  Widget build(BuildContext context) {
    final provinces = ref.watch(provincesProvider);
    final cities = ref.watch(citiesProvider(_provinceId));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: provinces.when(
            data: (list) => DropdownButtonFormField<int>(
              initialValue: _provinceId,
              decoration: const InputDecoration(labelText: 'Provinsi (opsional)'),
              isExpanded: true,
              items: [
                const DropdownMenuItem(value: null, child: Text('Pilih provinsi')),
                for (final province in list)
                  DropdownMenuItem(
                    value: province.id,
                    child: Text(
                      province.provinceName ?? '-',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (value) {
                setState(() {
                  _provinceId = value;
                  _cityId = null;
                });
                widget.onChanged(_provinceId, _cityId);
              },
            ),
            loading: () => const _DropdownPlaceholder(label: 'Provinsi'),
            error: (_, _) => const _DropdownPlaceholder(label: 'Provinsi', hasError: true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _provinceId == null
              ? const _DropdownPlaceholder(label: 'Kabupaten/Kota', enabled: false)
              : cities.when(
                  data: (list) => DropdownButtonFormField<int>(
                    initialValue: list.any((c) => c.id == _cityId) ? _cityId : null,
                    decoration: const InputDecoration(labelText: 'Kabupaten/Kota (opsional)'),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Pilih kota')),
                      for (final city in list)
                        DropdownMenuItem(
                          value: city.id,
                          child: Text(city.cityName ?? '-', overflow: TextOverflow.ellipsis),
                        ),
                    ],
                    onChanged: (value) {
                      setState(() => _cityId = value);
                      widget.onChanged(_provinceId, _cityId);
                    },
                  ),
                  loading: () => const _DropdownPlaceholder(label: 'Kabupaten/Kota'),
                  error: (_, _) =>
                      const _DropdownPlaceholder(label: 'Kabupaten/Kota', hasError: true),
                ),
        ),
      ],
    );
  }
}

class _DropdownPlaceholder extends StatelessWidget {
  final String label;
  final bool enabled;
  final bool hasError;

  const _DropdownPlaceholder({required this.label, this.enabled = true, this.hasError = false});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: null,
      decoration: InputDecoration(
        labelText: label,
        errorText: hasError ? 'Gagal memuat' : null,
        suffixIcon: enabled && !hasError
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : null,
      ),
      items: const [],
      onChanged: null,
    );
  }
}
