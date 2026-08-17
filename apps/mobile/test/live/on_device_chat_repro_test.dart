@Tags(['live'])
library;

/// On-device repro: stejné okno konverzace + kontext jako aplikace nad
/// vytaženou SQLite, reálné volání modelu (opt-in AIT_DB + AITRAINER_LIVE_SMOKE
/// + klíč z env) → raw do build/live-smoke, nikdy do repa ani logu klíč.

import 'dart:convert';
import 'dart:io';

import 'package:ai_trainer_mobile/core/database/app_database.dart';
import 'package:ai_trainer_mobile/core/database/database_provider.dart';
import 'package:ai_trainer_mobile/core/time/clock.dart';
import 'package:ai_trainer_mobile/features/ai/application/ai_providers.dart';
import 'package:ai_trainer_mobile/features/ai/domain/byok_key_store.dart';
import 'package:ai_trainer_mobile/features/chat/application/chat_providers.dart';
import 'package:ai_trainer_mobile/features/chat/data/chat_reply_validator.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _EnvKeyStore implements ByokKeyStore {
  @override
  Future<String?> read() async =>
      Platform.environment['AITRAINER_AI_ANTHROPIC_APIKEY'];
  @override
  Future<void> write(String key) async {}
  @override
  Future<void> clear() async {}
}

void main() {
  final dbPath = Platform.environment['AIT_DB'];
  final live = Platform.environment['AITRAINER_LIVE_SMOKE'] == '1';
  test(
    'repro on-device chat failure',
    () async {
      final path = dbPath!;
      final db = AppDatabase(NativeDatabase(File(path)));
      final now = DateTime.now();
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          byokKeyStoreProvider.overrideWithValue(_EnvKeyStore()),
          clockProvider.overrideWithValue(() => now),
        ],
      );
      addTearDown(container.dispose);
      final row = await db
          .customSelect(
            "SELECT id FROM local_chat_messages WHERE role='ASSISTANT' ORDER BY created_at DESC, position DESC LIMIT 1",
          )
          .getSingle();
      final assistantId = row.data['id'] as String;
      final window = await container
          .read(chatRepositoryProvider)
          .windowBefore(assistantId);
      final turns = [for (final m in window) chatTurnFor(m)];
      stdout.writeln('turns=${turns.length}');
      for (final t in turns) {
        final c = t.content;
        stdout.writeln(
          '[${t.role}] ${c.substring(0, c.length.clamp(0, 300)).replaceAll('\n', ' ')}',
        );
      }
      final context = await container
          .read(aiContextBuilderProvider)
          .buildPlanProposalContext(now: now);
      final payload = {...context.payload, 'today': formatLocalDate(now)};
      stdout.writeln('context=${jsonEncode(payload)}');
      final raw = await container
          .read(chatAiClientProvider)
          .chat(turns: turns, profileContext: payload);
      Directory('build/live-smoke').createSync(recursive: true);
      File('build/live-smoke/on-device-repro-raw.json').writeAsStringSync(raw);
      stdout.writeln('rawLength=${raw.length}');
      final reply = validateChatReply(raw);
      stdout.writeln('valid=${reply != null}');
      if (reply != null) {
        stdout.writeln(
          'replyLen=${reply.text.length} actions=${jsonEncode(reply.actions)}',
        );
      }
      stdout.writeln('RAW-START');
      for (var i = 0; i < raw.length; i += 800) {
        stdout.writeln(
          raw.substring(i, i + 800 < raw.length ? i + 800 : raw.length),
        );
      }
      stdout.writeln('RAW-END');
      await db.close();
    },
    timeout: const Timeout(Duration(minutes: 3)),
    skip: dbPath == null || !live
        ? 'opt-in: AIT_DB + AITRAINER_LIVE_SMOKE=1'
        : null,
  );
}
