import 'dart:async';

import 'package:ai_trainer_mobile/app/backend_status/backend_health_client.dart';
import 'package:ai_trainer_mobile/app/backend_status/backend_status_providers.dart';
import 'package:ai_trainer_mobile/app/backend_status/backend_status_section.dart';
import 'package:ai_trainer_mobile/app/bootstrap/ai_trainer_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class ScriptedBackendHealthClient implements BackendHealthClient {
  ScriptedBackendHealthClient(this.script);

  final List<Future<BackendHealthStatus> Function()> script;
  int callCount = 0;

  @override
  Future<BackendHealthStatus> checkHealth() {
    final step = script[callCount.clamp(0, script.length - 1)];
    callCount += 1;
    return step();
  }
}

const readyStatus = BackendHealthStatus(
  service: 'ai-trainer-backend',
  version: '0.0.1-dev',
  ready: true,
);

Widget appWith(BackendHealthClient client) => ProviderScope(
  overrides: [backendHealthClientProvider.overrideWithValue(client)],
  child: const AiTrainerApp(),
);

void main() {
  testWidgets('loading stav ma stabilni klic a UI nezamrza', (tester) async {
    final never = Completer<BackendHealthStatus>();
    await tester.pumpWidget(
      appWith(ScriptedBackendHealthClient([() => never.future])),
    );
    await tester.pump();

    expect(find.byKey(BackendStatusSection.loadingKey), findsOneWidget);

    // Úklid: dokončit future, aby test neskončil s pending timerem.
    never.complete(readyStatus);
    await tester.pumpAndSettle();
  });

  testWidgets('success stav zobrazi ready zpravu se service metadaty', (
    tester,
  ) async {
    await tester.pumpWidget(
      appWith(ScriptedBackendHealthClient([() async => readyStatus])),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(BackendStatusSection.successKey), findsOneWidget);
    expect(find.textContaining('ai-trainer-backend'), findsOneWidget);
  });

  testWidgets('not-ready stav se nevydava za uspech a nabizi retry', (
    tester,
  ) async {
    await tester.pumpWidget(
      appWith(
        ScriptedBackendHealthClient([
          () async => const BackendHealthStatus(
            service: 'ai-trainer-backend',
            version: '0.0.1-dev',
            ready: false,
          ),
        ]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(BackendStatusSection.notReadyKey), findsOneWidget);
    expect(find.byKey(BackendStatusSection.successKey), findsNothing);
    expect(find.byKey(BackendStatusSection.retryKey), findsOneWidget);
  });

  testWidgets('failure stav zobrazi bezpecnou zpravu bez raw vyjimky', (
    tester,
  ) async {
    await tester.pumpWidget(
      appWith(
        ScriptedBackendHealthClient([
          () async => throw const BackendHealthException(
            BackendHealthFailureKind.unreachable,
          ),
        ]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(BackendStatusSection.failureKey), findsOneWidget);
    expect(find.byKey(BackendStatusSection.retryKey), findsOneWidget);
    expect(find.textContaining('Exception'), findsNothing);
    expect(find.textContaining('BackendHealth'), findsNothing);
  });

  testWidgets('retry po failure znovu zavola client a zobrazi success', (
    tester,
  ) async {
    final client = ScriptedBackendHealthClient([
      () async => throw const BackendHealthException(
        BackendHealthFailureKind.unreachable,
      ),
      () async => readyStatus,
    ]);
    await tester.pumpWidget(appWith(client));
    await tester.pumpAndSettle();
    expect(find.byKey(BackendStatusSection.failureKey), findsOneWidget);

    await tester.tap(find.byKey(BackendStatusSection.retryKey));
    await tester.pumpAndSettle();

    expect(find.byKey(BackendStatusSection.successKey), findsOneWidget);
    expect(client.callCount, 2);
  });
}
