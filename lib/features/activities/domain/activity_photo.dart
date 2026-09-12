/// A signed, time-limited view URL for one activity photo. Fetched only
/// when the caller asks to see photos for a specific activity (not embedded
/// in the activity list), so browsing many locations stays cheap.
class ActivityPhoto {
  final String id;
  final String url;
  final String? caption;
  final int displayOrder;

  const ActivityPhoto({
    required this.id,
    required this.url,
    required this.caption,
    required this.displayOrder,
  });

  factory ActivityPhoto.fromJson(Map<String, dynamic> json) => ActivityPhoto(
    id: json['id'] as String,
    url: json['url'] as String,
    caption: json['caption'] as String?,
    displayOrder: json['displayOrder'] as int,
  );
}
