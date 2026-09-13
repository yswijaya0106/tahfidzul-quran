import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/media/image_compressor.dart';
import '../../../core/theme/app_colors.dart';
import '../../files/application/file_providers.dart';
import '../../files/domain/uploaded_file.dart';

/// Wide banner image that lets the user set a location's cover photo from
/// either the camera or the gallery, compressing and uploading it
/// immediately so the caller only ever deals with the resulting
/// [UploadedFile.objectKey]. Mirrors StudentPhotoField's upload flow.
class LocationCoverPhotoField extends ConsumerStatefulWidget {
  final String? photoUrl;
  final ValueChanged<UploadedFile> onUploaded;

  const LocationCoverPhotoField({super.key, this.photoUrl, required this.onUploaded});

  @override
  ConsumerState<LocationCoverPhotoField> createState() => _LocationCoverPhotoFieldState();
}

class _LocationCoverPhotoFieldState extends ConsumerState<LocationCoverPhotoField> {
  final _picker = ImagePicker();
  Uint8List? _previewBytes;
  double? _progress;
  bool _uploading = false;

  Future<void> _pick() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Ambil foto'),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pilih dari galeri'),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picked = await _picker.pickImage(source: source, imageQuality: 90);
    if (picked == null) return;

    final originalBytes = await picked.readAsBytes();
    final compressed = compressForUpload(originalBytes);
    setState(() {
      _previewBytes = compressed.bytes;
      _uploading = true;
      _progress = 0;
    });

    try {
      final uploaded = await ref
          .read(fileRepositoryProvider)
          .upload(
            fileName: picked.name,
            bytes: compressed.bytes,
            mimeType: compressed.mimeType,
            onProgress: (sent, total) {
              if (total <= 0) return;
              if (mounted) setState(() => _progress = sent / total);
            },
          );
      widget.onUploaded(uploaded);
    } catch (_) {
      if (mounted) {
        setState(() => _previewBytes = null);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gagal mengunggah foto sampul.')));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _previewBytes != null || widget.photoUrl != null;

    return GestureDetector(
      onTap: _uploading ? null : _pick,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 140,
          width: double.infinity,
          color: AppColors.deepGreen.withValues(alpha: 0.08),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_previewBytes != null)
                Image.memory(_previewBytes!, fit: BoxFit.cover)
              else if (widget.photoUrl != null)
                Image.network(
                  widget.photoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const _PlaceholderContent(),
                )
              else
                const _PlaceholderContent(),
              if (_uploading)
                DecoratedBox(
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.35)),
                  child: Center(
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        value: _progress == 0 ? null : _progress,
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              if (!_uploading)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.gold,
                    child: Icon(
                      hasImage ? Icons.edit : Icons.add_a_photo,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceholderContent extends StatelessWidget {
  const _PlaceholderContent();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.mosque_outlined, size: 32, color: AppColors.deepGreen),
          SizedBox(height: 6),
          Text(
            'Foto sampul lokasi',
            style: TextStyle(color: AppColors.deepGreen, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
