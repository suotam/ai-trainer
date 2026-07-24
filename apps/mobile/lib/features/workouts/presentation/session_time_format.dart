/// Bezpečný lokální timestamp session `YYYY-MM-DD HH:MM` — bez citlivých
/// dat, deterministicky formátovaný.
String formatStartedAt(DateTime startedAtUtc) {
  final local = startedAtUtc.toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} '
      '${two(local.hour)}:${two(local.minute)}';
}
