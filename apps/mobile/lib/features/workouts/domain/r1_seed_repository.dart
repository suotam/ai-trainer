/// Seed boundary R1 (fyzický model §16, §17).
library;

enum SeedResult { applied, alreadyApplied }

/// Aplikuje verzovaný demo seed. Musí být idempotentní, se stabilními ID
/// a nesmí přepsat session ani uživatelsky změněnou instanci (PDR-010).
abstract interface class R1SeedRepository {
  Future<SeedResult> applySeed();
}
