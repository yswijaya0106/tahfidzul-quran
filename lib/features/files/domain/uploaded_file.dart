class UploadedFile {
  final String objectKey;
  final String mimeType;
  final int sizeBytes;

  const UploadedFile({
    required this.objectKey,
    required this.mimeType,
    required this.sizeBytes,
  });
}
