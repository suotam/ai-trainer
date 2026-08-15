import 'package:ai_trainer_mobile/core/database/tables/chat_tables.dart';
import 'package:ai_trainer_mobile/features/chat/data/drift_chat_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/workout_test_scope.dart';

/// R7-02 testy persistence konverzací (C47 §2/§3): lifecycle a řazení
/// (CHC-011), okno SENT/COMPLETED (CHC-006), osiřelé PENDING → FAILED
/// (CHC-004), retry bez duplicit (CHC-005), nová konverzace (CHC-012),
/// device-local bez owner/sync sloupců (CHC-001).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final now = DateTime.utc(2026, 8, 15, 12);

  test('výměna zpráv: user SENT + assistant PENDING → COMPLETED; řazení '
      'drží position (CHC-003/011)', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final repo = DriftChatRepository(db);
    var seq = 0;
    String nextId() => 'm-${seq++}';

    final conversation = await repo.openActiveConversation(
      newId: nextId,
      now: now,
    );
    final assistant1 = await repo.appendExchange(
      conversation,
      userText: 'Ahoj, jak mám trénovat?',
      newId: nextId,
      now: now,
    );
    await repo.completeAssistant(
      assistant1,
      content: 'Začni zlehka.',
      now: now,
    );
    final assistant2 = await repo.appendExchange(
      conversation,
      userText: 'A co zítra?',
      newId: nextId,
      now: now,
    );

    final messages = await repo.messages(conversation);
    expect(messages, hasLength(4));
    expect(messages[0].role, chatRoleUser);
    expect(messages[0].status, chatStatusSent);
    expect(messages[1].id, assistant1);
    expect(messages[1].status, chatStatusCompleted);
    expect(messages[1].content, 'Začni zlehka.');
    expect(messages[3].id, assistant2);
    expect(messages[3].isPending, isTrue);
    expect([for (final m in messages) m.position], [0, 1, 2, 3]);
  });

  test('okno do modelu: jen SENT/COMPLETED před kotvou, posledních N '
      '(CHC-006)', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final repo = DriftChatRepository(db);
    var seq = 0;
    String nextId() => 'm-${seq++}';
    final conversation = await repo.openActiveConversation(
      newId: nextId,
      now: now,
    );

    // Selhaná výměna — do okna nesmí (CHC-006).
    final failed = await repo.appendExchange(
      conversation,
      userText: 'první',
      newId: nextId,
      now: now,
    );
    await repo.failAssistant(failed, errorKind: 'network', now: now);
    final completed = await repo.appendExchange(
      conversation,
      userText: 'druhá',
      newId: nextId,
      now: now,
    );
    await repo.completeAssistant(completed, content: 'odpověď', now: now);
    final anchor = await repo.appendExchange(
      conversation,
      userText: 'třetí',
      newId: nextId,
      now: now,
    );

    final window = await repo.windowBefore(anchor);
    expect(
      [for (final m in window) m.content],
      ['první', 'druhá', 'odpověď', 'třetí'],
    );
    expect(window.any((m) => m.isFailed || m.isPending), isFalse);

    // Limit okna bere poslední zprávy (CHC-007 deterministické zkrácení).
    final small = await repo.windowBefore(anchor, limit: 2);
    expect([for (final m in small) m.content], ['odpověď', 'třetí']);
  });

  test('osiřelé PENDING se při otevření překlopí na FAILED s retry cestou '
      '(CHC-004/005)', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final repo = DriftChatRepository(db);
    var seq = 0;
    String nextId() => 'm-${seq++}';
    final conversation = await repo.openActiveConversation(
      newId: nextId,
      now: now,
    );
    final orphan = await repo.appendExchange(
      conversation,
      userText: 'zpráva před pádem',
      newId: nextId,
      now: now,
    );

    // „Restart": nové otevření překlopí PENDING → FAILED (CHC-004).
    final reopened = await repo.openActiveConversation(newId: nextId, now: now);
    expect(reopened, conversation);
    final afterRestart = await repo.messages(conversation);
    final assistant = afterRestart.singleWhere((m) => m.id == orphan);
    expect(assistant.isFailed, isTrue);
    expect(assistant.errorKind, 'interrupted');

    // Explicitní retry nad týmž řádkem — žádná duplicita (CHC-005).
    await repo.markPendingForRetry(orphan, now: now);
    final retried = await repo.messages(conversation);
    expect(retried.singleWhere((m) => m.id == orphan).isPending, isTrue);
    expect(retried, hasLength(2));
  });

  test('nová konverzace: starší zůstává, aktivní je nejnovější (CHC-012); '
      'tabulky jsou device-local bez owner/sync sloupců (CHC-001)', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final repo = DriftChatRepository(db);
    var seq = 0;
    String nextId() => 'm-${seq++}';
    final first = await repo.openActiveConversation(newId: nextId, now: now);
    await repo.appendExchange(
      first,
      userText: 'stará zpráva',
      newId: nextId,
      now: now,
    );

    final second = await repo.startNewConversation(
      newId: nextId,
      now: now.add(const Duration(minutes: 1)),
    );
    final active = await repo.openActiveConversation(
      newId: nextId,
      now: now.add(const Duration(minutes: 2)),
    );
    expect(active, second);
    expect(await repo.messages(second), isEmpty);
    expect(await repo.messages(first), hasLength(2));

    // Device-local artefakt: žádné owner/sync sloupce (CHC-001).
    final columns = await db
        .customSelect('PRAGMA table_info(local_chat_messages)')
        .get();
    final names = [for (final c in columns) c.data['name']];
    expect(names.contains('owner_id'), isFalse);
    expect(names.contains('sync_state'), isFalse);
  });
}
