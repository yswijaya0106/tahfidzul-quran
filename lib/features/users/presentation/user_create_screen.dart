import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/app_exception.dart';
import '../../locations/application/location_providers.dart';
import '../application/user_admin_providers.dart';

class UserCreateScreen extends ConsumerStatefulWidget {
  const UserCreateScreen({super.key});

  @override
  ConsumerState<UserCreateScreen> createState() => _UserCreateScreenState();
}

class _UserCreateScreenState extends ConsumerState<UserCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  String _role = 'LOCATION_OPERATOR';
  final Set<String> _selectedLocationIds = {};
  bool _submitting = false;
  Map<String, String>? _serverFieldErrors;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _serverFieldErrors = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);
    try {
      await ref
          .read(userAdminRepositoryProvider)
          .create(
            fullName: _fullNameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            password: _passwordController.text,
            role: _role,
            locationIds: _role == 'LOCATION_OPERATOR'
                ? _selectedLocationIds.toList()
                : null,
          );

      ref.invalidate(userAdminListProvider);
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

  @override
  Widget build(BuildContext context) {
    final locations = ref.watch(locationListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Pengguna')),
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
                  labelText: 'Nama lengkap',
                  errorText: _serverFieldErrors?['fullName'],
                ),
                validator: (value) => (value == null || value.trim().length < 2)
                    ? 'Minimal 2 karakter'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  errorText: _serverFieldErrors?['email'],
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telepon (opsional bila ada email)',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Kata sandi'),
                obscureText: true,
                validator: (value) => (value == null || value.length < 8)
                    ? 'Minimal 8 karakter'
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _role,
                decoration: const InputDecoration(labelText: 'Peran'),
                items: const [
                  DropdownMenuItem(value: 'ADMIN', child: Text('Admin')),
                  DropdownMenuItem(
                    value: 'LOCATION_OPERATOR',
                    child: Text('Operator Lokasi'),
                  ),
                ],
                onChanged: (value) => setState(() => _role = value ?? _role),
              ),
              if (_role == 'LOCATION_OPERATOR') ...[
                const SizedBox(height: 16),
                Text(
                  'Lokasi yang ditugaskan',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (_serverFieldErrors?['locationIds'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _serverFieldErrors!['locationIds']!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                locations.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: LinearProgressIndicator(),
                  ),
                  error: (error, stackTrace) =>
                      Text('Gagal memuat lokasi: $error'),
                  data: (result) => Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: result.data.map((location) {
                      final selected = _selectedLocationIds.contains(
                        location.id,
                      );
                      return FilterChip(
                        label: Text(location.name),
                        selected: selected,
                        onSelected: (value) => setState(() {
                          if (value) {
                            _selectedLocationIds.add(location.id);
                          } else {
                            _selectedLocationIds.remove(location.id);
                          }
                        }),
                      );
                    }).toList(),
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
                    : const Text('Simpan pengguna'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
