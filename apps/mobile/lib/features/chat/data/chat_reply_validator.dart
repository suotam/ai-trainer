import 'dart:convert';

/// Validovaná odpověď chatu (C48 §2): konverzační text + kanonické akce.
class ChatReply {
  const ChatReply({required this.text, this.actions = const []});

  final String text;
  final List<Map<String, Object?>> actions;
}

const int _maxReplyChars = 4000;
// CHA-004 (12; původně 5 — on-device nález 3d: celý profil v jedné zprávě).
const int _maxActions = 12;

const Set<String> _sportRoles = {
  'PRIMARY',
  'SECONDARY',
  'SUPPORTING',
  'RECREATIONAL',
  'OCCASIONAL',
  'SEASONAL',
};
const Set<String> _sportPriorities = {
  'CRITICAL',
  'HIGH',
  'MEDIUM',
  'LOW',
  'BACKGROUND',
};
const Set<String> _experienceLevels = {
  'BEGINNER',
  'NOVICE',
  'INTERMEDIATE',
  'ADVANCED',
  'EXPERT',
  'PROFESSIONAL',
  'UNKNOWN',
};
const Set<String> _environments = {'INDOOR', 'OUTDOOR', 'MIXED'};
const Set<String> _goalTypes = {
  'PERFORMANCE',
  'STRENGTH',
  'ENDURANCE',
  'HABIT',
  'EVENT_PREPARATION',
  'RETURN_TO_ACTIVITY',
  'MAINTENANCE',
  'QUALITATIVE',
};
const Set<String> _goalPriorities = {'PRIMARY', 'MAINTENANCE', 'DEFERRED'};
const Set<String> _horizons = {
  'IMMEDIATE',
  'SHORT_TERM',
  'MEDIUM_TERM',
  'LONG_TERM',
  'OPEN_ENDED',
};
const Set<String> _days = {'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'};
const Set<String> _levels = {'AVAILABLE', 'LIMITED', 'UNAVAILABLE'};
const Set<String> _partsOfDay = {'MORNING', 'AFTERNOON', 'EVENING'};

/// Deterministická validace `chat-action-schema-v1` (C48 §2/§3, CHA-003):
/// fence extrakce, striktní tvarová tabulka, kanonizace zahazuje neznámá
/// pole; nevalidní celek → `null` (nikdy oprava ani částečné přijetí).
ChatReply? validateChatReply(String raw) {
  final json = _extractJson(raw);
  if (json == null) {
    return null;
  }
  final Object? decoded;
  try {
    decoded = jsonDecode(json);
  } on FormatException {
    return null;
  }
  if (decoded is! Map<String, Object?>) {
    return null;
  }
  final reply = decoded['reply'];
  if (reply is! String ||
      reply.trim().isEmpty ||
      reply.length > _maxReplyChars) {
    return null;
  }
  final actionsNode = decoded['actions'];
  if (actionsNode == null) {
    return ChatReply(text: reply);
  }
  if (actionsNode is! List || actionsNode.length > _maxActions) {
    return null;
  }
  final actions = <Map<String, Object?>>[];
  var requestCount = 0;
  for (final node in actionsNode) {
    if (node is! Map<String, Object?>) {
      return null;
    }
    final canonical = _validateAction(node);
    if (canonical == null) {
      return null;
    }
    if (canonical['action'] == 'REQUEST_PLAN' ||
        canonical['action'] == 'REQUEST_ADJUSTMENT') {
      requestCount++;
    }
    actions.add(canonical);
  }
  // Nejvýše jedna REQUEST akce na odpověď (C49 CHP-002) — bounded práce.
  if (requestCount > 1) {
    return null;
  }
  return ChatReply(text: reply, actions: actions);
}

Map<String, Object?>? _validateAction(Map<String, Object?> node) =>
    switch (node['action']) {
      'UPSERT_SPORT' => _validateUpsertSport(node),
      'ADD_GOAL' => _validateAddGoal(node),
      'SET_AVAILABILITY' => _validateSetAvailability(node),
      'ADD_CONSTRAINT' => _validateAddConstraint(node),
      // REQUEST akce (C49 §2): bez polí — spouští existující pipeline.
      'REQUEST_PLAN' => const {'action': 'REQUEST_PLAN'},
      'REQUEST_ADJUSTMENT' => const {'action': 'REQUEST_ADJUSTMENT'},
      _ => null,
    };

Map<String, Object?>? _validateUpsertSport(Map<String, Object?> node) {
  final sportCode = _optionalText(node, 'sportCode', 60);
  final customName = _optionalText(node, 'customName', 120);
  // sportCode XOR customName (C17 vzor).
  if ((sportCode == null) == (customName == null)) {
    return null;
  }
  final role = _requiredEnum(node, 'role', _sportRoles);
  final priority = _requiredEnum(node, 'priority', _sportPriorities);
  if (role == null || priority == null) {
    return null;
  }
  final experience = node.containsKey('experienceLevel')
      ? _requiredEnum(node, 'experienceLevel', _experienceLevels)
      : null;
  if (node.containsKey('experienceLevel') && experience == null) {
    return null;
  }
  final frequency = _optionalInt(node, 'frequencyPerWeek', 0, 21);
  if (node.containsKey('frequencyPerWeek') && frequency == null) {
    return null;
  }
  final duration = _optionalInt(node, 'typicalDurationMinutes', 1, 600);
  if (node.containsKey('typicalDurationMinutes') && duration == null) {
    return null;
  }
  final environment = node.containsKey('environment')
      ? _requiredEnum(node, 'environment', _environments)
      : null;
  if (node.containsKey('environment') && environment == null) {
    return null;
  }
  return {
    'action': 'UPSERT_SPORT',
    'sportCode': ?sportCode,
    'customName': ?customName,
    'role': role,
    'priority': priority,
    'experienceLevel': ?experience,
    'frequencyPerWeek': ?frequency,
    'typicalDurationMinutes': ?duration,
    'environment': ?environment,
  };
}

Map<String, Object?>? _validateAddGoal(Map<String, Object?> node) {
  final title = _requiredText(node, 'title', 120);
  final goalType = _requiredEnum(node, 'goalType', _goalTypes);
  final priority = _requiredEnum(node, 'priority', _goalPriorities);
  if (title == null || goalType == null || priority == null) {
    return null;
  }
  final horizon = node.containsKey('horizon')
      ? _requiredEnum(node, 'horizon', _horizons)
      : null;
  if (node.containsKey('horizon') && horizon == null) {
    return null;
  }
  final targetDate = _optionalText(node, 'targetLocalDate', 10);
  if (node.containsKey('targetLocalDate')) {
    if (targetDate == null || DateTime.tryParse(targetDate) == null) {
      return null;
    }
  }
  return {
    'action': 'ADD_GOAL',
    'title': title,
    'goalType': goalType,
    'priority': priority,
    'horizon': ?horizon,
    'targetLocalDate': ?targetDate,
  };
}

Map<String, Object?>? _validateSetAvailability(Map<String, Object?> node) {
  final day = _requiredEnum(node, 'dayOfWeek', _days);
  final level = _requiredEnum(node, 'level', _levels);
  if (day == null || level == null) {
    return null;
  }
  final budget = _optionalInt(node, 'budgetMinutes', 1, 960);
  if (node.containsKey('budgetMinutes') && budget == null) {
    return null;
  }
  final part = node.containsKey('preferredPartOfDay')
      ? _requiredEnum(node, 'preferredPartOfDay', _partsOfDay)
      : null;
  if (node.containsKey('preferredPartOfDay') && part == null) {
    return null;
  }
  return {
    'action': 'SET_AVAILABILITY',
    'dayOfWeek': day,
    'level': level,
    'budgetMinutes': ?budget,
    'preferredPartOfDay': ?part,
  };
}

Map<String, Object?>? _validateAddConstraint(Map<String, Object?> node) {
  final title = _requiredText(node, 'title', 120);
  if (title == null) {
    return null;
  }
  return {'action': 'ADD_CONSTRAINT', 'title': title};
}

String? _requiredText(Map<String, Object?> node, String key, int maxLength) {
  final value = node[key];
  if (value is! String) {
    return null;
  }
  final trimmed = value.trim();
  if (trimmed.isEmpty || trimmed.length > maxLength) {
    return null;
  }
  return trimmed;
}

String? _optionalText(Map<String, Object?> node, String key, int maxLength) {
  if (!node.containsKey(key) || node[key] == null) {
    return null;
  }
  return _requiredText(node, key, maxLength);
}

String? _requiredEnum(
  Map<String, Object?> node,
  String key,
  Set<String> allowed,
) {
  final value = node[key];
  if (value is! String || !allowed.contains(value)) {
    return null;
  }
  return value;
}

int? _optionalInt(Map<String, Object?> node, String key, int min, int max) {
  if (!node.containsKey(key) || node[key] == null) {
    return null;
  }
  final value = node[key];
  if (value is! int || value < min || value > max) {
    return null;
  }
  return value;
}

String? _extractJson(String raw) {
  final trimmed = raw.trim();
  final fence = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```').firstMatch(trimmed);
  if (fence != null) {
    return fence.group(1);
  }
  final start = trimmed.indexOf('{');
  final end = trimmed.lastIndexOf('}');
  if (start < 0 || end <= start) {
    return null;
  }
  return trimmed.substring(start, end + 1);
}
