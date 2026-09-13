import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

enum DebugErrorSource { flutter, dart }

class DebugErrorEntry {
  const DebugErrorEntry({
    required this.time,
    required this.source,
    required this.message,
    this.stackTrace,
  });

  final DateTime time;
  final DebugErrorSource source;
  final String message;
  final String? stackTrace;

  String get sourceLabel => switch (source) {
    DebugErrorSource.flutter => 'Flutter',
    DebugErrorSource.dart => 'Dart',
  };
}

/// Singleton that accumulates app error entries for the debug overlay.
class DebugErrorLogService {
  DebugErrorLogService._();
  static final DebugErrorLogService instance = DebugErrorLogService._();

  static const int _maxEntries = 100;

  final ValueNotifier<List<DebugErrorEntry>> logs = ValueNotifier(const []);

  void add(DebugErrorEntry entry) {
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks) {
      _commit(entry);
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) => _commit(entry));
    }
  }

  void _commit(DebugErrorEntry entry) {
    final updated = [entry, ...logs.value];
    logs.value = updated.length > _maxEntries
        ? updated.sublist(0, _maxEntries)
        : updated;
  }

  void clear() => logs.value = const [];
}
