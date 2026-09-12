import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/app_exception.dart';
import '../application/location_providers.dart';
import '../domain/location.dart';

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

  final List<_MemberEntry> _members = [];
  bool _membersLoaded = false;

  bool _submitting = false;
  Map<String, String>? _serverFieldErrors;

  bool get _isEditing => widget.location != null;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
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
          latitude: latitude,
          longitude: longitude,
          phone: _phoneController.text.trim(),
          description: _descriptionController.text.trim(),
          organizationMembers: organizationMembers,
        );
        ref.invalidate(locationDetailProvider(widget.location!.id));
      } else {
        await repository.create(
          name: _nameController.text.trim(),
          address: _addressController.text.trim(),
          latitude: latitude,
          longitude: longitude,
          phone: _phoneController.text.trim(),
          description: _descriptionController.text.trim(),
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
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama lokasi',
                  errorText: _serverFieldErrors?['name'],
                ),
                validator: (value) => (value == null || value.trim().length < 2)
                    ? 'Minimal 2 karakter'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Alamat',
                  errorText: _serverFieldErrors?['address'],
                ),
                maxLines: 2,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telepon (opsional)',
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
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    'Struktur Organisasi',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const Spacer(),
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
                  child: Text('Belum ada anggota. Tap "Tambah" untuk menambahkan.'),
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

class _MemberFormRow extends StatelessWidget {
  final _MemberEntry entry;
  final VoidCallback onRemove;

  const _MemberFormRow({required this.entry, required this.onRemove});

  @override
  Widget build(BuildContext context) {
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
                      child: TextFormField(
                        controller: entry.roleTitleController,
                        decoration: const InputDecoration(labelText: 'Jabatan'),
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
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Hapus anggota',
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
