/// Vazba aktuálního lokálního vlastníka dat (C2 §4 ↔ C3 §7): po přihlášení
/// je vlastníkem nově vytvářených dat účet; anonymní stav je first-class
/// (ISC-002). Vazba nemění vlastnictví existujících dat — attach
/// předpřihlašovacích dat vlastní C15 (R2-07).
abstract interface class LocalOwnerBinding {
  Future<void> bindAccount(String accountId);

  Future<void> bindAnonymous();
}
