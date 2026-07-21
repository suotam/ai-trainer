# AI Trainer – Documentation Map

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/README.md`

---

# 1. Účel dokumentace

Tato složka obsahuje úplnou produktovou, doménovou, technickou, bezpečnostní, implementační a provozní dokumentaci aplikace AI Trainer.

AI Trainer je multiplatformní aplikace pro Android a iOS, která funguje jako osobní AI trenér pro sportovce.

Aplikace musí uživateli umožnit zejména:

* definovat sporty, cíle a časové možnosti,
* vytvářet dlouhodobé i krátkodobé tréninkové plány,
* plánovat jednotlivé workouty,
* sledovat sportovní aktivity,
* zaznamenávat průběh workoutů,
* reagovat na únavu, bolest a změny okolností,
* přizpůsobovat plán pomocí AI,
* zobrazovat plán v interním kalendáři,
* připomínat dnešní aktivity,
* fungovat offline,
* synchronizovat data mezi zařízeními,
* pracovat s wearables a externími službami,
* poskytovat bezpečná, vysvětlitelná a vratná doporučení.

Dokumentace musí být dostatečně konkrétní, aby podle ní mohl vývojář nebo AI coding agent aplikaci implementovat bez zásadního domýšlení:

* produktových pravidel,
* architektury,
* datového modelu,
* bezpečnostního chování,
* uživatelských flow,
* API kontraktů,
* synchronizace,
* AI nástrojů,
* testovacích kritérií.

---

# 2. Základní pravidlo zdroje pravdy

Každá oblast má určený autoritativní dokument nebo skupinu dokumentů.

Pokud si dokumenty odporují, platí toto pořadí:

1. bezpečnostní a právní pravidla,
2. globální produktové principy,
3. doménové invariance,
4. konkrétní doménový model,
5. schválené architektonické rozhodnutí,
6. API nebo datový kontrakt,
7. UX specifikace,
8. implementační doporučení,
9. příklady a návrhy.

Dokument s vyšší prioritou se nesmí obejít dokumentem s nižší prioritou.

Příklad:

* UX specifikace nesmí umožnit akci zakázanou bezpečnostním modelem.
* AI prompt nesmí obejít doménovou invariantu.
* mobilní aplikace nesmí zapisovat data způsobem odporujícím API kontraktu.
* integrace nesmí měnit zdroj pravdy definovaný doménovým modelem.

---

# 3. Dokumentační principy

## 3.1 Dokumentace před implementací

Kompletní dokumentace má být vytvořena před zahájením hlavní implementace.

Drobné technické experimenty mohou vzniknout dříve pouze jako:

* proof of concept,
* ověření technologie,
* měření rizika,
* test dostupnosti externího API.

Experiment se nesmí stát produkční architekturou bez odpovídajícího rozhodovacího dokumentu.

## 3.2 Jeden význam, jeden vlastník

Každý důležitý pojem nebo pravidlo má mít jednoho hlavního vlastníka.

Například:

* TrainingPlan vlastní training plan doména.
* WorkoutSession vlastní workout doména.
* Activity vlastní activity doména.
* PainReport vlastní recovery and limitations doména.
* AIProposal vlastní AI and change doména.

Ostatní dokumenty na objekt odkazují, ale nemají vytvářet jeho odlišnou definici.

## 3.3 Stabilní názvosloví

Doménové názvy se používají konzistentně v:

* dokumentaci,
* databázi,
* API,
* backendu,
* mobilní aplikaci,
* AI nástrojích,
* eventech,
* testech.

Překlad v uživatelském rozhraní může být lokalizovaný, ale interní technické názvy musí zůstat stabilní.

## 3.4 Žádná neřízená obecná data

Kritické doménové objekty nesmí být implementovány pouze jako:

```text
Map<String, dynamic>
```

nebo:

```text
arbitrary JSON
```

bez konkrétního verzovaného schématu.

## 3.5 AI není zdroj pravdy

AI může:

* interpretovat,
* navrhovat,
* vysvětlovat,
* vytvářet strukturované návrhy.

AI nesmí:

* přímo přepisovat databázi,
* obcházet validaci,
* obcházet potvrzení,
* odstraňovat bezpečnostní omezení,
* vydávat návrh za již provedenou změnu.

## 3.6 Offline-first

Mobilní aplikace musí být navržena jako offline-first.

Uživatel musí být schopen bez internetu minimálně:

* otevřít dnešní plán,
* spustit workout,
* zaznamenat průběh,
* dokončit workout,
* vytvořit aktivitu,
* zaznamenat check-in,
* nahlásit bolest,
* používat lokálně známá bezpečnostní omezení.

## 3.7 Bezpečnost před výkonem

Při konfliktu mezi:

* výkonovým cílem,
* preferencí,
* plánem,
* readiness,
* bolestí,
* odborným doporučením,

má bezpečnostní omezení vyšší prioritu.

---

# 4. Hlavní struktura dokumentace

```text
docs/
├── README.md
├── 01-vision/
├── 02-product/
├── 03-users/
├── 04-ux/
├── 05-design-system/
├── 06-domain/
├── 07-backend/
├── 08-mobile/
├── 09-ai/
├── 10-integrations/
├── 11-security/
├── 12-data/
├── 13-devops/
├── 14-quality/
├── 15-release/
├── 16-roadmap/
├── 17-decisions/
├── 18-api/
├── 19-operations/
└── 20-implementation/
```

---

# 5. `01-vision`

## 5.1 Účel

Definuje dlouhodobý směr produktu a neměnné produktové zásady.

## 5.2 Dokumenty

```text
docs/01-vision/
├── vision.md
├── product-principles.md
├── product-positioning.md
├── long-term-product-vision.md
└── non-goals.md
```

## 5.3 Stav

* `vision.md` – existuje,
* `product-principles.md` – existuje,
* ostatní dokumenty zbývají.

## 5.4 Zdroj pravdy

Tato sekce určuje:

* proč produkt existuje,
* jakou hodnotu má přinášet,
* čím se odlišuje,
* co se nemá stát součástí produktu,
* jak se mají rozhodovat nejasné produktové otázky.

---

# 6. `02-product`

## 6.1 Účel

Definuje rozsah produktu, funkce, obchodní logiku a produktové priority.

## 6.2 Dokumenty

```text
docs/02-product/
├── product-scope.md
├── functional-requirements.md
├── non-functional-requirements.md
├── feature-catalog.md
├── product-editions.md
├── subscription-and-entitlements.md
├── notification-strategy.md
├── gamification-strategy.md
├── personalization-strategy.md
├── success-metrics.md
├── product-analytics-requirements.md
├── localization-scope.md
└── legal-product-boundaries.md
```

## 6.3 Zdroj pravdy

Tato sekce určuje:

* co aplikace musí umět,
* co je základní funkce,
* co patří do budoucích verzí,
* jaké funkce jsou placené,
* jak se měří úspěch produktu,
* jaké behaviorální mechanismy jsou přijatelné.

## 6.4 Důležité pravidlo

Dokumentace popisuje úplnou cílovou aplikaci.

Implementační roadmapa následně určí pořadí realizace.

Úplná dokumentace neznamená, že všechny funkce musí být vydány v první veřejné verzi.

---

# 7. `03-users`

## 7.1 Účel

Definuje cílové uživatele, jejich potřeby, životní cyklus a vztahy.

## 7.2 Dokumenty

```text
docs/03-users/
├── user-personas.md
├── user-scenarios.md
├── jobs-to-be-done.md
├── user-lifecycle.md
├── onboarding-personalization.md
├── multisport-user-model.md
├── returning-user-model.md
├── coach-persona.md
├── guardian-and-minor-scenarios.md
└── accessibility-personas.md
```

## 7.3 Zásada univerzálnosti

Persony a scénáře nesmí omezit aplikaci pouze na uvedené příklady.

Příklady uživatelů slouží k ověření modelu.

Aplikace musí podporovat:

* libovolný sport,
* více sportů současně,
* neznámý nebo vlastní sport,
* různé úrovně zkušenosti,
* různé časové možnosti,
* různé vybavení,
* různé dlouhodobé cíle.

---

# 8. `04-ux`

## 8.1 Účel

Definuje informační architekturu, obrazovky, flow a chování aplikace.

## 8.2 Dokumenty

```text
docs/04-ux/
├── information-architecture.md
├── navigation-model.md
├── core-user-flows.md
├── screen-inventory.md
├── screen-specifications.md
├── onboarding-flow.md
├── today-flow.md
├── calendar-flow.md
├── workout-tracker-flow.md
├── activity-tracking-flow.md
├── ai-chat-flow.md
├── proposal-review-flow.md
├── recovery-and-pain-flow.md
├── integrations-flow.md
├── profile-and-settings-flow.md
├── coach-flow.md
├── empty-states.md
├── loading-states.md
├── error-states.md
├── offline-states.md
├── conflict-resolution-flow.md
├── accessibility-requirements.md
└── ux-content-guidelines.md
```

## 8.3 Zdroj pravdy

UX specifikace určuje:

* co uživatel vidí,
* jak přechází mezi funkcemi,
* jak potvrzuje AI změny,
* jak se zobrazují chyby,
* jak aplikace komunikuje offline stav,
* jak se zobrazují bezpečnostní upozornění.

## 8.4 Omezení UX vrstvy

UX nesmí zavádět nový doménový stav, který neexistuje v doménovém modelu.

---

# 9. `05-design-system`

## 9.1 Účel

Definuje vizuální a komponentový systém aplikace.

## 9.2 Dokumenty

```text
docs/05-design-system/
├── design-principles.md
├── color-system.md
├── typography.md
├── spacing-and-layout.md
├── iconography.md
├── component-library.md
├── form-components.md
├── chart-components.md
├── calendar-components.md
├── workout-components.md
├── ai-components.md
├── feedback-and-status-components.md
├── motion.md
├── theming.md
├── dark-mode.md
└── accessibility-design.md
```

## 9.3 Zásada

Design system má být implementovatelný jako opakovaně použitelné Flutter komponenty.

Nemá jít pouze o vizuální inspiraci.

---

# 10. `06-domain`

## 10.1 Účel

Definuje základní obchodní a sportovní model celé aplikace.

## 10.2 Dokumenty

```text
docs/06-domain/
├── domain-overview.md
├── sports-and-goals-model.md
├── training-plan-model.md
├── workout-model.md
├── scheduling-model.md
├── activity-model.md
├── recovery-and-limitations-model.md
├── ai-and-change-model.md
├── metrics-model.md
├── integration-model.md
├── sync-and-offline-model.md
├── identity-and-profile-model.md
├── domain-events.md
├── domain-invariants.md
└── glossary.md
```

## 10.3 Stav

Existují:

* domain overview,
* sports and goals model,
* training plan model,
* workout model,
* scheduling model,
* activity model,
* recovery and limitations model,
* AI and change model,
* metrics model,
* integration model,
* sync and offline model,
* identity and profile model,
* domain events.

Zbývají:

* `domain-invariants.md`,
* `glossary.md`.

## 10.4 Zdroj pravdy

Tato sekce má nejvyšší prioritu pro:

* objekty,
* stavové přechody,
* vlastnictví,
* doménové služby,
* příkazy,
* události,
* invariance.

---

# 11. `07-backend`

## 11.1 Účel

Definuje serverovou architekturu a implementační hranice backendu.

## 11.2 Dokumenty

```text
docs/07-backend/
├── backend-architecture.md
├── modular-monolith-strategy.md
├── module-boundaries.md
├── backend-project-structure.md
├── application-layer.md
├── domain-layer.md
├── persistence-layer.md
├── query-and-projection-model.md
├── event-architecture.md
├── transactional-outbox.md
├── background-jobs.md
├── scheduling-engine.md
├── planning-engine.md
├── workout-service.md
├── activity-service.md
├── recovery-service.md
├── safety-rules-engine.md
├── metrics-service.md
├── progress-service.md
├── ai-orchestration-service.md
├── change-service.md
├── integration-service.md
├── sync-service.md
├── notification-service.md
├── audit-service.md
├── file-and-blob-service.md
├── error-model.md
├── validation-strategy.md
├── idempotency-strategy.md
├── concurrency-strategy.md
├── caching-strategy.md
├── background-processing.md
└── backend-configuration.md
```

## 11.3 Výchozí architektonický směr

Dokud nebude rozhodnuto jinak v ADR:

* backend začne jako modulární monolit,
* moduly budou respektovat doménové hranice,
* komunikace bude připravena na event-driven model,
* databázové transakce budou lokální v rámci modulu nebo jasně definovaného workflow,
* nebude předčasně zaveden velký počet mikroservis.

## 11.4 Zdroj pravdy

Backend dokumentace definuje, jak se doménový model technicky realizuje na serveru.

Nesmí však měnit význam doménových pravidel.

---

# 12. `08-mobile`

## 12.1 Účel

Definuje Flutter aplikaci pro Android a iOS.

## 12.2 Dokumenty

```text
docs/08-mobile/
├── mobile-architecture.md
├── flutter-project-structure.md
├── feature-module-structure.md
├── dependency-direction.md
├── state-management.md
├── navigation-and-routing.md
├── local-database.md
├── repository-pattern.md
├── offline-command-queue.md
├── sync-engine.md
├── conflict-resolution.md
├── background-execution.md
├── workout-session-persistence.md
├── timer-architecture.md
├── activity-tracking.md
├── gps-tracking.md
├── health-platform-access.md
├── push-notifications.md
├── local-notifications.md
├── secure-storage.md
├── authentication-flow.md
├── onboarding-implementation.md
├── ai-chat-implementation.md
├── proposal-review-implementation.md
├── accessibility-implementation.md
├── localization.md
├── error-handling.md
├── performance.md
├── battery-usage.md
├── app-lifecycle.md
├── mobile-analytics.md
└── mobile-configuration.md
```

## 12.3 Výchozí technologie

* Flutter,
* Dart,
* Android a iOS ze stejného hlavního codebase,
* nativní bridge pouze tam, kde Flutter nestačí,
* lokální databáze s podporou transakcí a migrací,
* offline-first repository layer.

Konkrétní knihovny musí být schváleny v ADR dokumentech.

---

# 13. `09-ai`

## 13.1 Účel

Definuje kompletní AI systém.

## 13.2 Dokumenty

```text
docs/09-ai/
├── ai-architecture.md
├── ai-responsibilities.md
├── model-selection.md
├── provider-abstraction.md
├── context-management.md
├── athlete-context-builder.md
├── conversation-memory.md
├── prompt-architecture.md
├── structured-output-contracts.md
├── ai-tools.md
├── tool-authorization.md
├── proposal-generation.md
├── change-set-generation.md
├── confirmation-policy.md
├── planning-reasoning.md
├── workout-generation.md
├── recovery-reasoning.md
├── pain-handling.md
├── limitation-handling.md
├── safety-rules.md
├── medical-boundaries.md
├── hallucination-prevention.md
├── prompt-injection-protection.md
├── sensitive-data-handling.md
├── ai-fallbacks.md
├── cost-and-token-management.md
├── caching.md
├── AI-observability.md
├── evaluation-strategy.md
├── AI-test-scenarios.md
└── model-migration-strategy.md
```

## 13.3 Kritická zásada

AI nesmí přijímat neomezený přístup k interním datům.

AI pracuje přes:

* explicitní kontext builder,
* verzované nástroje,
* strukturované výstupy,
* autorizaci,
* validační vrstvu,
* ConfirmationPolicy,
* ChangeSet.

## 13.4 OpenAI nebo jiný poskytovatel

Aplikace nesmí být v doménové vrstvě pevně svázána s jedním poskytovatelem modelu.

Konkrétní první poskytovatel může být vybrán v technickém rozhodnutí.

---

# 14. `10-integrations`

## 14.1 Účel

Definuje konkrétní externí integrace a jejich omezení.

## 14.2 Dokumenty

```text
docs/10-integrations/
├── integration-architecture.md
├── integration-priorities.md
├── provider-capability-matrix.md
├── apple-health.md
├── health-connect.md
├── garmin.md
├── strava.md
├── polar.md
├── coros.md
├── suunto.md
├── fitbit.md
├── oura.md
├── whoop.md
├── google-calendar.md
├── apple-calendar.md
├── microsoft-calendar.md
├── wear-os.md
├── apple-watch.md
├── file-import.md
├── workout-export.md
├── activity-deduplication.md
└── integration-certification.md
```

## 14.3 Důležité pravidlo

Dokumentace musí rozlišit:

* cílovou podporu,
* reálně dostupné veřejné API,
* partnerství nebo certifikaci,
* funkci dostupnou pouze na mobilním zařízení,
* funkci dostupnou serverově.

To, že doménový model funkci podporuje, neznamená, že ji poskytovatel skutečně povoluje.

---

# 15. `11-security`

## 15.1 Účel

Definuje bezpečnost, soukromí, oprávnění a právně významné procesy.

## 15.2 Dokumenty

```text
docs/11-security/
├── security-architecture.md
├── threat-model.md
├── data-classification.md
├── authentication.md
├── authorization.md
├── session-management.md
├── device-security.md
├── local-data-encryption.md
├── backend-data-encryption.md
├── secrets-management.md
├── integration-security.md
├── oauth-security.md
├── webhook-security.md
├── AI-security.md
├── prompt-injection-security.md
├── health-data-security.md
├── location-data-security.md
├── consent-and-privacy.md
├── GDPR.md
├── data-retention.md
├── data-export.md
├── account-deletion.md
├── audit-and-access-logging.md
├── incident-response.md
├── vulnerability-management.md
├── minor-user-protection.md
└── security-testing.md
```

## 15.3 Zdroj pravdy

Bezpečnostní dokumentace má přednost před:

* pohodlím UX,
* automatizací,
* AI návrhem,
* integrací,
* analytikou.

---

# 16. `12-data`

## 16.1 Účel

Definuje databáze, ukládání, migrace, kvalitu a životní cyklus dat.

## 16.2 Dokumenty

```text
docs/12-data/
├── data-architecture.md
├── relational-data-model.md
├── database-schema.md
├── entity-relationship-model.md
├── naming-conventions.md
├── PostgreSQL-strategy.md
├── local-data-model.md
├── time-series-data.md
├── blob-storage.md
├── caching-and-Redis.md
├── data-migrations.md
├── seed-data.md
├── reference-data.md
├── data-quality.md
├── deduplication.md
├── data-lineage.md
├── backup-and-restore.md
├── disaster-recovery.md
├── archival.md
├── retention-and-deletion.md
├── data-export-format.md
└── analytics-data-model.md
```

## 16.3 Zásada

Fyzický databázový model následuje doménu.

Databázová tabulka není automaticky doménový agregát.

---

# 17. `13-devops`

## 17.1 Účel

Definuje vývojové prostředí, CI/CD, deployment a infrastrukturu.

## 17.2 Dokumenty

```text
docs/13-devops/
├── environments.md
├── local-development.md
├── Docker.md
├── configuration-management.md
├── secrets-in-environments.md
├── CI.md
├── CD.md
├── GitHub-Actions.md
├── infrastructure-as-code.md
├── cloud-architecture.md
├── deployment-strategy.md
├── database-deployment.md
├── migration-deployment.md
├── mobile-build-pipeline.md
├── Android-signing.md
├── iOS-signing.md
├── feature-flags.md
├── observability-stack.md
├── logging.md
├── metrics.md
├── tracing.md
├── alerting.md
├── scaling.md
├── cost-management.md
└── environment-recovery.md
```

---

# 18. `14-quality`

## 18.1 Účel

Definuje testovací strategii a kritéria kvality.

## 18.2 Dokumenty

```text
docs/14-quality/
├── quality-strategy.md
├── test-pyramid.md
├── domain-testing.md
├── backend-unit-testing.md
├── integration-testing.md
├── API-contract-testing.md
├── event-contract-testing.md
├── mobile-unit-testing.md
├── widget-testing.md
├── mobile-integration-testing.md
├── end-to-end-testing.md
├── offline-testing.md
├── sync-testing.md
├── multi-device-testing.md
├── migration-testing.md
├── integration-provider-testing.md
├── AI-evaluation.md
├── AI-safety-testing.md
├── security-testing.md
├── performance-testing.md
├── load-testing.md
├── battery-testing.md
├── accessibility-testing.md
├── localization-testing.md
├── chaos-testing.md
├── test-data-management.md
├── acceptance-criteria.md
└── release-quality-gates.md
```

## 18.3 Kritické oblasti testování

Nejvyšší prioritu mají:

* neztracení workout dat,
* bezpečnostní blokace,
* synchronizační konflikty,
* idempotence,
* AI nástroje,
* account deletion,
* citlivá data,
* offline režim.

---

# 19. `15-release`

## 19.1 Účel

Definuje vydávání aplikace a správu verzí.

## 19.2 Dokumenty

```text
docs/15-release/
├── versioning.md
├── release-process.md
├── release-channels.md
├── internal-testing.md
├── beta-program.md
├── app-store-release.md
├── play-store-release.md
├── backend-release.md
├── database-release.md
├── feature-rollout.md
├── compatibility-policy.md
├── forced-upgrades.md
├── rollback.md
├── crash-reporting.md
├── release-monitoring.md
└── deprecation-policy.md
```

---

# 20. `16-roadmap`

## 20.1 Účel

Definuje pořadí realizace úplné aplikace.

## 20.2 Dokumenty

```text
docs/16-roadmap/
├── product-roadmap.md
├── implementation-stages.md
├── dependency-roadmap.md
├── MVP-definition.md
├── beta-definition.md
├── version-1-definition.md
├── post-v1-roadmap.md
├── wearable-roadmap.md
├── coach-mode-roadmap.md
├── organization-roadmap.md
├── AI-capability-roadmap.md
├── technical-debt-strategy.md
└── risk-register.md
```

## 20.3 Důležité pravidlo

I když dokumentujeme úplnou cílovou aplikaci, implementace musí probíhat po vertikálních řezech.

Každá etapa musí vytvořit použitelný, testovatelný stav.

---

# 21. `17-decisions`

## 21.1 Účel

Uchovává Architecture Decision Records.

## 21.2 Struktura

```text
docs/17-decisions/
├── README.md
├── ADR-001-backend-language.md
├── ADR-002-backend-architecture.md
├── ADR-003-mobile-state-management.md
├── ADR-004-local-database.md
├── ADR-005-server-database.md
├── ADR-006-authentication-provider.md
├── ADR-007-AI-provider.md
├── ADR-008-event-transport.md
├── ADR-009-cloud-provider.md
├── ADR-010-observability-stack.md
└── ...
```

## 21.3 ADR struktura

Každý ADR obsahuje:

* stav,
* kontext,
* rozhodnutí,
* alternativy,
* důsledky,
* datum,
* navazující dokumenty.

## 21.4 Stavy

* PROPOSED,
* ACCEPTED,
* SUPERSEDED,
* REJECTED,
* DEPRECATED.

---

# 22. `18-api`

## 22.1 Účel

Definuje konkrétní veřejné a interní kontrakty.

## 22.2 Dokumenty

```text
docs/18-api/
├── API-principles.md
├── authentication-api.md
├── profile-api.md
├── sports-api.md
├── goals-api.md
├── plans-api.md
├── workouts-api.md
├── workout-sessions-api.md
├── scheduling-api.md
├── activities-api.md
├── recovery-api.md
├── metrics-api.md
├── AI-api.md
├── changes-api.md
├── integrations-api.md
├── sync-api.md
├── notifications-api.md
├── files-api.md
├── error-contract.md
├── pagination.md
├── filtering-and-sorting.md
├── idempotency.md
├── API-versioning.md
├── webhooks.md
└── OpenAPI-generation.md
```

## 22.3 Zásada

API dokumenty musí být odvoditelné z domény.

Nesmí zavádět neomezené obecné endpointy typu:

```text
PATCH /entities/{id}
```

pro všechny objekty bez doménového významu.

---

# 23. `19-operations`

## 23.1 Účel

Definuje každodenní provoz produkční aplikace.

## 23.2 Dokumenty

```text
docs/19-operations/
├── operations-overview.md
├── service-catalog.md
├── ownership.md
├── SLO-and-SLA.md
├── runbooks.md
├── incident-management.md
├── on-call.md
├── provider-outage-runbook.md
├── AI-provider-outage-runbook.md
├── sync-failure-runbook.md
├── database-incident-runbook.md
├── security-incident-runbook.md
├── data-recovery-runbook.md
├── support-tooling.md
├── user-support-boundaries.md
├── data-correction-process.md
└── operational-audit.md
```

---

# 24. `20-implementation`

## 24.1 Účel

Definuje, jak bude Claude nebo vývojový tým postupovat při samotné implementaci.

## 24.2 Dokumenty

```text
docs/20-implementation/
├── implementation-master-plan.md
├── repository-strategy.md
├── repository-structure.md
├── coding-standards.md
├── branch-and-commit-strategy.md
├── definition-of-ready.md
├── definition-of-done.md
├── vertical-slices.md
├── module-implementation-order.md
├── Claude-instructions.md
├── Claude-prompt-template.md
├── context-loading-guide.md
├── change-review-checklist.md
├── documentation-update-policy.md
├── generated-code-policy.md
├── dependency-policy.md
├── code-review-policy.md
├── database-change-policy.md
├── API-change-policy.md
├── AI-change-policy.md
└── release-readiness-checklist.md
```

## 24.3 Nejdůležitější dokument pro coding agenta

`Claude-instructions.md` bude obsahovat:

* pravidla práce s dokumentací,
* zákaz domýšlení neexistujících pravidel,
* požadavek aktualizovat dokumentaci při změně,
* požadavek implementovat po vertikálních řezech,
* požadavek psát testy,
* zákaz měnit doménové invariance bez schválení,
* pravidla práce s databází,
* pravidla práce s AI nástroji,
* pravidla bezpečnosti.

---

# 25. Dokumentační stavy

Každý dokument musí uvádět stav.

Možné stavy:

* OUTLINE,
* DRAFT,
* REVIEW_REQUIRED,
* APPROVED,
* IMPLEMENTATION_READY,
* IMPLEMENTED,
* NEEDS_UPDATE,
* SUPERSEDED,
* ARCHIVED.

## 25.1 DRAFT

Obsah je rozsáhlý, ale ještě nemusí být finálně konzistentní s celou dokumentací.

## 25.2 APPROVED

Produktový a architektonický význam je schválen.

## 25.3 IMPLEMENTATION_READY

Dokument obsahuje dostatek konkrétních informací pro implementaci.

## 25.4 IMPLEMENTED

Dokument odpovídá skutečně implementovanému systému.

---

# 26. Dokumentační metadata

Každý dokument má na začátku obsahovat minimálně:

```text
Verze:
Stav:
Soubor:
Vlastník:
Poslední aktualizace:
Navazuje na:
Navazující dokumenty:
```

U prvních draftů může být vlastník nebo datum doplněno později.

---

# 27. Propojení dokumentů

Dokument má uvádět:

* na co navazuje,
* co na něj navazuje,
* které pojmy vlastní,
* které pojmy pouze používá.

Tím se zabrání vzniku paralelních definic.

---

# 28. Diagramy

Diagramy se mají zapisovat jako:

* Mermaid,
* textové diagramy,
* případně samostatné zdrojové soubory.

Obrázek bez editovatelného zdroje nestačí.

Doporučené budoucí složky:

```text
docs/assets/
├── diagrams/
├── wireframes/
├── schemas/
└── examples/
```

---

# 29. Příklady a testovací scénáře

Příklady v dokumentaci musí být realistické.

Důležité referenční scénáře zahrnují:

## Fotbalista

* tři týmové tréninky,
* nedělní zápas,
* domácí posilování horní části těla,
* hrazda,
* úprava podle únavy.

## Florbalista a lezec

* florbal pondělí a středa,
* nedělní zápas,
* ranní mobilita,
* posílení nohou,
* lezecký víkend,
* dvoufázové dny.

## Nepravidelný multisportovec

* měnící se pracovní rozvrh,
* vlastní sporty,
* cestování,
* různé vybavení.

## Uživatel s omezením

* bolest bicepsu,
* historická operace kolene,
* dočasný zákaz běhu,
* návrat po nemoci.

Příklady slouží k ověření univerzálnosti.

Neomezují produkt pouze na uvedené sporty.

---

# 30. Dokumentační konzistence

Před označením oblasti jako `IMPLEMENTATION_READY` se musí zkontrolovat:

* stejné názvy objektů,
* stejné stavové hodnoty,
* stejné příkazy,
* stejné eventy,
* stejné priority,
* stejné bezpečnostní hranice,
* stejné potvrzovací požadavky,
* stejné vlastnictví dat,
* stejné jednotky a časové významy.

---

# 31. Automatické kontroly dokumentace

V budoucím repozitáři je vhodné kontrolovat:

* nefunkční odkazy,
* duplicitní názvy souborů,
* chybějící metadata,
* neplatné Mermaid diagramy,
* neregistrované eventy,
* neregistrované API kontrakty,
* neshodu glossary pojmů.

---

# 32. Pořadí tvorby dokumentace

Dokumentaci budeme vytvářet v tomto pořadí:

## Fáze A – dokončení základních pravidel

1. `06-domain/domain-invariants.md`
2. `06-domain/glossary.md`
3. chybějící vision a product foundations
4. chybějící user foundations
5. dokončení UX kostry

## Fáze B – zásadní architektura

1. backend architecture,
2. mobile architecture,
3. AI architecture,
4. security architecture,
5. data architecture,
6. integration architecture.

## Fáze C – konkrétní kontrakty

1. API,
2. databázový model,
3. event kontrakty,
4. AI nástroje,
5. sync kontrakty,
6. externí poskytovatelé.

## Fáze D – provoz a kvalita

1. testování,
2. DevOps,
3. release,
4. operations,
5. roadmap.

## Fáze E – instrukce pro implementaci

1. master implementation plan,
2. repository structure,
3. Claude instructions,
4. prompt templates,
5. vertical slices,
6. definition of done.

---

# 33. Předběžný rozsah dokumentace

Úplná dokumentace pravděpodobně obsahuje přibližně:

| Sekce          | Odhad dokumentů |
| -------------- | --------------: |
| Vision         |               5 |
| Product        |              13 |
| Users          |              10 |
| UX             |              23 |
| Design system  |              16 |
| Domain         |              15 |
| Backend        |              33 |
| Mobile         |              32 |
| AI             |              31 |
| Integrations   |              22 |
| Security       |              27 |
| Data           |              22 |
| DevOps         |              25 |
| Quality        |              28 |
| Release        |              16 |
| Roadmap        |              13 |
| Decisions      |        průběžně |
| API            |              25 |
| Operations     |              17 |
| Implementation |              21 |

Celkem může jít přibližně o **350–400 souborů**, pokud bude každé konkrétní téma oddělené.

To však neznamená 400 obřích dokumentů.

Část dokumentů bude:

* krátká rozhodovací specifikace,
* kontrakt,
* checklist,
* tabulka,
* runbook,
* konkrétní provider dokument.

Dlouhé budou zejména:

* doménové modely,
* hlavní architektury,
* AI bezpečnost,
* synchronizace,
* databázový model,
* implementační plán.

---

# 34. Praktický rozsah před programováním

Protože cílem je nejdříve dokončit úplnou dokumentaci, programování začne až po vytvoření všech plánovaných sekcí v rozsahu potřebném pro cílovou aplikaci.

Před zahájením implementace musí být minimálně:

* všechny dokumenty se statusem alespoň `DRAFT`,
* zásadní dokumenty se statusem `IMPLEMENTATION_READY`,
* všechna technologická rozhodnutí přijatá,
* API kontrakty definované,
* databázový model definovaný,
* bezpečnostní model schválený,
* AI nástroje a safety pravidla definované,
* roadmapa a vertikální řezy připravené,
* instrukce pro Clauda hotové.

---

# 35. Co není cílem

Dokumentace nemá:

* vytvářet zbytečné duplicity,
* předstírat přesnost u neověřených externích API,
* zamknout každý implementační detail bez důvodu,
* přidávat funkce pouze proto, že je mají konkurenční aplikace,
* vytvářet stovky prázdných souborů bez obsahu,
* nahradit testy,
* nahradit uživatelské ověřování produktu.

Každý dokument musí mít praktický účel.

---

# 36. Pravidlo změn během implementace

Pokud implementace odhalí neřešený problém:

1. problém se zaznamená,
2. najde se vlastník pravidla,
3. upraví se příslušný dokument,
4. případně vznikne ADR,
5. zkontrolují se závislé dokumenty,
6. až poté se implementuje změna.

Claude nesmí svévolně změnit architekturu pouze proto, že je jiná varianta rychlejší.

---

# 37. Instrukce pro budoucího coding agenta

Před implementací funkce musí agent:

1. načíst `docs/README.md`,
2. určit dotčené domény,
3. načíst příslušné doménové dokumenty,
4. načíst globální invariance,
5. načíst architekturu cílové vrstvy,
6. načíst bezpečnostní dokumenty,
7. načíst API a datové kontrakty,
8. načíst implementační etapu,
9. ověřit acceptance criteria,
10. až poté měnit kód.

Agent nesmí:

* vytvářet nové doménové pojmy bez dokumentace,
* měnit veřejný kontrakt bez aktualizace dokumentů,
* obcházet bezpečnost,
* odstraňovat testy kvůli průchodu buildu,
* skrývat neimplementovanou část falešnými daty,
* označit úkol za hotový bez splnění Definition of Done.

---

# 38. Bezpečnostní upozornění

AI Trainer pracuje s údaji, které mohou zahrnovat:

* sportovní historii,
* bolest,
* omezení,
* spánek,
* tělesné hodnoty,
* polohu,
* zdravotně relevantní informace,
* AI konverzace.

Dokumentace musí počítat s vysokou citlivostí těchto dat.

Aplikace nesmí být prezentována jako:

* lékař,
* diagnostický nástroj,
* náhrada fyzioterapeuta,
* náhrada urgentní zdravotní péče.

---

# 39. Aktuálně dokončené hlavní dokumenty

V současnosti jsou vytvořeny nebo rozpracovány zejména:

```text
docs/01-vision/
├── vision.md
└── product-principles.md

docs/02-product/
└── product-scope.md

docs/03-users/
├── user-personas.md
└── user-scenarios.md

docs/04-ux/
├── information-architecture.md
├── core-user-flows.md
└── screen-specifications.md

docs/06-domain/
├── domain-overview.md
├── sports-and-goals-model.md
├── training-plan-model.md
├── workout-model.md
├── scheduling-model.md
├── activity-model.md
├── recovery-and-limitations-model.md
├── ai-and-change-model.md
├── metrics-model.md
├── integration-model.md
├── sync-and-offline-model.md
├── identity-and-profile-model.md
└── domain-events.md
```

Přesný skutečný stav musí být později ověřen proti souborům v repozitáři.

---

# 40. Bezprostředně následující dokumenty

Další pořadí je:

```text
docs/06-domain/domain-invariants.md
docs/06-domain/glossary.md
docs/01-vision/product-positioning.md
docs/01-vision/long-term-product-vision.md
docs/01-vision/non-goals.md
docs/02-product/functional-requirements.md
docs/02-product/non-functional-requirements.md
docs/02-product/feature-catalog.md
```

Tím nejprve uzavřeme doménovou vrstvu a následně doplníme vrchní produktovou vrstvu, proti které budeme kontrolovat všechny technické části.

---

# 41. Závěr

Tento dokument je hlavním rozcestníkem projektu AI Trainer.

Jeho úkolem je zajistit, že dokumentace nebude pouze sbírka dlouhých textů, ale propojený systém zdrojů pravdy.

Základní vztah dokumentace je:

```text
Vision
    ↓
Product requirements
    ↓
User needs
    ↓
UX flows
    ↓
Domain model
    ↓
Architecture
    ↓
Security and data rules
    ↓
API and implementation contracts
    ↓
Testing and operations
    ↓
Implementation plan
```

Při vývoji se musí postupovat opačným směrem pouze v rámci schválených pravidel:

```text
Implementation task
    ↓
Implementation plan
    ↓
API and architecture
    ↓
Domain rules
    ↓
Product requirement
    ↓
Vision and principles
```

Díky tomu bude možné předat dokumentaci Claudovi nebo vývojovému týmu a systematicky implementovat aplikaci bez toho, aby si každý modul vytvářel vlastní neslučitelná pravidla.
