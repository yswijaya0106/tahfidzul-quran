import 'grade.dart';

export 'grade.dart';

enum AssessmentType { newMemorization, murojaah }

AssessmentType assessmentTypeFromApi(String value) =>
    value == 'NEW_MEMORIZATION'
    ? AssessmentType.newMemorization
    : AssessmentType.murojaah;

String assessmentTypeToApi(AssessmentType type) =>
    type == AssessmentType.newMemorization ? 'NEW_MEMORIZATION' : 'MUROJAAH';

String assessmentTypeLabel(AssessmentType type) =>
    type == AssessmentType.newMemorization ? 'New memorization' : 'Murojaah';

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
  final AssessmentType assessmentType;
  final int startSurahNumber;
  final int startVerseNumber;
  final int endSurahNumber;
  final int endVerseNumber;
  final Grade grade;
  final String? notes;

  const MemorizationAssessment({
    required this.id,
    required this.studentId,
    required this.locationId,
    required this.assessmentDate,
    required this.assessmentType,
    required this.startSurahNumber,
    required this.startVerseNumber,
    required this.endSurahNumber,
    required this.endVerseNumber,
    required this.grade,
    required this.notes,
  });

  factory MemorizationAssessment.fromJson(Map<String, dynamic> json) =>
      MemorizationAssessment(
        id: json['id'] as String,
        studentId: json['studentId'] as String,
        locationId: json['locationId'] as String,
        assessmentDate: json['assessmentDate'] as String,
        assessmentType: assessmentTypeFromApi(json['assessmentType'] as String),
        startSurahNumber: json['startSurahNumber'] as int,
        startVerseNumber: json['startVerseNumber'] as int,
        endSurahNumber: json['endSurahNumber'] as int,
        endVerseNumber: json['endVerseNumber'] as int,
        grade: gradeFromApi(json['grade'] as String),
        notes: json['notes'] as String?,
      );
}
