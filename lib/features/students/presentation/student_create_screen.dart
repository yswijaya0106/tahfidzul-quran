import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/app_exception.dart';
import '../../locations/application/location_providers.dart';
import '../application/student_providers.dart';

class StudentCreateScreen extends ConsumerStatefulWidget {
  const StudentCreateScreen({super.key});

  @override
  ConsumerState<StudentCreateScreen> createState() =>
      _StudentCreateScreenState();
}

class _StudentCreateScreenState extends ConsumerState<StudentCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _guardianNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _studentPhoneController = TextEditingController();
  final _guardianPhoneController = TextEditingController();
  final _nikController = TextEditingController();

  bool _submitting = false;
  Map<String, String>? _serverFieldErrors;

  @override
  void dispose() {
    _fullNameController.dispose();
    _guardianNameController.dispose();
    _addressController.dispose();
    _studentPhoneController.dispose();
    _guardianPhoneController.dispose();
    _nikController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _serverFieldErrors = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final locationId = ref.read(selectedLocationIdProvider);
    if (locationId == null) return;

    setState(() => _submitting = true);
    try {
      final student = await ref
          .read(studentRepositoryProvider)
          .create(
            fullName: _fullNameController.text.trim(),
            locationId: locationId,
            nik: _nikController.text.trim().isEmpty
                ? null
                : _nikController.text.trim(),
            guardianName: _guardianNameController.text.trim().isEmpty
                ? null
                : _guardianNameController.text.trim(),
            address: _addressController.text.trim().isEmpty
                ? null
                : _addressController.text.trim(),
            studentPhone: _studentPhoneController.text.trim().isEmpty
                ? null
                : _studentPhoneController.text.trim(),
            guardianPhone: _guardianPhoneController.text.trim().isEmpty
                ? null
                : _guardianPhoneController.text.trim(),
          );

      if (mounted) {
        context.replace('/students/${student.id}');
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add student')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'Full name',
                  errorText: _serverFieldErrors?['fullName'],
                ),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nikController,
                decoration: const InputDecoration(labelText: 'NIK (optional)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _guardianNameController,
                decoration: const InputDecoration(
                  labelText: "Guardian's name (optional)",
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _studentPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Student phone (optional)',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _guardianPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Guardian phone (optional)',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address (optional)',
                ),
                maxLines: 2,
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
                    : const Text('Save student'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
