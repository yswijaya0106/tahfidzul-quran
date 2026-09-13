import '../../../core/domain/target_status.dart';
import 'grade.dart';

export '../../../core/domain/target_status.dart';
export 'grade.dart';

enum AssessmentType { newMemorization, murojaah }

AssessmentType assessmentTypeFromApi(String value) =>
    value == 'NEW_MEMORIZATION'
    ? AssessmentType.newMemorization
    : AssessmentType.murojaah;

String assessmentTypeToApi(AssessmentType type) =>
    type == AssessmentType.newMemorization ? 'NEW_MEMORIZATION' : 'MUROJAAH';

String assessmentTypeLabel(AssessmentType type) =>
    type == AssessmentType.newMemorization ? 'Hafalan baru' : 'Murojaah';

/// @deprecated use [gradeFromApi] from grade.dart instead; kept as an alias
/// during the transition.
Grade assessmentGradeFromApi(String value) => gradeFromApi(value);

/// @deprecated use [gradeToApi] from grade.dart instead.
String assessmentGradeToApi(Grade grade) => gradeToApi(grade);

/// @deprecated use [gradeLabel] from grade.dart instead.
String assessmentGradeLabel(Grade grade) => gradeLabel(grade);

class MemorizationAssessment {
  final String id;
  final String studentId;
  final String locationId;
  final String assessmentDate;
  /// The student's program day (1-300) on assessmentDate, or null if their
  /// program_start_date isn't set.
  final int? dayNumber;
  final AssessmentType assessmentType;
  final int startSurahNumber;
  final int startVerseNumber;
  final int endSurahNumber;
  final int endVerseNumber;
  final Grade grade;
  final String? notes;
  final int? targetEndSurahNumber;
  final int? targetEndVerseNumber;
  final TargetStatus targetStatus;
  /// Linear verse count (from surah 1 verse 1) of this assessment's end
  /// position, for charting achievement over time.
  final int achievedCumulativeVerses;
  /// Same linear measure for the daily target's end position, or null when
  /// there's no target data for this assessment's day.
  final int? targetCumulativeVerses;

  const MemorizationAssessment({
    required this.id,
    required this.studentId,
    required this.locationId,
    required this.assessmentDate,
    required this.dayNumber,
    required this.assessmentType,
    required this.startSurahNumber,
    required this.startVerseNumber,
    required this.endSurahNumber,
    required this.endVerseNumber,
    required this.grade,
    required this.notes,
    required this.targetEndSurahNumber,
    required this.targetEndVerseNumber,
    required this.targetStatus,
    required this.achievedCumulativeVerses,
    required this.targetCumulativeVerses,
  });

  factory MemorizationAssessment.fromJson(Map<String, dynamic> json) =>
      MemorizationAssessment(
        id: json['id'] as String,
        studentId: json['studentId'] as String,
        locationId: json['locationId'] as String,
        assessmentDate: json['assessmentDate'] as String,
        dayNumber: json['dayNumber'] as int?,
        assessmentType: assessmentTypeFromApi(json['assessmentType'] as String),
        startSurahNumber: json['startSurahNumber'] as int,
        startVerseNumber: json['startVerseNumber'] as int,
        endSurahNumber: json['endSurahNumber'] as int,
        endVerseNumber: json['endVerseNumber'] as int,
        grade: gradeFromApi(json['grade'] as String),
        notes: json['notes'] as String?,
        targetEndSurahNumber: json['targetEndSurahNumber'] as int?,
        targetEndVerseNumber: json['targetEndVerseNumber'] as int?,
        targetStatus: targetStatusFromApi(json['targetStatus'] as String),
        achievedCumulativeVerses: json['achievedCumulativeVerses'] as int,
        targetCumulativeVerses: json['targetCumulativeVerses'] as int?,
      );
}
