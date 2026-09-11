import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/media/image_compressor.dart';
import '../../../core/theme/app_colors.dart';
import '../../files/application/file_providers.dart';
import '../../locations/application/location_providers.dart';
import '../application/activity_providers.dart';
import '../domain/activity_photo_input.dart';

class _PickedPhoto {
  final XFile file;
  final TextEditingController captionController = TextEditingController();
  double progress = 0;
  bool failed = false;

  _PickedPhoto(this.file);
}

class ActivityCreateScreen extends ConsumerStatefulWidget {
  const ActivityCreateScreen({super.key});

  @override
  ConsumerState<ActivityCreateScreen> createState() =>
      _ActivityCreateScreenState();
}

class _ActivityCreateScreenState extends ConsumerState<ActivityCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();
  final List<_PickedPhoto> _photos = [];

  DateTime _activityDate = DateTime.now();
  bool _submitting = false;
  String? _submitStatus;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (final photo in _photos) {
      photo.captionController.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _activityDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _activityDate = picked);
  }

  Future<void> _pickPhotos() async {
    final picked = await _picker.pickMultiImage(imageQuality: 90);
    if (picked.isEmpty) return;
    setState(() => _photos.addAll(picked.map(_PickedPhoto.new)));
  }

  void _removePhoto(int index) {
    setState(() {
      _photos[index].captionController.dispose();
      _photos.removeAt(index);
    });
  }

  Future<List<ActivityPhotoInput>> _uploadPhotos() async {
    final fileRepository = ref.read(fileRepositoryProvider);
    final uploaded = <ActivityPhotoInput>[];

    for (var i = 0; i < _photos.length; i++) {
      final photo = _photos[i];
      setState(
        () => _submitStatus = 'Mengompres foto ${i + 1}/${_photos.length}...',
      );

      final Uint8List originalBytes = await photo.file.readAsBytes();
      final compressed = compressForUpload(originalBytes);

      setState(
        () => _submitStatus = 'Mengunggah foto ${i + 1}/${_photos.length}...',
      );
      final result = await fileRepository.upload(
        fileName: photo.file.name,
        bytes: compressed.bytes,
        mimeType: compressed.mimeType,
        onProgress: (sent, total) {
          if (total <= 0) return;
          setState(() => photo.progress = sent / total);
        },
      );

      uploaded.add(
        ActivityPhotoInput(
          objectKey: result.objectKey,
          mimeType: result.mimeType,
          sizeBytes: result.sizeBytes,
          displayOrder: i,
          caption: photo.captionController.text.trim(),
        ),
      );
    }

    return uploaded;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final locationId = ref.read(selectedLocationIdProvider);
    if (locationId == null) return;

    setState(() {
      _submitting = true;
      _submitStatus = null;
      for (final photo in _photos) {
        photo.progress = 0;
        photo.failed = false;
      }
    });

    try {
      final photos = await _uploadPhotos();

      setState(() => _submitStatus = 'Menyimpan aktivitas...');
      await ref
          .read(activityRepositoryProvider)
          .create(
            locationId: locationId,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            activityDate: _activityDate,
            photos: photos,
          );
      ref.invalidate(activityListProvider(locationId));
      if (mounted) context.pop();
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
    return Scaffold(
      appBar: AppBar(title: const Text('New activity')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Activity date'),
                subtitle: Text(
                  _activityDate.toLocal().toString().split(' ').first,
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _submitting ? null : _pickDate,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    'Photos (${_photos.length})',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _submitting ? null : _pickPhotos,
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: const Text('Add photos'),
                  ),
                ],
              ),
              Text(
                'Photos are compressed to about 500KB before upload.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              if (_photos.isNotEmpty)
                _PhotoGrid(photos: _photos, onRemove: _removePhoto),
              const SizedBox(height: 24),
              if (_submitStatus != null) ...[
                Text(
                  _submitStatus!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
              ],
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
                    : const Text('Save activity'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoGrid extends StatelessWidget {
  final List<_PickedPhoto> photos;
  final void Function(int index) onRemove;

  const _PhotoGrid({required this.photos, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.8,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) =>
          _PhotoTile(photo: photos[index], onRemove: () => onRemove(index)),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final _PickedPhoto photo;
  final VoidCallback onRemove;

  const _PhotoTile({required this.photo, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  photo.file.path.isEmpty ? File('') : File(photo.file.path),
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: AppColors.goldLight.withValues(alpha: 0.3),
                    child: const Icon(Icons.image_outlined),
                  ),
                ),
              ),
              if (photo.progress > 0 && photo.progress < 1)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          value: photo.progress,
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 2,
                right: 2,
                child: InkWell(
                  onTap: onRemove,
                  child: const CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.black54,
                    child: Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 28,
          child: TextField(
            controller: photo.captionController,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              hintText: 'Caption',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 4),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
