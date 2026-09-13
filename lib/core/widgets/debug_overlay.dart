import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_constants.dart';
import '../network/debug_api_log_service.dart';
import '../network/debug_error_log_service.dart';

/// Wraps [child] with a draggable debug FAB (visible only when
/// [AppConstants.isDebugMode]). The log panel renders directly in the Stack
/// — no Navigator/Overlay context needed.
class DebugOverlay extends StatefulWidget {
  const DebugOverlay({super.key, required this.child});

  final Widget child;

  @override
  State<DebugOverlay> createState() => _DebugOverlayState();
}

class _DebugOverlayState extends State<DebugOverlay> {
  static const _btnSize = 52.0;
  static const _margin = 16.0;

  Offset? _position;
  bool _panelOpen = false;

  @override
  Widget build(BuildContext context) {
    if (!AppConstants.isDebugMode) return widget.child;

    return LayoutBuilder(
      builder: (context, constraints) {
        _position ??= Offset(
          constraints.maxWidth - _btnSize - _margin,
          constraints.maxHeight - _btnSize - _margin - 72,
        );

        return Stack(
          children: [
            widget.child,

            // ── full-screen log panel ───────────────────────────
            // Overlay widget is needed so TextField inside the panel can
            // create a SelectionOverlay (required for backspace/delete).
            if (_panelOpen)
              Positioned.fill(
                child: Overlay(
                  initialEntries: [
                    OverlayEntry(
                      builder: (_) => _DebugLogPanel(
                        onClose: () => setState(() => _panelOpen = false),
                      ),
                    ),
                  ],
                ),
              ),

            // ── draggable FAB ───────────────────────────────────
            if (!_panelOpen)
              Positioned(
                left: _position!.dx,
                top: _position!.dy,
                child: GestureDetector(
                  onPanUpdate: (d) => setState(() {
                    _position = Offset(
                      (_position!.dx + d.delta.dx).clamp(
                        _margin,
                        constraints.maxWidth - _btnSize - _margin,
                      ),
                      (_position!.dy + d.delta.dy).clamp(
                        _margin,
                        constraints.maxHeight - _btnSize - _margin,
                      ),
                    );
                  }),
                  child: _DebugFab(onTap: () => setState(() => _panelOpen = true)),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Floating button
// ─────────────────────────────────────────────────────────────

class _DebugFab extends StatelessWidget {
  const _DebugFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        DebugApiLogService.instance.logs,
        DebugErrorLogService.instance.logs,
      ]),
      builder: (context, _) {
        final apiLogs = DebugApiLogService.instance.logs.value;
        final errorLogs = DebugErrorLogService.instance.logs.value;
        final hasApiError = apiLogs.any((e) => e.isError);
        final hasAppError = errorLogs.isNotEmpty;
        final hasError = hasApiError || hasAppError;
        final total = apiLogs.length + errorLogs.length;
        final color = hasError ? const Color(0xFFD32F2F) : const Color(0xFF37474F);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(26),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(2, 3)),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Center(
                    child: Icon(Icons.bug_report_rounded, color: Colors.white, size: 26),
                  ),
                  if (total > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: hasError ? Colors.orange : Colors.greenAccent.shade400,
                          shape: BoxShape.circle,
                          border: Border.all(color: color, width: 1.5),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          total > 99 ? '99' : '$total',
                          style: const TextStyle(
                            fontSize: 7,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Full-screen log panel
// ─────────────────────────────────────────────────────────────

class _DebugLogPanel extends StatefulWidget {
  const _DebugLogPanel({required this.onClose});

  final VoidCallback onClose;

  @override
  State<_DebugLogPanel> createState() => _DebugLogPanelState();
}

class _DebugLogPanelState extends State<_DebugLogPanel> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final TextEditingController _searchController;
  String _apiFilter = '';
  int? _expandedApiIndex;
  int? _expandedErrIndex;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(
      () => setState(() {
        _expandedApiIndex = null;
        _expandedErrIndex = null;
      }),
    );
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  _buildHeader(),
                  _buildTabBar(),
                  const Divider(height: 1),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [_buildApiTab(), _buildErrorTab()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── header ─────────────────────────────────────────────────

  Widget _buildHeader() {
    return ListenableBuilder(
      listenable: Listenable.merge([
        DebugApiLogService.instance.logs,
        DebugErrorLogService.instance.logs,
      ]),
      builder: (context, _) {
        final apiCount = DebugApiLogService.instance.logs.value.length;
        final errCount = DebugErrorLogService.instance.logs.value.length;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: const Color(0xFF263238),
          child: Row(
            children: [
              const Icon(Icons.bug_report_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Debug Log  ($apiCount API · $errCount error)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              _IconBtn(icon: Icons.delete_outline, onTap: _clearCurrentTab),
              const SizedBox(width: 4),
              _IconBtn(icon: Icons.close, onTap: widget.onClose),
            ],
          ),
        );
      },
    );
  }

  void _clearCurrentTab() {
    if (_tabController.index == 0) {
      DebugApiLogService.instance.clear();
      setState(() => _expandedApiIndex = null);
    } else {
      DebugErrorLogService.instance.clear();
      setState(() => _expandedErrIndex = null);
    }
  }

  // ── tab bar ─────────────────────────────────────────────────

  Widget _buildTabBar() {
    return ListenableBuilder(
      listenable: Listenable.merge([
        DebugApiLogService.instance.logs,
        DebugErrorLogService.instance.logs,
      ]),
      builder: (context, _) {
        final apiCount = DebugApiLogService.instance.logs.value.length;
        final errCount = DebugErrorLogService.instance.logs.value.length;
        return TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF263238),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF263238),
          tabs: [
            Tab(text: 'API ($apiCount)'),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Errors ($errCount)'),
                  if (errCount > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ── API tab ─────────────────────────────────────────────────

  Widget _buildApiTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Filter by URL or method…',
              prefixIcon: const Icon(Icons.search, size: 18),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            style: const TextStyle(fontSize: 13),
            onChanged: (v) => setState(() {
              _apiFilter = v.toLowerCase();
              _expandedApiIndex = null;
            }),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ValueListenableBuilder<List<DebugApiEntry>>(
            valueListenable: DebugApiLogService.instance.logs,
            builder: (context, logs, _) {
              final filtered = _apiFilter.isEmpty
                  ? logs
                  : logs
                        .where(
                          (e) =>
                              e.url.toLowerCase().contains(_apiFilter) ||
                              e.method.toLowerCase().contains(_apiFilter),
                        )
                        .toList();

              if (filtered.isEmpty) {
                return const Center(
                  child: Text('No requests yet', style: TextStyle(color: Colors.grey)),
                );
              }

              return ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final entry = filtered[i];
                  final isExpanded = _expandedApiIndex == i;
                  return _ApiEntryTile(
                    entry: entry,
                    isExpanded: isExpanded,
                    onToggle: () => setState(() => _expandedApiIndex = isExpanded ? null : i),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Errors tab ──────────────────────────────────────────────

  Widget _buildErrorTab() {
    return ValueListenableBuilder<List<DebugErrorEntry>>(
      valueListenable: DebugErrorLogService.instance.logs,
      builder: (context, logs, _) {
        if (logs.isEmpty) {
          return const Center(
            child: Text('No errors', style: TextStyle(color: Colors.grey)),
          );
        }

        return ListView.separated(
          itemCount: logs.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final entry = logs[i];
            final isExpanded = _expandedErrIndex == i;
            return _ErrorEntryTile(
              entry: entry,
              isExpanded: isExpanded,
              onToggle: () => setState(() => _expandedErrIndex = isExpanded ? null : i),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// API entry tile
// ─────────────────────────────────────────────────────────────

class _ApiEntryTile extends StatelessWidget {
  const _ApiEntryTile({required this.entry, required this.isExpanded, required this.onToggle});

  final DebugApiEntry entry;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _MethodBadge(entry.method),
                    const SizedBox(width: 6),
                    if (entry.statusCode != null) ...[
                      _StatusBadge(entry.statusCode!, entry.isError),
                      const SizedBox(width: 6),
                    ],
                    Expanded(
                      child: Text(
                        _shortUrl(entry.url),
                        style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _durationLabel(entry.duration),
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    _formatTime(entry.time),
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                ),
                if (entry.isError && entry.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      entry.errorMessage!,
                      style: const TextStyle(fontSize: 11, color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (isExpanded) _ApiExpandedBody(entry: entry),
      ],
    );
  }

  String _shortUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return '${uri.host}${uri.path}${uri.query.isNotEmpty ? '?${uri.query}' : ''}';
    } catch (_) {
      return url;
    }
  }

  String _durationLabel(Duration d) =>
      d.inSeconds >= 1 ? '${d.inSeconds}s' : '${d.inMilliseconds}ms';

  String _formatTime(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:'
      '${t.second.toString().padLeft(2, '0')}.${t.millisecond.toString().padLeft(3, '0')}';
}

class _ApiExpandedBody extends StatefulWidget {
  const _ApiExpandedBody({required this.entry});

  final DebugApiEntry entry;

  @override
  State<_ApiExpandedBody> createState() => _ApiExpandedBodyState();
}

class _ApiExpandedBodyState extends State<_ApiExpandedBody> {
  bool _copiedAll = false;

  Future<void> _copyAll() async {
    try {
      await Clipboard.setData(ClipboardData(text: widget.entry.copyAllText));
    } catch (_) {
      return;
    }
    if (!mounted) return;
    setState(() => _copiedAll = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _copiedAll = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 6),
            child: OutlinedButton.icon(
              onPressed: _copyAll,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 6),
                side: BorderSide(color: _copiedAll ? Colors.green : Colors.grey.shade400),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              icon: Icon(
                _copiedAll ? Icons.check_rounded : Icons.copy_all_rounded,
                size: 14,
                color: _copiedAll ? Colors.green : Colors.grey.shade600,
              ),
              label: Text(
                _copiedAll ? 'Copied!' : 'Copy All (Request + Headers + Response)',
                style: TextStyle(
                  fontSize: 11,
                  color: _copiedAll ? Colors.green : Colors.grey.shade600,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionBlock(label: 'Request URL', content: widget.entry.url),
                if (widget.entry.requestBody != null)
                  _SectionBlock(label: 'Request Body', content: widget.entry.prettyRequestBody),
                _SectionBlock(
                  label: 'Request Headers',
                  content: widget.entry.prettyRequestHeaders,
                ),
                _SectionBlock(
                  label: widget.entry.isError ? 'Error Response' : 'Response Body',
                  content: widget.entry.prettyResponseBody,
                  isError: widget.entry.isError,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Error entry tile
// ─────────────────────────────────────────────────────────────

class _ErrorEntryTile extends StatelessWidget {
  const _ErrorEntryTile({required this.entry, required this.isExpanded, required this.onToggle});

  final DebugErrorEntry entry;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _SourceBadge(entry.sourceLabel),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.message,
                        style: const TextStyle(fontSize: 12, color: Colors.red),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    _formatTime(entry.time),
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded && entry.stackTrace != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: _SectionBlock(label: 'Stack Trace', content: entry.stackTrace!, isError: true),
          ),
      ],
    );
  }

  String _formatTime(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:'
      '${t.second.toString().padLeft(2, '0')}.${t.millisecond.toString().padLeft(3, '0')}';
}

// ─────────────────────────────────────────────────────────────
// Shared section block (copyable monospace content)
// ─────────────────────────────────────────────────────────────

class _SectionBlock extends StatefulWidget {
  const _SectionBlock({required this.label, required this.content, this.isError = false});

  final String label;
  final String content;
  final bool isError;

  @override
  State<_SectionBlock> createState() => _SectionBlockState();
}

class _SectionBlockState extends State<_SectionBlock> {
  bool _copied = false;
  bool _visible = true;

  Future<void> _copy() async {
    try {
      await Clipboard.setData(ClipboardData(text: widget.content));
    } catch (_) {
      return;
    }
    if (!mounted) return;
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final labelColor = widget.isError ? Colors.red.shade700 : Colors.grey.shade700;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => setState(() => _visible = !_visible),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _visible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        size: 13,
                        color: labelColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: labelColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: _copy,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    _copied ? Icons.check_rounded : Icons.copy_rounded,
                    size: 14,
                    color: _copied ? Colors.green : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          if (_visible) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.isError ? Colors.red.shade50 : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: widget.isError ? Colors.red.shade200 : const Color(0xFFE0E0E0),
                ),
              ),
              child: Text(
                widget.content,
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: widget.isError ? Colors.red.shade900 : Colors.black87,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Small helpers
// ─────────────────────────────────────────────────────────────

class _MethodBadge extends StatelessWidget {
  const _MethodBadge(this.method);

  final String method;

  static Color _color(String m) => switch (m.toUpperCase()) {
    'GET' => const Color(0xFF1565C0),
    'POST' => const Color(0xFF2E7D32),
    'PUT' => const Color(0xFFE65100),
    'PATCH' => const Color(0xFF6A1B9A),
    'DELETE' => const Color(0xFFC62828),
    _ => const Color(0xFF37474F),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(color: _color(method), borderRadius: BorderRadius.circular(4)),
      child: Text(
        method.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge(this.code, this.isError);

  final int code;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError
        ? Colors.red.shade700
        : code < 300
        ? Colors.green.shade700
        : Colors.orange.shade700;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        '$code',
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  const _SourceBadge(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red.shade700,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
    );
  }
}
