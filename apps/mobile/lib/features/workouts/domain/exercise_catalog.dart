/// Katalog cviků (C51) — uzavřený, stabilní doménový slovník (C17 vzor).
///
/// In-app statická data (EXC-003): kódy se nikdy nemění ani nerecyklují
/// (EXC-002); odstranění = `deprecated`. Názvy, popis provedení a cue jsou
/// l10n prezentační vrstva klíčovaná kódem (EXC-006/007).
library;

/// Kategorie cviku (C51 §4.1).
enum ExerciseCategory {
  warmUp('WARM_UP'),
  mobility('MOBILITY'),
  strengthPush('STRENGTH_PUSH'),
  strengthPull('STRENGTH_PULL'),
  strengthLegs('STRENGTH_LEGS'),
  core('CORE'),
  climbing('CLIMBING'),
  endurance('ENDURANCE'),
  recovery('RECOVERY');

  const ExerciseCategory(this.code);
  final String code;
}

/// Výchozí předpis (C51 §4): kroky/set plany ho mohou přepsat (EXC-010).
enum ExercisePrescription {
  setRep('SET_REP'),
  duration('DURATION');

  const ExercisePrescription(this.code);
  final String code;
}

/// Hlavní zatížení (C51 §4.3) — informativní.
enum MuscleGroup {
  fingersForearms('FINGERS_FOREARMS'),
  shoulders('SHOULDERS'),
  chest('CHEST'),
  triceps('TRICEPS'),
  biceps('BICEPS'),
  upperBack('UPPER_BACK'),
  lats('LATS'),
  core('CORE'),
  lowerBack('LOWER_BACK'),
  glutes('GLUTES'),
  quads('QUADS'),
  hamstrings('HAMSTRINGS'),
  calves('CALVES'),
  hips('HIPS'),
  feetAnkles('FEET_ANKLES'),
  fullBody('FULL_BODY'),
  cardio('CARDIO');

  const MuscleGroup(this.code);
  final String code;
}

/// Položka katalogu (C51 §4). `equipment` = kódy katalogu vybavení C19
/// (vč. aditivního rozšíření C51 §4.2); prázdné = jen tělo.
class ExerciseCatalogEntry {
  const ExerciseCatalogEntry(
    this.code,
    this.category,
    this.defaultPrescription,
    this.primaryMuscles, {
    this.equipment = const [],
    this.bilateral = true,
    this.deprecated = false,
  });

  final String code;
  final ExerciseCategory category;
  final ExercisePrescription defaultPrescription;
  final List<MuscleGroup> primaryMuscles;
  final List<String> equipment;

  /// `false` = provádí se na každou stranu zvlášť.
  final bool bilateral;
  final bool deprecated;
}

const _w = ExerciseCategory.warmUp;
const _m = ExerciseCategory.mobility;
const _push = ExerciseCategory.strengthPush;
const _pull = ExerciseCategory.strengthPull;
const _legs = ExerciseCategory.strengthLegs;
const _core = ExerciseCategory.core;
const _climb = ExerciseCategory.climbing;
const _endu = ExerciseCategory.endurance;
const _rec = ExerciseCategory.recovery;
const _rep = ExercisePrescription.setRep;
const _dur = ExercisePrescription.duration;

/// Kanonický katalog P0 (C51 §5) — 112 položek. Pořadí = pořadí v kontraktu.
const List<ExerciseCatalogEntry> exerciseCatalog = [
  // 5.1 Rozcvička
  ExerciseCatalogEntry('JUMPING_JACKS', _w, _dur, [
    MuscleGroup.cardio,
    MuscleGroup.fullBody,
  ]),
  ExerciseCatalogEntry('HIGH_KNEES', _w, _dur, [
    MuscleGroup.cardio,
    MuscleGroup.hips,
  ]),
  ExerciseCatalogEntry('BUTT_KICKS', _w, _dur, [
    MuscleGroup.cardio,
    MuscleGroup.hamstrings,
  ]),
  ExerciseCatalogEntry(
    'JUMP_ROPE',
    _w,
    _dur,
    [MuscleGroup.cardio, MuscleGroup.calves],
    equipment: ['JUMP_ROPE'],
  ),
  ExerciseCatalogEntry('ARM_CIRCLES', _w, _dur, [MuscleGroup.shoulders]),
  ExerciseCatalogEntry(
    'SHOULDER_DISLOCATES',
    _w,
    _rep,
    [MuscleGroup.shoulders, MuscleGroup.upperBack],
    equipment: ['RESISTANCE_BANDS'],
  ),
  ExerciseCatalogEntry(
    'BAND_PULL_APART',
    _w,
    _rep,
    [MuscleGroup.upperBack, MuscleGroup.shoulders],
    equipment: ['RESISTANCE_BANDS'],
  ),
  ExerciseCatalogEntry('HIP_CIRCLES', _w, _rep, [MuscleGroup.hips]),
  ExerciseCatalogEntry('LEG_SWINGS_FRONT', _w, _rep, [
    MuscleGroup.hips,
    MuscleGroup.hamstrings,
  ], bilateral: false),
  ExerciseCatalogEntry('LEG_SWINGS_SIDE', _w, _rep, [
    MuscleGroup.hips,
  ], bilateral: false),
  ExerciseCatalogEntry('WRIST_CIRCLES', _w, _dur, [
    MuscleGroup.fingersForearms,
  ]),
  ExerciseCatalogEntry('FINGER_FLEXOR_STRETCH', _w, _dur, [
    MuscleGroup.fingersForearms,
  ]),
  ExerciseCatalogEntry(
    'FINGER_EXTENSOR_BAND',
    _w,
    _rep,
    [MuscleGroup.fingersForearms],
    equipment: ['RESISTANCE_BANDS'],
  ),
  ExerciseCatalogEntry(
    'SCAPULAR_PULL_UP',
    _w,
    _rep,
    [MuscleGroup.upperBack, MuscleGroup.lats],
    equipment: ['PULL_UP_BAR'],
  ),
  ExerciseCatalogEntry(
    'DEAD_HANG',
    _w,
    _dur,
    [MuscleGroup.fingersForearms, MuscleGroup.shoulders],
    equipment: ['PULL_UP_BAR'],
  ),
  ExerciseCatalogEntry('INCHWORM', _w, _rep, [
    MuscleGroup.fullBody,
    MuscleGroup.hamstrings,
  ]),
  ExerciseCatalogEntry(
    'EASY_TRAVERSE',
    _w,
    _dur,
    [MuscleGroup.fullBody, MuscleGroup.fingersForearms],
    equipment: ['CLIMBING_WALL_ACCESS'],
  ),
  // 5.2 Mobilita
  ExerciseCatalogEntry(
    'CAT_COW',
    _m,
    _rep,
    [MuscleGroup.lowerBack, MuscleGroup.core],
    equipment: ['YOGA_MAT'],
  ),
  ExerciseCatalogEntry(
    'THORACIC_ROTATION',
    _m,
    _rep,
    [MuscleGroup.upperBack],
    equipment: ['YOGA_MAT'],
    bilateral: false,
  ),
  ExerciseCatalogEntry('WORLDS_GREATEST_STRETCH', _m, _rep, [
    MuscleGroup.hips,
    MuscleGroup.upperBack,
  ], bilateral: false),
  ExerciseCatalogEntry('DEEP_SQUAT_HOLD', _m, _dur, [
    MuscleGroup.hips,
    MuscleGroup.calves,
  ]),
  ExerciseCatalogEntry(
    'HIP_FLEXOR_STRETCH',
    _m,
    _dur,
    [MuscleGroup.hips],
    equipment: ['YOGA_MAT'],
    bilateral: false,
  ),
  ExerciseCatalogEntry(
    'PIGEON_STRETCH',
    _m,
    _dur,
    [MuscleGroup.glutes, MuscleGroup.hips],
    equipment: ['YOGA_MAT'],
    bilateral: false,
  ),
  ExerciseCatalogEntry('HAMSTRING_STRETCH', _m, _dur, [
    MuscleGroup.hamstrings,
  ], bilateral: false),
  ExerciseCatalogEntry('COUCH_STRETCH', _m, _dur, [
    MuscleGroup.quads,
    MuscleGroup.hips,
  ], bilateral: false),
  ExerciseCatalogEntry(
    'CHILD_POSE',
    _m,
    _dur,
    [MuscleGroup.lowerBack, MuscleGroup.lats],
    equipment: ['YOGA_MAT'],
  ),
  ExerciseCatalogEntry(
    'DOWNWARD_DOG',
    _m,
    _dur,
    [MuscleGroup.hamstrings, MuscleGroup.calves, MuscleGroup.shoulders],
    equipment: ['YOGA_MAT'],
  ),
  ExerciseCatalogEntry(
    'COBRA',
    _m,
    _dur,
    [MuscleGroup.core, MuscleGroup.lowerBack],
    equipment: ['YOGA_MAT'],
  ),
  ExerciseCatalogEntry('ANKLE_CIRCLES', _m, _rep, [
    MuscleGroup.feetAnkles,
  ], bilateral: false),
  ExerciseCatalogEntry('CALF_RAISE', _m, _rep, [MuscleGroup.calves]),
  ExerciseCatalogEntry('SINGLE_LEG_BALANCE', _m, _dur, [
    MuscleGroup.feetAnkles,
    MuscleGroup.hips,
  ], bilateral: false),
  ExerciseCatalogEntry('SHORT_FOOT', _m, _rep, [
    MuscleGroup.feetAnkles,
  ], bilateral: false),
  ExerciseCatalogEntry('TOWEL_SCRUNCH', _m, _rep, [
    MuscleGroup.feetAnkles,
  ], bilateral: false),
  ExerciseCatalogEntry('WRIST_FLEXOR_STRETCH', _m, _dur, [
    MuscleGroup.fingersForearms,
  ]),
  ExerciseCatalogEntry('SHOULDER_CARS', _m, _rep, [
    MuscleGroup.shoulders,
  ], bilateral: false),
  ExerciseCatalogEntry('HIP_CARS', _m, _rep, [
    MuscleGroup.hips,
  ], bilateral: false),
  // 5.3 Síla — tlaky
  ExerciseCatalogEntry('PUSH_UP', _push, _rep, [
    MuscleGroup.chest,
    MuscleGroup.triceps,
    MuscleGroup.shoulders,
  ]),
  ExerciseCatalogEntry('INCLINE_PUSH_UP', _push, _rep, [
    MuscleGroup.chest,
    MuscleGroup.triceps,
  ]),
  ExerciseCatalogEntry('DIAMOND_PUSH_UP', _push, _rep, [
    MuscleGroup.triceps,
    MuscleGroup.chest,
  ]),
  ExerciseCatalogEntry('PIKE_PUSH_UP', _push, _rep, [
    MuscleGroup.shoulders,
    MuscleGroup.triceps,
  ]),
  ExerciseCatalogEntry(
    'RING_PUSH_UP',
    _push,
    _rep,
    [MuscleGroup.chest, MuscleGroup.triceps, MuscleGroup.core],
    equipment: ['GYMNASTIC_RINGS'],
  ),
  ExerciseCatalogEntry(
    'RING_DIP',
    _push,
    _rep,
    [MuscleGroup.chest, MuscleGroup.triceps, MuscleGroup.shoulders],
    equipment: ['GYMNASTIC_RINGS'],
  ),
  ExerciseCatalogEntry(
    'RING_SUPPORT_HOLD',
    _push,
    _dur,
    [MuscleGroup.shoulders, MuscleGroup.triceps, MuscleGroup.core],
    equipment: ['GYMNASTIC_RINGS'],
  ),
  ExerciseCatalogEntry(
    'TRX_CHEST_PRESS',
    _push,
    _rep,
    [MuscleGroup.chest, MuscleGroup.triceps],
    equipment: ['SUSPENSION_TRAINER'],
  ),
  ExerciseCatalogEntry(
    'TRX_TRICEPS_EXTENSION',
    _push,
    _rep,
    [MuscleGroup.triceps],
    equipment: ['SUSPENSION_TRAINER'],
  ),
  ExerciseCatalogEntry(
    'DUMBBELL_BENCH_PRESS',
    _push,
    _rep,
    [MuscleGroup.chest, MuscleGroup.triceps],
    equipment: ['DUMBBELLS', 'BENCH'],
  ),
  ExerciseCatalogEntry(
    'OVERHEAD_PRESS',
    _push,
    _rep,
    [MuscleGroup.shoulders, MuscleGroup.triceps],
    equipment: ['DUMBBELLS'],
  ),
  ExerciseCatalogEntry(
    'BENCH_PRESS',
    _push,
    _rep,
    [MuscleGroup.chest, MuscleGroup.triceps],
    equipment: ['BARBELL', 'BENCH'],
  ),
  // 5.4 Síla — tahy
  ExerciseCatalogEntry(
    'PULL_UP',
    _pull,
    _rep,
    [MuscleGroup.lats, MuscleGroup.biceps, MuscleGroup.upperBack],
    equipment: ['PULL_UP_BAR'],
  ),
  ExerciseCatalogEntry(
    'CHIN_UP',
    _pull,
    _rep,
    [MuscleGroup.biceps, MuscleGroup.lats],
    equipment: ['PULL_UP_BAR'],
  ),
  ExerciseCatalogEntry(
    'NEGATIVE_PULL_UP',
    _pull,
    _rep,
    [MuscleGroup.lats, MuscleGroup.biceps],
    equipment: ['PULL_UP_BAR'],
  ),
  ExerciseCatalogEntry(
    'RING_ROW',
    _pull,
    _rep,
    [MuscleGroup.upperBack, MuscleGroup.biceps],
    equipment: ['GYMNASTIC_RINGS'],
  ),
  ExerciseCatalogEntry(
    'TRX_ROW',
    _pull,
    _rep,
    [MuscleGroup.upperBack, MuscleGroup.biceps],
    equipment: ['SUSPENSION_TRAINER'],
  ),
  ExerciseCatalogEntry(
    'TRX_Y_RAISE',
    _pull,
    _rep,
    [MuscleGroup.shoulders, MuscleGroup.upperBack],
    equipment: ['SUSPENSION_TRAINER'],
  ),
  ExerciseCatalogEntry(
    'FACE_PULL_BAND',
    _pull,
    _rep,
    [MuscleGroup.upperBack, MuscleGroup.shoulders],
    equipment: ['RESISTANCE_BANDS'],
  ),
  ExerciseCatalogEntry(
    'EXTERNAL_ROTATION_BAND',
    _pull,
    _rep,
    [MuscleGroup.shoulders],
    equipment: ['RESISTANCE_BANDS'],
    bilateral: false,
  ),
  ExerciseCatalogEntry(
    'DUMBBELL_ROW',
    _pull,
    _rep,
    [MuscleGroup.lats, MuscleGroup.upperBack],
    equipment: ['DUMBBELLS'],
    bilateral: false,
  ),
  ExerciseCatalogEntry(
    'KETTLEBELL_SWING',
    _pull,
    _rep,
    [MuscleGroup.glutes, MuscleGroup.hamstrings, MuscleGroup.core],
    equipment: ['KETTLEBELL'],
  ),
  ExerciseCatalogEntry(
    'DEADLIFT',
    _pull,
    _rep,
    [MuscleGroup.hamstrings, MuscleGroup.glutes, MuscleGroup.lowerBack],
    equipment: ['BARBELL'],
  ),
  ExerciseCatalogEntry(
    'ROMANIAN_DEADLIFT',
    _pull,
    _rep,
    [MuscleGroup.hamstrings, MuscleGroup.glutes],
    equipment: ['DUMBBELLS'],
  ),
  // 5.5 Síla — nohy
  ExerciseCatalogEntry('BODYWEIGHT_SQUAT', _legs, _rep, [
    MuscleGroup.quads,
    MuscleGroup.glutes,
  ]),
  ExerciseCatalogEntry(
    'GOBLET_SQUAT',
    _legs,
    _rep,
    [MuscleGroup.quads, MuscleGroup.glutes, MuscleGroup.core],
    equipment: ['KETTLEBELL'],
  ),
  ExerciseCatalogEntry('SPLIT_SQUAT', _legs, _rep, [
    MuscleGroup.quads,
    MuscleGroup.glutes,
  ], bilateral: false),
  ExerciseCatalogEntry(
    'BULGARIAN_SPLIT_SQUAT',
    _legs,
    _rep,
    [MuscleGroup.quads, MuscleGroup.glutes],
    equipment: ['BENCH'],
    bilateral: false,
  ),
  ExerciseCatalogEntry('REVERSE_LUNGE', _legs, _rep, [
    MuscleGroup.quads,
    MuscleGroup.glutes,
  ], bilateral: false),
  ExerciseCatalogEntry('LATERAL_LUNGE', _legs, _rep, [
    MuscleGroup.hips,
    MuscleGroup.quads,
  ], bilateral: false),
  ExerciseCatalogEntry(
    'STEP_UP',
    _legs,
    _rep,
    [MuscleGroup.quads, MuscleGroup.glutes],
    equipment: ['STEP_BOX'],
    bilateral: false,
  ),
  ExerciseCatalogEntry(
    'PISTOL_SQUAT_ASSISTED',
    _legs,
    _rep,
    [MuscleGroup.quads, MuscleGroup.glutes, MuscleGroup.feetAnkles],
    equipment: ['SUSPENSION_TRAINER'],
    bilateral: false,
  ),
  ExerciseCatalogEntry(
    'GLUTE_BRIDGE',
    _legs,
    _rep,
    [MuscleGroup.glutes, MuscleGroup.hamstrings],
    equipment: ['YOGA_MAT'],
  ),
  ExerciseCatalogEntry(
    'SINGLE_LEG_GLUTE_BRIDGE',
    _legs,
    _rep,
    [MuscleGroup.glutes, MuscleGroup.hamstrings],
    equipment: ['YOGA_MAT'],
    bilateral: false,
  ),
  ExerciseCatalogEntry(
    'HIP_THRUST',
    _legs,
    _rep,
    [MuscleGroup.glutes],
    equipment: ['BENCH'],
  ),
  ExerciseCatalogEntry('NORDIC_CURL_ASSISTED', _legs, _rep, [
    MuscleGroup.hamstrings,
  ]),
  ExerciseCatalogEntry(
    'BACK_SQUAT',
    _legs,
    _rep,
    [MuscleGroup.quads, MuscleGroup.glutes],
    equipment: ['BARBELL'],
  ),
  ExerciseCatalogEntry(
    'SINGLE_LEG_CALF_RAISE',
    _legs,
    _rep,
    [MuscleGroup.calves],
    equipment: ['STEP_BOX'],
    bilateral: false,
  ),
  // 5.6 Střed těla
  ExerciseCatalogEntry(
    'PLANK',
    _core,
    _dur,
    [MuscleGroup.core],
    equipment: ['YOGA_MAT'],
  ),
  ExerciseCatalogEntry(
    'SIDE_PLANK',
    _core,
    _dur,
    [MuscleGroup.core],
    equipment: ['YOGA_MAT'],
    bilateral: false,
  ),
  ExerciseCatalogEntry(
    'HOLLOW_HOLD',
    _core,
    _dur,
    [MuscleGroup.core],
    equipment: ['YOGA_MAT'],
  ),
  ExerciseCatalogEntry(
    'SUPERMAN_HOLD',
    _core,
    _dur,
    [MuscleGroup.lowerBack, MuscleGroup.glutes],
    equipment: ['YOGA_MAT'],
  ),
  ExerciseCatalogEntry(
    'DEAD_BUG',
    _core,
    _rep,
    [MuscleGroup.core],
    equipment: ['YOGA_MAT'],
  ),
  ExerciseCatalogEntry(
    'BIRD_DOG',
    _core,
    _rep,
    [MuscleGroup.core, MuscleGroup.lowerBack],
    equipment: ['YOGA_MAT'],
    bilateral: false,
  ),
  ExerciseCatalogEntry(
    'HANGING_KNEE_RAISE',
    _core,
    _rep,
    [MuscleGroup.core, MuscleGroup.hips],
    equipment: ['PULL_UP_BAR'],
  ),
  ExerciseCatalogEntry(
    'HANGING_LEG_RAISE',
    _core,
    _rep,
    [MuscleGroup.core, MuscleGroup.hips],
    equipment: ['PULL_UP_BAR'],
  ),
  ExerciseCatalogEntry('L_SIT', _core, _dur, [
    MuscleGroup.core,
    MuscleGroup.hips,
  ]),
  ExerciseCatalogEntry('MOUNTAIN_CLIMBER', _core, _dur, [
    MuscleGroup.core,
    MuscleGroup.cardio,
  ]),
  ExerciseCatalogEntry(
    'RING_FALLOUT',
    _core,
    _rep,
    [MuscleGroup.core, MuscleGroup.lats],
    equipment: ['GYMNASTIC_RINGS'],
  ),
  ExerciseCatalogEntry(
    'TRX_PIKE',
    _core,
    _rep,
    [MuscleGroup.core, MuscleGroup.shoulders],
    equipment: ['SUSPENSION_TRAINER'],
  ),
  // 5.7 Lezecké
  ExerciseCatalogEntry(
    'HANGBOARD_MAX_HANG',
    _climb,
    _dur,
    [MuscleGroup.fingersForearms],
    equipment: ['HANGBOARD'],
  ),
  ExerciseCatalogEntry(
    'HANGBOARD_REPEATER',
    _climb,
    _dur,
    [MuscleGroup.fingersForearms],
    equipment: ['HANGBOARD'],
  ),
  ExerciseCatalogEntry(
    'HANGBOARD_MIN_EDGE_HANG',
    _climb,
    _dur,
    [MuscleGroup.fingersForearms],
    equipment: ['HANGBOARD'],
  ),
  ExerciseCatalogEntry(
    'LOCK_OFF_HOLD',
    _climb,
    _dur,
    [MuscleGroup.lats, MuscleGroup.biceps, MuscleGroup.upperBack],
    equipment: ['PULL_UP_BAR'],
    bilateral: false,
  ),
  ExerciseCatalogEntry(
    'TUCK_FRONT_LEVER',
    _climb,
    _dur,
    [MuscleGroup.lats, MuscleGroup.core],
    equipment: ['PULL_UP_BAR'],
  ),
  ExerciseCatalogEntry('RICE_BUCKET', _climb, _dur, [
    MuscleGroup.fingersForearms,
  ]),
  ExerciseCatalogEntry(
    'WRIST_CURL',
    _climb,
    _rep,
    [MuscleGroup.fingersForearms],
    equipment: ['DUMBBELLS'],
  ),
  ExerciseCatalogEntry(
    'REVERSE_WRIST_CURL',
    _climb,
    _rep,
    [MuscleGroup.fingersForearms],
    equipment: ['DUMBBELLS'],
  ),
  ExerciseCatalogEntry(
    'BOULDER_PROBLEMS',
    _climb,
    _dur,
    [MuscleGroup.fullBody, MuscleGroup.fingersForearms],
    equipment: ['CLIMBING_WALL_ACCESS'],
  ),
  ExerciseCatalogEntry(
    'ROUTE_CLIMBING',
    _climb,
    _dur,
    [MuscleGroup.fullBody],
    equipment: ['CLIMBING_WALL_ACCESS'],
  ),
  ExerciseCatalogEntry(
    'ARC_TRAVERSE',
    _climb,
    _dur,
    [MuscleGroup.fingersForearms, MuscleGroup.fullBody],
    equipment: ['CLIMBING_WALL_ACCESS'],
  ),
  ExerciseCatalogEntry(
    'LIMIT_BOULDERING',
    _climb,
    _dur,
    [MuscleGroup.fullBody, MuscleGroup.fingersForearms],
    equipment: ['CLIMBING_WALL_ACCESS'],
  ),
  ExerciseCatalogEntry(
    'FOUR_BY_FOUR',
    _climb,
    _dur,
    [MuscleGroup.fullBody, MuscleGroup.cardio],
    equipment: ['CLIMBING_WALL_ACCESS'],
  ),
  // 5.8 Vytrvalost
  ExerciseCatalogEntry('EASY_RUN', _endu, _dur, [MuscleGroup.cardio]),
  ExerciseCatalogEntry('TEMPO_RUN', _endu, _dur, [MuscleGroup.cardio]),
  ExerciseCatalogEntry('INTERVAL_RUN', _endu, _dur, [MuscleGroup.cardio]),
  ExerciseCatalogEntry(
    'EASY_RIDE',
    _endu,
    _dur,
    [MuscleGroup.cardio],
    equipment: ['BIKE'],
  ),
  ExerciseCatalogEntry(
    'STATIONARY_BIKE_STEADY',
    _endu,
    _dur,
    [MuscleGroup.cardio],
    equipment: ['STATIONARY_BIKE'],
  ),
  ExerciseCatalogEntry(
    'ROWING_ERG',
    _endu,
    _dur,
    [MuscleGroup.cardio, MuscleGroup.upperBack],
    equipment: ['ROWING_MACHINE'],
  ),
  ExerciseCatalogEntry('BURPEE', _endu, _rep, [
    MuscleGroup.fullBody,
    MuscleGroup.cardio,
  ]),
  // 5.9 Regenerace
  ExerciseCatalogEntry(
    'FOAM_ROLL_QUADS',
    _rec,
    _dur,
    [MuscleGroup.quads],
    equipment: ['FOAM_ROLLER'],
  ),
  ExerciseCatalogEntry(
    'FOAM_ROLL_UPPER_BACK',
    _rec,
    _dur,
    [MuscleGroup.upperBack],
    equipment: ['FOAM_ROLLER'],
  ),
  ExerciseCatalogEntry(
    'FOAM_ROLL_CALVES',
    _rec,
    _dur,
    [MuscleGroup.calves],
    equipment: ['FOAM_ROLLER'],
  ),
  ExerciseCatalogEntry('FOREARM_MASSAGE', _rec, _dur, [
    MuscleGroup.fingersForearms,
  ]),
  ExerciseCatalogEntry('BOX_BREATHING', _rec, _dur, []),
  ExerciseCatalogEntry('WALKING_COOLDOWN', _rec, _dur, [MuscleGroup.cardio]),
];

final Map<String, ExerciseCatalogEntry> _byCode = {
  for (final entry in exerciseCatalog) entry.code: entry,
};

/// Položka podle kódu; `null` = katalog kód nezná (EXC-001/011).
ExerciseCatalogEntry? exerciseCatalogEntry(String code) => _byCode[code];

bool isKnownExerciseCode(String code) => _byCode.containsKey(code);

/// Položky nabízené k novému výběru (bez `deprecated`, EXC-002).
List<ExerciseCatalogEntry> activeExerciseCatalog() => [
  for (final entry in exerciseCatalog)
    if (!entry.deprecated) entry,
];

/// Kódy nabízené modelu i UI k novému výběru — stabilní pořadí kontraktu.
List<String> activeExerciseCodes() => [
  for (final entry in activeExerciseCatalog()) entry.code,
];
