enum AssessmentType { newMemorization, murojaah }

enum AssessmentGrade { mumtaz, jayyidJiddan, jayyid, needsReview }

AssessmentType assessmentTypeFromApi(String value) =>
    value == 'NEW_MEMORIZATION'
    ? AssessmentType.newMemorization
    : AssessmentType.murojaah;

String assessmentTypeToApi(AssessmentType type) =>
    type == AssessmentType.newMemorization ? 'NEW_MEMORIZATION' : 'MUROJAAH';

String assessmentTypeLabel(AssessmentType type) =>
    type == AssessmentType.newMemorization ? 'New memorization' : 'Murojaah';

AssessmentGrade assessmentGradeFromApi(String value) {
  switch (value) {
    case 'MUMTAZ':
      return AssessmentGrade.mumtaz;
    case 'JAYYID_JIDDAN':
      return AssessmentGrade.jayyidJiddan;
    case 'JAYYID':
      return AssessmentGrade.jayyid;
    default:
      return AssessmentGrade.needsReview;
  }
}

String assessmentGradeToApi(AssessmentGrade grade) {
  switch (grade) {
    case AssessmentGrade.mumtaz:
      return 'MUMTAZ';
    case AssessmentGrade.jayyidJiddan:
      return 'JAYYID_JIDDAN';
    case AssessmentGrade.jayyid:
      return 'JAYYID';
    case AssessmentGrade.needsReview:
      return 'NEEDS_REVIEW';
  }
}

String assessmentGradeLabel(AssessmentGrade grade) {
  switch (grade) {
    case AssessmentGrade.mumtaz:
      return 'Mumtaz';
    case AssessmentGrade.jayyidJiddan:
      return 'Jayyid Jiddan';
    case AssessmentGrade.jayyid:
      return 'Jayyid';
    case AssessmentGrade.needsReview:
      return 'Needs review';
  }
}

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
  final AssessmentGrade grade;
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
        grade: assessmentGradeFromApi(json['grade'] as String),
        notes: json['notes'] as String?,
      );
}
