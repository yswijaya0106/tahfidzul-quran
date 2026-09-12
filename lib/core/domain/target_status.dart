/// Whether a memorization position is at/past the 300-day program's daily
/// target for that day, behind it, or has no target data to compare against
/// (no program_start_date on the student, or the day is outside daily_targets).
enum TargetStatus { reached, notReached, noTargetData }

TargetStatus targetStatusFromApi(String value) => switch (value) {
  'REACHED' => TargetStatus.reached,
  'NOT_REACHED' => TargetStatus.notReached,
  _ => TargetStatus.noTargetData,
};
