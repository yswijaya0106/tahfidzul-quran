class LocationDashboard {
  final String rangeFrom;
  final String rangeTo;
  final String timezone;
  final String lastUpdatedAt;
  final int activeStudentCount;
  final int assessmentCount;
  final String? latestAssessmentDate;
  final Map<String, int> distributionByGrade;
  final Map<String, int> distributionByType;
  final List<InactiveStudent> studentsWithoutRecentAssessment;
  final List<RecentActivity> recentActivities;

  const LocationDashboard({
    required this.rangeFrom,
    required this.rangeTo,
    required this.timezone,
    required this.lastUpdatedAt,
    required this.activeStudentCount,
    required this.assessmentCount,
    required this.latestAssessmentDate,
    required this.distributionByGrade,
    required this.distributionByType,
    required this.studentsWithoutRecentAssessment,
    required this.recentActivities,
  });

  factory LocationDashboard.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final range = json['range'] as Map<String, dynamic>;
    return LocationDashboard(
      rangeFrom: range['from'] as String,
      rangeTo: range['to'] as String,
      timezone: json['timezone'] as String,
      lastUpdatedAt: json['lastUpdatedAt'] as String,
      activeStudentCount: data['activeStudentCount'] as int,
      assessmentCount: data['assessmentCount'] as int,
      latestAssessmentDate: data['latestAssessmentDate'] as String?,
      distributionByGrade: Map<String, int>.from(
        data['distributionByGrade'] as Map,
      ),
      distributionByType: Map<String, int>.from(
        data['distributionByType'] as Map,
      ),
      studentsWithoutRecentAssessment:
          (data['studentsWithoutRecentAssessment'] as List<dynamic>)
              .map((e) => InactiveStudent.fromJson(e as Map<String, dynamic>))
              .toList(),
      recentActivities: (data['recentActivities'] as List<dynamic>)
          .map((e) => RecentActivity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class InactiveStudent {
  final String studentId;
  final String fullName;
  final String studentCode;

  const InactiveStudent({
    required this.studentId,
    required this.fullName,
    required this.studentCode,
  });

  factory InactiveStudent.fromJson(Map<String, dynamic> json) =>
      InactiveStudent(
        studentId: json['studentId'] as String,
        fullName: json['fullName'] as String,
        studentCode: json['studentCode'] as String,
      );
}

class RecentActivity {
  final String activityId;
  final String title;
  final String activityDate;

  const RecentActivity({
    required this.activityId,
    required this.title,
    required this.activityDate,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) => RecentActivity(
    activityId: json['activityId'] as String,
    title: json['title'] as String,
    activityDate: json['activityDate'] as String,
  );
}
