import 'student.dart';

/// A single memorization assessment position, as returned by
/// `latestNewMemorization`/`latestMurojaah` on the profile endpoint (the
/// backend returns the raw database row for those, hence the snake_case
/// keys below rather than the usual camelCase API convention).
class AssessmentPosition {
  final int startSurahNumber;
  final int startVerseNumber;
  final int endSurahNumber;
  final int endVerseNumber;
  final String grade;
  final String assessmentDate;

  const AssessmentPosition({
    required this.startSurahNumber,
    required this.startVerseNumber,
    required this.endSurahNumber,
    required this.endVerseNumber,
    required this.grade,
    required this.assessmentDate,
  });

  factory AssessmentPosition.fromJson(Map<String, dynamic> json) =>
      AssessmentPosition(
        startSurahNumber: json['start_surah_number'] as int,
        startVerseNumber: json['start_verse_number'] as int,
        endSurahNumber: json['end_surah_number'] as int,
        endVerseNumber: json['end_verse_number'] as int,
        grade: json['grade'] as String,
        assessmentDate: json['assessment_date'] as String,
      );
}

class MemorizationProgress {
  final AssessmentPosition? latestNewMemorization;
  final AssessmentPosition? latestMurojaah;
  final Map<String, int> distributionByGrade;

  const MemorizationProgress({
    required this.latestNewMemorization,
    required this.latestMurojaah,
    required this.distributionByGrade,
  });

  factory MemorizationProgress.fromJson(Map<String, dynamic> json) =>
      MemorizationProgress(
        latestNewMemorization: json['latestNewMemorization'] != null
            ? AssessmentPosition.fromJson(
                json['latestNewMemorization'] as Map<String, dynamic>,
              )
            : null,
        latestMurojaah: json['latestMurojaah'] != null
            ? AssessmentPosition.fromJson(
                json['latestMurojaah'] as Map<String, dynamic>,
              )
            : null,
        distributionByGrade: Map<String, int>.from(
          json['distributionByGrade'] as Map,
        ),
      );
}

/// Combines a student's profile with their memorization progress, as
/// returned by `GET /students/:id/profile`.
class StudentProfile {
  final Student student;
  final MemorizationProgress progress;

  const StudentProfile({required this.student, required this.progress});

  factory StudentProfile.fromJson(Map<String, dynamic> json) =>
      StudentProfile(
        student: Student.fromJson(json['profile'] as Map<String, dynamic>),
        progress: MemorizationProgress.fromJson(
          json['progress'] as Map<String, dynamic>,
        ),
      );
}
