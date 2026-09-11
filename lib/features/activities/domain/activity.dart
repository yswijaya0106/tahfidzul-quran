class Activity {
  final String id;
  final String locationId;
  final String title;
  final String? description;
  final String activityDate;

  const Activity({
    required this.id,
    required this.locationId,
    required this.title,
    required this.description,
    required this.activityDate,
  });

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
    id: json['id'] as String,
    locationId: json['locationId'] as String,
    title: json['title'] as String,
    description: json['description'] as String?,
    activityDate: json['activityDate'] as String,
  );
}
