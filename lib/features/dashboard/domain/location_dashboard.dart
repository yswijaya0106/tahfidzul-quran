import '../../../core/domain/target_status.dart';

export '../../../core/domain/target_status.dart';

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
  final List<TopStudent> topStudents;

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
    required this.topStudents,
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
      topStudents: (data['topStudents'] as List<dynamic>? ?? [])
          .map((e) => TopStudent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TopStudent {
  final String studentId;
  final String fullName;
  final String studentCode;
  final int assessmentCount;
  final int mumtazCount;

  const TopStudent({
    required this.studentId,
    required this.fullName,
    required this.studentCode,
    required this.assessmentCount,
    required this.mumtazCount,
  });

  factory TopStudent.fromJson(Map<String, dynamic> json) => TopStudent(
    studentId: json['studentId'] as String,
    fullName: json['fullName'] as String,
    studentCode: json['studentCode'] as String,
    assessmentCount: json['assessmentCount'] as int,
    mumtazCount: json['mumtazCount'] as int,
  );
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
  final String? thumbnailUrl;

  const RecentActivity({
    required this.activityId,
    required this.title,
    required this.activityDate,
    this.thumbnailUrl,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) => RecentActivity(
    activityId: json['activityId'] as String,
    title: json['title'] as String,
    activityDate: json['activityDate'] as String,
    thumbnailUrl: json['thumbnailUrl'] as String?,
  );
}

/// Admin-only, cross-location submission progress for a single day.
class LocationsOverview {
  final String date;
  final String lastUpdatedAt;
  final List<LocationOverviewItem> locations;

  const LocationsOverview({
    required this.date,
    required this.lastUpdatedAt,
    required this.locations,
  });

  factory LocationsOverview.fromJson(Map<String, dynamic> json) =>
      LocationsOverview(
        date: json['date'] as String,
        lastUpdatedAt: json['lastUpdatedAt'] as String,
        locations: (json['data'] as List<dynamic>)
            .map((e) => LocationOverviewItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class LocationOverviewItem {
  final String locationId;
  final String locationName;
  final String? kabKota;
  final String status;
  final int activeStudentCount;
  final int assessmentsToday;
  final int activitiesToday;
  final int photosToday;
  final String? lastAssessmentAt;
  final String? lastActivityAt;

  const LocationOverviewItem({
    required this.locationId,
    required this.locationName,
    required this.kabKota,
    required this.status,
    required this.activeStudentCount,
    required this.assessmentsToday,
    required this.activitiesToday,
    required this.photosToday,
    required this.lastAssessmentAt,
    required this.lastActivityAt,
  });

  bool get hasSubmittedAssessmentToday => assessmentsToday > 0;
  bool get hasSubmittedActivityToday => activitiesToday > 0;

  factory LocationOverviewItem.fromJson(Map<String, dynamic> json) =>
      LocationOverviewItem(
        locationId: json['locationId'] as String,
        locationName: json['locationName'] as String,
        kabKota: json['kabKota'] as String?,
        status: json['status'] as String,
        activeStudentCount: json['activeStudentCount'] as int,
        assessmentsToday: json['assessmentsToday'] as int,
        activitiesToday: json['activitiesToday'] as int,
        photosToday: json['photosToday'] as int,
        lastAssessmentAt: json['lastAssessmentAt'] as String?,
        lastActivityAt: json['lastActivityAt'] as String?,
      );
}

/// Admin-only list of students who submitted a new-memorization assessment
/// today, each compared against the 300-day program's daily target.
class MemorizationProgressOverview {
  final String date;
  final String lastUpdatedAt;
  final List<StudentMemorizationProgress> students;

  const MemorizationProgressOverview({
    required this.date,
    required this.lastUpdatedAt,
    required this.students,
  });

  factory MemorizationProgressOverview.fromJson(Map<String, dynamic> json) =>
      MemorizationProgressOverview(
        date: json['date'] as String,
        lastUpdatedAt: json['lastUpdatedAt'] as String,
        students: (json['data'] as List<dynamic>)
            .map(
              (e) =>
                  StudentMemorizationProgress.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      );
}

class StudentMemorizationProgress {
  final String studentId;
  final String fullName;
  final String studentCode;
  final String locationId;
  final String locationName;
  final String? kabKota;
  final String assessmentDate;
  final int achievedEndSurahNumber;
  final int achievedEndVerseNumber;
  final int? dayNumber;
  final int? targetEndSurahNumber;
  final int? targetEndVerseNumber;
  final TargetStatus targetStatus;

  const StudentMemorizationProgress({
    required this.studentId,
    required this.fullName,
    required this.studentCode,
    required this.locationId,
    required this.locationName,
    required this.kabKota,
    required this.assessmentDate,
    required this.achievedEndSurahNumber,
    required this.achievedEndVerseNumber,
    required this.dayNumber,
    required this.targetEndSurahNumber,
    required this.targetEndVerseNumber,
    required this.targetStatus,
  });

  factory StudentMemorizationProgress.fromJson(Map<String, dynamic> json) =>
      StudentMemorizationProgress(
        studentId: json['studentId'] as String,
        fullName: json['fullName'] as String,
        studentCode: json['studentCode'] as String,
        locationId: json['locationId'] as String,
        locationName: json['locationName'] as String,
        kabKota: json['kabKota'] as String?,
        assessmentDate: json['assessmentDate'] as String,
        achievedEndSurahNumber: json['achievedEndSurahNumber'] as int,
        achievedEndVerseNumber: json['achievedEndVerseNumber'] as int,
        dayNumber: json['dayNumber'] as int?,
        targetEndSurahNumber: json['targetEndSurahNumber'] as int?,
        targetEndVerseNumber: json['targetEndVerseNumber'] as int?,
        targetStatus: targetStatusFromApi(json['targetStatus'] as String),
      );
}

enum LeaderboardScope { aggregate, daily }

String leaderboardScopeToApi(LeaderboardScope scope) =>
    scope == LeaderboardScope.aggregate ? 'AGGREGATE' : 'DAILY';

/// Admin-only, school-wide ranking of students by how far their achieved
/// Quran position exceeds (or trails) their daily target, in linear verse
/// count. `scope: aggregate` compares each student's furthest-ever position
/// against today's target for their program day; `scope: daily` only
/// considers students who submitted a new-memorization assessment on [date].
class LeaderboardOverview {
  final LeaderboardScope scope;
  final String date;
  final String lastUpdatedAt;
  final List<LeaderboardItem> items;

  const LeaderboardOverview({
    required this.scope,
    required this.date,
    required this.lastUpdatedAt,
    required this.items,
  });

  factory LeaderboardOverview.fromJson(Map<String, dynamic> json) {
    return LeaderboardOverview(
      scope: (json['scope'] as String) == 'AGGREGATE'
          ? LeaderboardScope.aggregate
          : LeaderboardScope.daily,
      date: json['date'] as String,
      lastUpdatedAt: json['lastUpdatedAt'] as String,
      items: (json['data'] as List<dynamic>)
          .map((e) => LeaderboardItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class LeaderboardItem {
  final int rank;
  final String studentId;
  final String fullName;
  final String studentCode;
  final String locationId;
  final String locationName;
  final String? kabKota;
  final int dayNumber;
  final String? assessmentDate;
  final int achievedEndSurahNumber;
  final int achievedEndVerseNumber;
  final int targetEndSurahNumber;
  final int targetEndVerseNumber;
  final int deltaVerses;
  final TargetStatus targetStatus;

  const LeaderboardItem({
    required this.rank,
    required this.studentId,
    required this.fullName,
    required this.studentCode,
    required this.locationId,
    required this.locationName,
    required this.kabKota,
    required this.dayNumber,
    required this.assessmentDate,
    required this.achievedEndSurahNumber,
    required this.achievedEndVerseNumber,
    required this.targetEndSurahNumber,
    required this.targetEndVerseNumber,
    required this.deltaVerses,
    required this.targetStatus,
  });

  bool get isAhead => deltaVerses >= 0;

  factory LeaderboardItem.fromJson(Map<String, dynamic> json) => LeaderboardItem(
    rank: json['rank'] as int,
    studentId: json['studentId'] as String,
    fullName: json['fullName'] as String,
    studentCode: json['studentCode'] as String,
    locationId: json['locationId'] as String,
    locationName: json['locationName'] as String,
    kabKota: json['kabKota'] as String?,
    dayNumber: json['dayNumber'] as int,
    assessmentDate: json['assessmentDate'] as String?,
    achievedEndSurahNumber: json['achievedEndSurahNumber'] as int,
    achievedEndVerseNumber: json['achievedEndVerseNumber'] as int,
    targetEndSurahNumber: json['targetEndSurahNumber'] as int,
    targetEndVerseNumber: json['targetEndVerseNumber'] as int,
    deltaVerses: json['deltaVerses'] as int,
    targetStatus: targetStatusFromApi(json['targetStatus'] as String),
  );
}

/// Admin-only feed of today's activity photos across every location, most
/// recently uploaded first.
class TodayActivityPhotosOverview {
  final String date;
  final String lastUpdatedAt;
  final List<TodayActivityPhoto> photos;

  const TodayActivityPhotosOverview({
    required this.date,
    required this.lastUpdatedAt,
    required this.photos,
  });

  factory TodayActivityPhotosOverview.fromJson(Map<String, dynamic> json) =>
      TodayActivityPhotosOverview(
        date: json['date'] as String,
        lastUpdatedAt: json['lastUpdatedAt'] as String,
        photos: (json['data'] as List<dynamic>)
            .map((e) => TodayActivityPhoto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class TodayActivityPhoto {
  final String photoId;
  final String photoUrl;
  final String? caption;
  final String uploadedAt;
  final String activityId;
  final String activityTitle;
  final String locationId;
  final String locationName;
  final String? kabKota;

  const TodayActivityPhoto({
    required this.photoId,
    required this.photoUrl,
    required this.caption,
    required this.uploadedAt,
    required this.activityId,
    required this.activityTitle,
    required this.locationId,
    required this.locationName,
    required this.kabKota,
  });

  factory TodayActivityPhoto.fromJson(Map<String, dynamic> json) =>
      TodayActivityPhoto(
        photoId: json['photoId'] as String,
        photoUrl: json['photoUrl'] as String,
        caption: json['caption'] as String?,
        uploadedAt: json['uploadedAt'] as String,
        activityId: json['activityId'] as String,
        activityTitle: json['activityTitle'] as String,
        locationId: json['locationId'] as String,
        locationName: json['locationName'] as String,
        kabKota: json['kabKota'] as String?,
      );
}
