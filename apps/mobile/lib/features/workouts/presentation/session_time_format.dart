/// Bezpečný lokální timestamp session `YYYY-MM-DD HH:MM` — bez citlivých
/// dat, deterministicky formátovaný.
String formatStartedAt(DateTime startedAtUtc) {
  final local = startedAtUtc.toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} '
      '${two(local.hour)}:${two(local.minute)}';
}

/// `M:SS` (nebo `H:MM:SS`) pro odpočty a uplynulý čas průvodce (C53).
String formatElapsed(int seconds) {
  final s = seconds < 0 ? 0 : seconds;
  final h = s ~/ 3600;
  final m = (s % 3600) ~/ 60;
  final sec = s % 60;
  String two(int v) => v.toString().padLeft(2, '0');
  return h > 0 ? '$h:${two(m)}:${two(sec)}' : '$m:${two(sec)}';
}
