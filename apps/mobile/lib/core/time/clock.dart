import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Testovatelná hranice času (ADR-010). Seed i „dnešní datum" čtou čas
/// výhradně přes tento provider; testy jej přepisují fixní hodnotou.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Lokální datum `YYYY-MM-DD` (fyzický model §4) z daného okamžiku.
String formatLocalDate(DateTime moment) {
  final local = moment.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$month-$day';
}

/// Dnešní lokální datum pro Today flow.
final todayLocalDateProvider = Provider<String>(
  (ref) => formatLocalDate(ref.watch(clockProvider)()),
);
