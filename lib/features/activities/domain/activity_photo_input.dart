/// Input for one photo attached to an activity being created/updated.
/// Mirrors the backend's `photos[]` schema in `activities.routes.ts`.
class ActivityPhotoInput {
  final String objectKey;
  final String mimeType;
  final int sizeBytes;
  final String? caption;
  final int displayOrder;

  const ActivityPhotoInput({
    required this.objectKey,
    required this.mimeType,
    required this.sizeBytes,
    required this.displayOrder,
    this.caption,
  });

  Map<String, dynamic> toJson() => {
    'objectKey': objectKey,
    'mimeType': mimeType,
    'sizeBytes': sizeBytes,
    'displayOrder': displayOrder,
    if (caption != null && caption!.isNotEmpty) 'caption': caption,
  };
}
