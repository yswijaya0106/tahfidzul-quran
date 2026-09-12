import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/app_exception.dart';
import '../application/angkatan_providers.dart';
import '../domain/angkatan.dart';

/// Create/edit form for an angkatan (intake cohort). Pass [angkatan] to edit
/// an existing one; omit it (with [locationId]) to create a new one.
class AngkatanFormScreen extends ConsumerStatefulWidget {
  final String locationId;
  final Angkatan? angkatan;

  const AngkatanFormScreen({
    super.key,
    required this.locationId,
    this.angkatan,
  });

  @override
  ConsumerState<AngkatanFormScreen> createState() => _AngkatanFormScreenState();
}

class _AngkatanFormScreenState extends ConsumerState<AngkatanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(
    text: widget.angkatan?.name,
  );

  late DateTime _startDate =
      widget.angkatan != null
          ? DateTime.parse(widget.angkatan!.startDate)
          : DateTime(DateTime.now().year, 1, 1);
  late DateTime _endDate =
      widget.angkatan != null
          ? DateTime.parse(widget.angkatan!.endDate)
          : DateTime(DateTime.now().year, 12, 31);

  bool _submitting = false;
  Map<String, String>? _serverFieldErrors;

  bool get _isEditing => widget.angkatan != null;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2015),
      lastDate: DateTime(DateTime.now().year + 10),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _submit() async {
    setState(() => _serverFieldErrors = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);
    try {
      final repository = ref.read(angkatanRepositoryProvider);
      if (_isEditing) {
        await repository.update(
          widget.angkatan!.id,
          name: _nameController.text.trim(),
          startDate: _startDate,
          endDate: _endDate,
        );
      } else {
        await repository.create(
          locationId: widget.locationId,
          name: _nameController.text.trim(),
          startDate: _startDate,
          endDate: _endDate,
        );
      }
      ref.invalidate(angkatanListProvider(widget.locationId));
      if (mounted) context.pop(true);
    } on AppException catch (error) {
      setState(() => _serverFieldErrors = error.fields);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Angkatan' : 'Tambah Angkatan'),
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
                  labelText: 'Nama angkatan',
                  errorText: _serverFieldErrors?['name'],
                ),
                validator: (value) => (value == null || value.trim().length < 2)
                    ? 'Minimal 2 karakter'
                    : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Tanggal mulai'),
                subtitle: Text(_formatDate(_startDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _submitting ? null : () => _pickDate(isStart: true),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Tanggal selesai'),
                subtitle: Text(_formatDate(_endDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _submitting ? null : () => _pickDate(isStart: false),
              ),
              if (_serverFieldErrors?['endDate'] != null) ...[
                const SizedBox(height: 4),
                Text(
                  _serverFieldErrors!['endDate']!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ],
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
                    : Text(_isEditing ? 'Simpan perubahan' : 'Simpan angkatan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
