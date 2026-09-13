import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/media/image_compressor.dart';
import '../../../core/theme/app_colors.dart';
import '../../files/application/file_providers.dart';
import '../../files/domain/uploaded_file.dart';

/// Circular avatar that lets the user set a student's photo from either the
/// camera or the gallery, compressing and uploading it immediately so the
/// caller only ever deals with the resulting [UploadedFile.objectKey].
class StudentPhotoField extends ConsumerStatefulWidget {
  final String? photoUrl;
  final ValueChanged<UploadedFile> onUploaded;

  const StudentPhotoField({super.key, this.photoUrl, required this.onUploaded});

  @override
  ConsumerState<StudentPhotoField> createState() => _StudentPhotoFieldState();
}

class _StudentPhotoFieldState extends ConsumerState<StudentPhotoField> {
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
        ).showSnackBar(const SnackBar(content: Text('Gagal mengunggah foto.')));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: _uploading ? null : _pick,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.deepGreen.withValues(alpha: 0.1),
              backgroundImage: _previewBytes != null
                  ? MemoryImage(_previewBytes!)
                  : (widget.photoUrl != null
                        ? NetworkImage(widget.photoUrl!) as ImageProvider
                        : null),
              child: _previewBytes == null && widget.photoUrl == null
                  ? const Icon(
                      Icons.person_outline,
                      size: 40,
                      color: AppColors.deepGreen,
                    )
                  : null,
            ),
            if (_uploading)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        value: _progress == 0 ? null : _progress,
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.gold,
                child: const Icon(
                  Icons.camera_alt,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
