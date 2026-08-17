import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/time/clock.dart';
import '../data/drift_guided_session_repository.dart';
import '../domain/guided_session.dart';
import '../domain/guided_session_repository.dart';
import '../domain/record_performance_result.dart';
import 'session_tracker_providers.dart';
import 'workout_detail_providers.dart';

/// Composition průvodce (C53): repository stavu průvodce + odvozený stav
/// z detailu, trackeru, session značek a `now` (GSP-002/005).
final guidedSessionRepositoryProvider = Provider<GuidedSessionRepository>(
  (ref) => DriftGuidedSessionRepository(ref.watch(appDatabaseProvider)),
);

/// Sekundový ticker jen pro překreslení časovačů (GSP-005) — časy se vždy
/// odvozují z uložených značek + clock, ne z tiků.
final guidedTickerProvider = StreamProvider<int>((ref) {
  var tick = 0;
  return Stream.periodic(const Duration(seconds: 1), (_) => ++tick);
});

/// Persistované značky session pro průvodce.
final guidedSessionRecordProvider =
    FutureProvider.family<GuidedSessionRecord?, String>(
      (ref, sessionId) =>
          ref.watch(guidedSessionRepositoryProvider).record(sessionId),
    );

/// Odvozený stav průvodce (čistá funkce nad read modely) — `null`, dokud
/// nejsou vstupy načtené nebo session neexistuje.
final guidedSessionStateProvider = Provider.family<GuidedSessionState?, String>(
  (ref, sessionId) {
    // Ticker: každou sekundu se přepočítá `now`.
    ref.watch(guidedTickerProvider);
    final record = ref.watch(guidedSessionRecordProvider(sessionId)).value;
    if (record == null) {
      return null;
    }
    final detail = ref
        .watch(workoutDetailProvider(record.workoutInstanceId))
        .value;
    final tracker = ref.watch(sessionTrackerProvider(sessionId)).value;
    if (detail == null || tracker == null) {
      return null;
    }
    return buildGuidedState(
      detail: detail,
      tracker: tracker,
      session: record,
      now: ref.watch(clockProvider)(),
    );
  },
);

/// Akce průvodce (C53 §5): kompozice existujících operací (session značky
/// přes [GuidedSessionRepository], výkony přes performance repo) — žádná
/// paralelní write cesta (GSP-001). Každá akce invaliduje read modely.
class GuidedSessionController extends Notifier<bool> {
  @override
  bool build() => false;

  Future<void> goToStep(String sessionId, String stepId) => _run(sessionId, () {
    return ref
        .read(guidedSessionRepositoryProvider)
        .goToStep(sessionId: sessionId, stepId: stepId, now: _now());
  });

  /// DURATION sada: fáze SET_RUNNING + krok IN_PROGRESS.
  Future<void> startSet(String sessionId, GuidedStep step, GuidedSet set) =>
      _run(sessionId, () async {
        if (set.setPerformanceId != null) {
          await ref
              .read(workoutPerformanceRepositoryProvider)
              .startSet(setPerformanceId: set.setPerformanceId!, now: _now());
        }
        return ref
            .read(guidedSessionRepositoryProvider)
            .startPhase(
              sessionId: sessionId,
              phase: GuidedPhase.setRunning,
              now: _now(),
              stepId: step.stepId,
              setPosition: set.position,
            );
      });

  /// Dokončení sady: existující zápis skutečností + completion; má-li sada
  /// pauzu, začne odpočet REST_AFTER_SET, jinak fáze končí.
  Future<RecordPerformanceResult?> completeSet(
    String sessionId,
    GuidedStep step,
    GuidedSet set, {
    int? actualRepetitions,
    double? actualWeightKg,
    int? actualDurationSeconds,
  }) async {
    RecordPerformanceResult? outcome;
    await _run(sessionId, () async {
      final id = set.setPerformanceId;
      if (id == null) {
        return const GuidedSessionSaved();
      }
      final repo = ref.read(workoutPerformanceRepositoryProvider);
      final now = _now();
      final recorded = await repo.recordSetActuals(
        setPerformanceId: id,
        actualRepetitions: actualRepetitions ?? set.plannedRepetitions,
        actualWeightKg: actualWeightKg ?? set.plannedWeightKg,
        actualDurationSeconds:
            actualDurationSeconds ?? set.plannedDurationSeconds,
        now: now,
      );
      if (recorded is! PerformanceSaved) {
        outcome = recorded;
        return const GuidedSessionSaved();
      }
      outcome = await repo.setSetCompletion(
        setPerformanceId: id,
        completed: true,
        now: now,
      );
      final rest = set.restAfterSeconds ?? 0;
      final guided = ref.read(guidedSessionRepositoryProvider);
      if (rest > 0) {
        return guided.startPhase(
          sessionId: sessionId,
          phase: GuidedPhase.restAfterSet,
          now: now,
          stepId: step.stepId,
          setPosition: set.position,
        );
      }
      return guided.clearPhase(sessionId: sessionId, now: now);
    });
    return outcome;
  }

  Future<void> uncompleteSet(String sessionId, GuidedSet set) =>
      _run(sessionId, () async {
        if (set.setPerformanceId != null) {
          await ref
              .read(workoutPerformanceRepositoryProvider)
              .setSetCompletion(
                setPerformanceId: set.setPerformanceId!,
                completed: false,
                now: _now(),
              );
        }
        return ref
            .read(guidedSessionRepositoryProvider)
            .clearPhase(sessionId: sessionId, now: _now());
      });

  Future<void> startRestStep(String sessionId, GuidedStep step) => _run(
    sessionId,
    () => ref
        .read(guidedSessionRepositoryProvider)
        .startPhase(
          sessionId: sessionId,
          phase: GuidedPhase.restStep,
          now: _now(),
          stepId: step.stepId,
        ),
  );

  /// Uživatelské potvrzení konce odpočtu / REST kroku (GSP-006).
  Future<void> finishPhase(String sessionId) => _run(
    sessionId,
    () => ref
        .read(guidedSessionRepositoryProvider)
        .clearPhase(sessionId: sessionId, now: _now()),
  );

  Future<void> skipStep(String sessionId, GuidedStep step) => _run(
    sessionId,
    () async {
      if (step.stepPerformanceId != null) {
        await ref
            .read(workoutPerformanceRepositoryProvider)
            .skipStep(stepPerformanceId: step.stepPerformanceId!, now: _now());
      }
      return ref
          .read(guidedSessionRepositoryProvider)
          .clearPhase(sessionId: sessionId, now: _now());
    },
  );

  Future<void> pause(String sessionId) => _run(
    sessionId,
    () => ref
        .read(guidedSessionRepositoryProvider)
        .pause(sessionId: sessionId, now: _now()),
  );

  Future<void> resume(String sessionId) => _run(
    sessionId,
    () => ref
        .read(guidedSessionRepositoryProvider)
        .resume(sessionId: sessionId, now: _now()),
  );

  DateTime _now() => ref.read(clockProvider)();

  Future<void> _run(
    String sessionId,
    Future<GuidedSessionResult> Function() action,
  ) async {
    if (state) {
      return;
    }
    state = true;
    try {
      await action();
    } finally {
      state = false;
      ref
        ..invalidate(guidedSessionRecordProvider(sessionId))
        ..invalidate(sessionTrackerProvider(sessionId));
    }
  }
}

final guidedSessionControllerProvider =
    NotifierProvider<GuidedSessionController, bool>(
      GuidedSessionController.new,
    );
