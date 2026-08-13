/// Minimální katalog sportů (C17 §5.1) — stabilní kanonické kódy.
///
/// Reprezentace katalogu je in-app statický seznam (implementační volba
/// dovolená C17); kódy se nikdy nemění ani nerecyklují (ASP-002).
/// Lokalizované názvy jsou prezentační vrstva (ASP-011).
library;

/// Katalogová položka: stabilní kód + kategorie (C17 §5.1).
typedef SportCatalogEntry = ({String code, String category});

const List<SportCatalogEntry> sportCatalog = [
  (code: 'STRENGTH_TRAINING', category: 'STRENGTH'),
  (code: 'RUNNING', category: 'ENDURANCE'),
  (code: 'CYCLING', category: 'ENDURANCE'),
  (code: 'SWIMMING', category: 'WATER_SPORT'),
  (code: 'CLIMBING', category: 'CLIMBING'),
  (code: 'FOOTBALL', category: 'TEAM_SPORT'),
  (code: 'FLOORBALL', category: 'TEAM_SPORT'),
  (code: 'TENNIS', category: 'RACKET'),
  (code: 'MARTIAL_ARTS', category: 'COMBAT'),
  (code: 'YOGA', category: 'MIND_BODY'),
  (code: 'MOBILITY', category: 'MOBILITY'),
  (code: 'HIKING', category: 'OUTDOOR'),
  (code: 'ROWING', category: 'ENDURANCE'),
];

bool isKnownSportCode(String code) =>
    sportCatalog.any((entry) => entry.code == code);

/// Stabilní kódy rolí (C17 §6.1).
const List<String> userSportRoles = [
  'PRIMARY',
  'SECONDARY',
  'SUPPORTING',
  'RECREATIONAL',
  'OCCASIONAL',
  'SEASONAL',
];

/// Stabilní kódy priorit (C17 §6.2).
const List<String> userSportPriorities = [
  'CRITICAL',
  'HIGH',
  'MEDIUM',
  'LOW',
  'BACKGROUND',
];

/// Stabilní kódy zkušenostních úrovní (C17 §6.3).
const List<String> experienceLevels = [
  'BEGINNER',
  'NOVICE',
  'INTERMEDIATE',
  'ADVANCED',
  'EXPERT',
  'PROFESSIONAL',
  'UNKNOWN',
];

/// Stabilní kódy typické intenzity (C17 §6.4).
const List<String> typicalIntensities = [
  'LOW',
  'MODERATE',
  'HIGH',
  'VERY_HIGH',
];

/// Stabilní kódy prostředí (C17 §6.5).
const List<String> sportEnvironments = ['INDOOR', 'OUTDOOR', 'MIXED'];
