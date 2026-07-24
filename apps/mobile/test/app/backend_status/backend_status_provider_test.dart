import 'package:ai_trainer_mobile/app/backend_status/backend_health_client.dart';
import 'package:ai_trainer_mobile/app/backend_status/backend_status_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fake client řízený testem: počítá volání a přepíná výsledky —
/// ověřuje i to, že nevzniká žádný automatický request loop.
class FakeBackendHealthClient implements BackendHealthClient {
  FakeBackendHealthClient(this.results);

  final List<Object> results;
  int callCount = 0;

  @override
  Future<BackendHealthStatus> checkHealth() async {
    final result = results[callCount.clamp(0, results.length - 1)];
    callCount += 1;
    if (result is BackendHealthStatus) {
      return result;
    }
    throw result as BackendHealthException;
  }
}

const readyStatus = BackendHealthStatus(
  service: 'ai-trainer-backend',
  version: '0.0.1-dev',
  ready: true,
);
const unreachable = BackendHealthException(
  BackendHealthFailureKind.unreachable,
);

void main() {
  ProviderContainer containerWith(BackendHealthClient client) {
    final container = ProviderContainer(
      overrides: [backendHealthClientProvider.overrideWithValue(client)],
    );
    addTearDown(container.dispose);
    // Aktivní subscription drží provider naživu po dobu testu
    // (Riverpod 3 auto-dispose bez posluchače).
    container.listen(backendStatusProvider, (_, _) {});
    return container;
  }

  test('loading -> success', () async {
    final client = FakeBackendHealthClient([readyStatus]);
    final container = containerWith(client);

    expect(container.read(backendStatusProvider), isA<AsyncLoading<Object?>>());
    final status = await container.read(backendStatusProvider.future);

    expect(status.ready, isTrue);
    expect(client.callCount, 1);
  });

  test('loading -> failure s bezpecnou vyjimkou', () async {
    final container = containerWith(FakeBackendHealthClient([unreachable]));

    await expectLater(
      container.read(backendStatusProvider.future),
      throwsA(isA<BackendHealthException>()),
    );
    expect(container.read(backendStatusProvider), isA<AsyncError<Object?>>());
  });

  test('retry po failure vede k novemu pokusu a uspechu', () async {
    final client = FakeBackendHealthClient([unreachable, readyStatus]);
    final container = containerWith(client);

    await expectLater(
      container.read(backendStatusProvider.future),
      throwsA(isA<BackendHealthException>()),
    );

    container.invalidate(backendStatusProvider);
    final status = await container.read(backendStatusProvider.future);

    expect(status.ready, isTrue);
    expect(client.callCount, 2);
  });

  test('bez retry probehne prave jeden request - zadny loop', () async {
    final client = FakeBackendHealthClient([readyStatus]);
    final container = containerWith(client);

    await container.read(backendStatusProvider.future);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    container.read(backendStatusProvider);

    expect(client.callCount, 1);
  });
}
