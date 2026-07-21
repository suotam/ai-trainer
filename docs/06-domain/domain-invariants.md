# AI Trainer – Domain Invariants

**Verze:** 0.1  
**Stav:** Draft  
**Soubor:** `docs/06-domain/domain-invariants.md`  
**Vlastník:** Domain Architecture  
**Poslední aktualizace:** 2026-07-21  
**Navazuje na:** všechny dokumenty v `docs/06-domain/`, `docs/01-vision/product-principles.md`  
**Navazující dokumenty:** `docs/06-domain/glossary.md`, backendová, mobilní, AI, bezpečnostní a testovací architektura

---

# 1. Účel dokumentu

Tento dokument sjednocuje globální a mezidoménové invariance aplikace AI Trainer.

Invariance je pravidlo, které musí zůstat pravdivé ve všech podporovaných stavech systému bez ohledu na to, zda změnu vyvolal:

- uživatel,
- trenér,
- opatrovník,
- AI,
- automatizace,
- mobilní klient,
- backend,
- offline synchronizace,
- externí integrace,
- administrativní nebo opravný proces.

Dokument nepopisuje znovu celé modely objektů. Detailní invariance konkrétního agregátu zůstávají v jeho vlastním doménovém dokumentu. Tento soubor vlastní pouze:

- pravidla platná napříč více doménami,
- pořadí priorit mezi doménami,
- nepřekročitelné bezpečnostní hranice,
- pravidla zdrojů pravdy,
- globální pravidla historie, času, identity, AI a synchronizace,
- pravidla konzistence mezi plánem, kalendářem, workoutem a skutečnou aktivitou,
- společný registr invariant s trvalými identifikátory.

---

# 2. Rozsah a autorita

Tento dokument je autoritativní pro cross-domain pravidla.

Pokud si pravidla odporují, platí následující pořadí:

1. právní a bezpečnostní zákaz,
2. aktivní odborné doporučení nebo ochranné omezení,
3. globální invariance z tohoto dokumentu,
4. detailní invariance vlastnící domény,
5. potvrzené uživatelské rozhodnutí,
6. aktivní plán a schedule,
7. preference,
8. AI doporučení,
9. výchozí heuristika.

Nižší vrstva nesmí obejít vyšší vrstvu.

## 2.1 Co není invariance

Invariance není:

- obecné doporučení,
- UX preference,
- současná technická volba,
- optimalizace,
- experiment,
- dočasná produktová priorita,
- odhad AI,
- běžná hodnota konfigurace.

Například „použijeme PostgreSQL“ je architektonické rozhodnutí, nikoli doménová invariance.

## 2.2 Síla pravidla

Každá invariance používá jednu úroveň:

- **ABSOLUTE** – systém nesmí vytvořit ani potvrdit porušující stav.
- **SAFETY_CRITICAL** – porušení musí operaci zablokovat a vyvolat bezpečnostní reakci.
- **CONSISTENCY_CRITICAL** – porušení musí operaci odmítnout nebo převést do řízeného konfliktu.
- **AUDIT_CRITICAL** – stav může vzniknout pouze s úplnou dohledatelností.
- **USER_CONTROL_CRITICAL** – vyžaduje odpovídající vědomé rozhodnutí uživatele.

---

# 3. Formát invarianty

Každá invariance má:

- stabilní ID `INV-xxx`,
- název,
- úroveň,
- pravidlo,
- praktický důsledek,
- hlavní vlastnící dokumenty.

ID se nesmí znovu použít pro jiný význam. Zrušená invariance se označí jako `DEPRECATED` nebo `SUPERSEDED`; její ID se nerecykluje.

---

# 4. Globální priority

## INV-001 – Bezpečnost má přednost před výkonem

**Úroveň:** `SAFETY_CRITICAL`

Žádný cíl, plán, preference, soutěžní termín, adherence score ani AI doporučení nesmí mít vyšší prioritu než platné bezpečnostní omezení.

**Důsledek:** Pokud vhodný workout nelze vytvořit bezpečně, systém musí nabídnout bezpečnou alternativu, odpočinek, omezenou aktivitu nebo odbornou konzultaci; nesmí „splnit plán za každou cenu“.

**Vlastnící dokumenty:** `product-principles.md`, `recovery-and-limitations-model.md`, `ai-and-change-model.md`.

## INV-002 – Aktivní zákaz nelze obejít preferencí

**Úroveň:** `SAFETY_CRITICAL`

Preference uživatele, automatizační nastavení ani trenérské oprávnění nesmí deaktivovat aktivní bezpečnostní zákaz bez procesu, který vlastní příslušná bezpečnostní nebo limitation doména.

## INV-003 – Nejistota nesmí být vydávána za jistotu

**Úroveň:** `ABSOLUTE`

Odhad, chybějící údaj, neověřený import nebo AI interpretace musí zůstat označeny odpovídajícím zdrojem, jistotou a úplností.

**Důsledek:** Nízká jistota může vést ke konzervativnějšímu návrhu nebo doplňující otázce, nikoli k falešně přesnému tvrzení.

## INV-004 – Autoritativní zákaz se vyhodnocuje v okamžiku provedení

**Úroveň:** `SAFETY_CRITICAL`

Schválení starého návrhu nestačí. Před aplikací změny nebo spuštěním kritické akce se musí znovu vyhodnotit aktuální omezení, oprávnění a relevantní verze dat.

---

# 5. Vlastnictví a izolace dat

## INV-005 – Každý sportovní objekt patří konkrétnímu AthleteProfile

**Úroveň:** `ABSOLUTE`

Každý cíl, plán, workout, schedule event, activity, metric, recovery record, limitation, AI proposal a integrační záznam musí mít jednoznačný profilový kontext.

## INV-006 – Data různých profilů se nesmí smísit

**Úroveň:** `SAFETY_CRITICAL`

Výpočet, AI kontext, synchronizace, projekce ani trenérský přístup nesmí použít data jiného AthleteProfile bez explicitního oprávněného cross-profile účelu.

## INV-007 – Klientský ActiveProfileContext není autorizace

**Úroveň:** `ABSOLUTE`

Backend musí u každého příkazu samostatně ověřit, zda aktér smí pracovat s uvedeným profilem. Hodnota profilu zaslaná klientem není důkaz oprávnění.

## INV-008 – Vlastnictví a role nelze změnit běžnou editací profilu

**Úroveň:** `CONSISTENCY_CRITICAL`

Změna vlastníka, profile role, coach relationship nebo guardian relationship musí proběhnout specializovaným autorizovaným procesem a vytvořit audit.

## INV-009 – Odvolané oprávnění zastavuje budoucí přístup

**Úroveň:** `SAFETY_CRITICAL`

Po revokaci vztahu, scope nebo souhlasu nesmí nová operace spoléhat na dříve vydané aplikační rozhodnutí. Cache a dlouhodobé joby musí být invalidovány nebo znovu autorizovány.

---

# 6. Identita, účet a profil

## INV-010 – Identita, účet a AthleteProfile jsou oddělené pojmy

**Úroveň:** `ABSOLUTE`

AuthenticationIdentity odpovídá na způsob přihlášení, UserAccount na produktový účet a AthleteProfile na osobu, pro kterou se plánuje. Jedna entita nesmí neřízeně suplovat ostatní.

## INV-011 – Externí login identita je unikátní

**Úroveň:** `CONSISTENCY_CRITICAL`

Jedna aktivní kombinace poskytovatele a stabilního provider subject nesmí současně patřit dvěma interním identitám mimo řízený merge proces.

## INV-012 – Účet nesmí zůstat bez bezpečné možnosti přístupu

**Úroveň:** `USER_CONTROL_CRITICAL`

Odpojení poslední autentizační metody musí být odmítnuto, pokud současně nevznikne jiný bezpečný recovery nebo login mechanismus.

## INV-013 – Anonymní upgrade nesmí duplikovat data

**Úroveň:** `CONSISTENCY_CRITICAL`

Registrace anonymního uživatele musí zachovat existující profil, workouty, activity a pending operace. Retry nesmí vytvořit druhý účet nebo profil.

## INV-014 – Smazaný nebo zablokovaný účet nesmí obnovit stav offline zápisem

**Úroveň:** `SAFETY_CRITICAL`

Pozdě přijatá offline operace nesmí znovu aktivovat účet, vztah ani data, která byla autoritativně zrušena nebo smazána.

---

# 7. Historie, verze a opravy

## INV-015 – Plán a skutečnost jsou oddělené

**Úroveň:** `ABSOLUTE`

Plánovaný workout nebo schedule event se nesmí zpětně změnit na skutečně provedenou Activity tak, že se ztratí rozdíl mezi záměrem a realitou.

## INV-016 – Dokončená historie se nepřepisuje neauditovaně

**Úroveň:** `AUDIT_CRITICAL`

Oprava dokončené activity, workout session, check-inu, metric value nebo importu musí vytvořit novou revizi, correction record nebo jinou dohledatelnou změnu.

## INV-017 – Aktivní plán má právě jednu aktivní verzi pro daný účinný kontext

**Úroveň:** `CONSISTENCY_CRITICAL`

Pro jeden TrainingPlan a překrývající se účinné období nesmí existovat dvě současně autoritativní aktivní verze.

## INV-018 – Workout session odkazuje na konkrétní revizi workoutu

**Úroveň:** `CONSISTENCY_CRITICAL`

Záznam výkonu musí zůstat interpretovatelný podle struktury workoutu, kterou uživatel skutečně vykonával. Pozdější úprava WorkoutInstance nesmí změnit význam uložené session.

## INV-019 – Historické metriky zachovávají použitou metodiku

**Úroveň:** `AUDIT_CRITICAL`

Odvozená metrika musí uvádět calculation method a version. Nová metodika nesmí neviditelně změnit význam staré hodnoty.

## INV-020 – Oprava nevytváří falešnou novou aktivitu

**Úroveň:** `CONSISTENCY_CRITICAL`

Korekce existujícího objektu nesmí být započtena jako další workout, activity, personal record nebo tréninková zátěž.

## INV-021 – Identifikátory se po merge nebo sync nerecyklují

**Úroveň:** `ABSOLUTE`

Sloučený, nahrazený nebo smazaný objekt může mít alias či tombstone, ale jeho stabilní ID nesmí být přiděleno jinému významu.

---

# 8. Čas a kalendář

## INV-022 – Absolutní čas a lokální význam jsou oddělené

**Úroveň:** `ABSOLUTE`

Historický okamžik se ukládá jako absolutní čas. Plánovací význam může navíc obsahovat local date, local time a IANA timezone.

## INV-023 – Změna časového pásma nesmí změnit historický okamžik

**Úroveň:** `CONSISTENCY_CRITICAL`

Změna preference timezone ovlivní zobrazení nebo budoucí plánování podle policy, ale nesmí posunout skutečný čas již provedené activity.

## INV-024 – ScheduleEvent není Activity

**Úroveň:** `ABSOLUTE`

Dokončení kalendářní události může vést k vytvoření nebo spárování Activity, ale samotná změna stavu ScheduleEvent nesmí bez odpovídající evidence představovat provedený sportovní výkon.

## INV-025 – Recurrence změna musí mít explicitní scope

**Úroveň:** `CONSISTENCY_CRITICAL`

Změna opakované série musí určit, zda se týká jednoho výskytu, celé série, nebo tohoto a následujících výskytů.

## INV-026 – Konkrétní kalendářní skutečnost má přednost před typickým týdnem

**Úroveň:** `CONSISTENCY_CRITICAL`

AvailabilityProfile a TypicalWeekProfile poskytují obecné mantinely. Konkrétní autoritativní událost, výjimka nebo uživatelská změna pro dané datum má přednost.

## INV-027 – Reminder nesmí odkazovat na zastaralý stav

**Úroveň:** `CONSISTENCY_CRITICAL`

Před odesláním reminderu se musí ověřit, že cílová událost stále existuje, nebyla přesunuta nebo zrušena a notifikace je stále povolena.

---

# 9. Sporty, cíle a plán

## INV-028 – Jeden profil má jeden koordinovaný tréninkový systém

**Úroveň:** `CONSISTENCY_CRITICAL`

Sporty mohou mít vlastní cíle a specifika, ale jejich plánovaná a skutečná zátěž musí být posuzována společně na úrovni AthleteProfile.

## INV-029 – Cíl nesmí vlastnit data jiného profilu

**Úroveň:** `ABSOLUTE`

Goal může odkazovat pouze na sporty, metriky, plány a activity v platném profilovém kontextu.

## INV-030 – Aktivovaný plán musí být validovaný vůči aktuálním omezením

**Úroveň:** `SAFETY_CRITICAL`

TrainingPlanVersion nelze aktivovat pouze proto, že byla dříve vygenerována. Aktivace musí ověřit aktuální cíle, dostupnost, limitation, konflikty a oprávnění.

## INV-031 – Změna hlavního cíle není drobná automatická změna

**Úroveň:** `USER_CONTROL_CRITICAL`

Založení, nahrazení, zásadní přesměrování nebo opuštění hlavního cíle vyžaduje explicitní uživatelské rozhodnutí nebo odpovídající oprávněný proces.

## INV-032 – Plán nesmí předstírat provedení

**Úroveň:** `ABSOLUTE`

Nevykonaný workout nesmí být označen jako dokončený pouze kvůli dosažení adherence, uzavření týdne nebo AI optimalizaci.

## INV-033 – Neprovedený plán se nepočítá jako skutečná zátěž

**Úroveň:** `CONSISTENCY_CRITICAL`

Odhadovaná budoucí zátěž může vstupovat do forecastu, ale nesmí se zaměnit za historickou provedenou zátěž.

---

# 10. Workout a workout session

## INV-034 – Aktivní session má stabilní obnovitelný stav

**Úroveň:** `CONSISTENCY_CRITICAL`

Rozpracovaná WorkoutSession musí být obnovitelná po pádu aplikace, restartu nebo dočasném offline režimu bez ztráty potvrzených výkonových záznamů.

## INV-035 – Jedna session nesmí být dokončena dvakrát

**Úroveň:** `CONSISTENCY_CRITICAL`

Opakovaný command, sync retry nebo návrat z backgroundu nesmí vytvořit druhé dokončení, druhou Activity ani dvojí metrický dopad.

## INV-036 – Záznam výkonu musí odpovídat typu kroku

**Úroveň:** `CONSISTENCY_CRITICAL`

SetPerformance nebo StepPerformance nesmí ukládat hodnotu, kterou daný step contract neumí jednoznačně interpretovat bez jednotky a modality.

## INV-037 – Substituce cviku zachovává původní záměr a skutečnost

**Úroveň:** `AUDIT_CRITICAL`

Systém musí zachovat, co bylo původně plánováno, čím to bylo nahrazeno a co bylo skutečně provedeno.

## INV-038 – Safety změna během workoutu má okamžitou přednost

**Úroveň:** `SAFETY_CRITICAL`

Nově hlášená bolest, akutní safety flag nebo relevantní limitation musí být vyhodnoceny před pokračováním v dotčeném kroku; aktivní session není výjimkou z bezpečnostních pravidel.

---

# 11. Activity, import a duplicity

## INV-039 – Jedna skutečná aktivita nesmí být započtena vícekrát

**Úroveň:** `CONSISTENCY_CRITICAL`

Ruční záznam, workout session a více provider importů mohou představovat tutéž skutečnost. Po potvrzení duplicity musí existovat právě jeden kanonický Activity dopad na progres, zátěž a rekordy.

## INV-040 – Zdroj a provenance se neztrácejí při normalizaci

**Úroveň:** `AUDIT_CRITICAL`

Normalizace externího záznamu nesmí odstranit možnost dohledat provider, source record, původní jednotku, čas a transformační verzi.

## INV-041 – Import není automaticky validovaná pravda

**Úroveň:** `CONSISTENCY_CRITICAL`

Externí záznam může vyžadovat validaci, deduplikaci, mapování nebo uživatelskou kontrolu, než ovlivní cíle, zátěž a osobní rekordy.

## INV-042 – Smazání u poskytovatele neurčuje automaticky lokální historii

**Úroveň:** `USER_CONTROL_CRITICAL`

Pokud externí zdroj odstraní záznam, systém musí postupovat podle integrační a retention policy. Nesmí bez pravidla nevratně odstranit lokální potvrzenou Activity.

## INV-043 – GPS trasa není nutná pro existenci Activity

**Úroveň:** `CONSISTENCY_CRITICAL`

Activity může zůstat platná i při chybějící, odstraněné nebo uživatelem zakázané trase. Odstranění route blobu nesmí smazat celý sportovní záznam, pokud to uživatel výslovně nepožaduje.

---

# 12. Recovery, bolest a omezení

## INV-044 – AI nesmí stanovovat medicínskou diagnózu

**Úroveň:** `SAFETY_CRITICAL`

Systém může strukturovat hlášené příznaky, aplikovat bezpečnostní pravidla a doporučit přerušení aktivity nebo odbornou konzultaci. Nesmí prezentovat diagnózu jako výsledek AI Traineru.

## INV-045 – PainReport a Limitation nejsou totéž

**Úroveň:** `ABSOLUTE`

PainReport je pozorování nebo hlášení. Limitation je platné omezení s rozsahem, závažností a životním cyklem. Hlášení bolesti může limitation vyvolat, ale nesmí ji neviditelně nahrazovat.

## INV-046 – Aktivní limitation ovlivňuje všechny relevantní sporty

**Úroveň:** `SAFETY_CRITICAL`

Omezení se nesmí aplikovat pouze na sport, během kterého bylo zaznamenáno. Musí se vyhodnotit vůči každému relevantnímu workoutu, activity proposal a plánu.

## INV-047 – Profesionální doporučení má dohledatelný původ a platnost

**Úroveň:** `AUDIT_CRITICAL`

Systém musí rozlišit uživatelsky přepsané doporučení, importovaný dokument a skutečně ověřený odborný vstup. Nesmí automaticky tvrdit, že doporučení pochází od odborníka, pokud to není podloženo.

## INV-048 – Expirace limitation není automatické potvrzení plné bezpečnosti

**Úroveň:** `SAFETY_CRITICAL`

Skončení platnosti může vyvolat review. Pokud pravidlo vyžaduje potvrzení, systém nesmí bez něj obnovit plnou zátěž.

## INV-049 – Readiness není medicínská diagnóza ani absolutní zákaz

**Úroveň:** `CONSISTENCY_CRITICAL`

Readiness je odvozený plánovací vstup s metodou, úplností a jistotou. Safety zákaz musí pocházet z odpovídajícího safety nebo limitation pravidla.

## INV-050 – Chybějící recovery data nejsou dobrá recovery data

**Úroveň:** `ABSOLUTE`

Absence check-inu, sleep nebo wearable hodnoty nesmí být interpretována jako nulová únava, kvalitní spánek nebo vysoká readiness.

---

# 13. Metriky a progres

## INV-051 – Každá numerická hodnota má definovaný význam a jednotku

**Úroveň:** `ABSOLUTE`

Doménová numerická hodnota nesmí být uložena nebo přenesena bez MetricDefinition, field contractu nebo jiného jednoznačného určení významu a jednotky.

## INV-052 – Změna zobrazovacích jednotek nemění kanonickou hodnotu

**Úroveň:** `CONSISTENCY_CRITICAL`

UnitPreference ovlivňuje vstup a zobrazení, nikoli historický fyzický význam uložených dat.

## INV-053 – Odvozená metrika uvádí vstupy, metodu a verzi

**Úroveň:** `AUDIT_CRITICAL`

Výpočet readiness, load, trendu, progresu nebo adherence musí být zpětně vysvětlitelný minimálně pomocí referencí na vstupy a calculation version.

## INV-054 – Invalidní vstup invaliduje závislé výsledky

**Úroveň:** `CONSISTENCY_CRITICAL`

Oprava nebo invalidace Activity, MetricValue nebo jiného vstupu musí označit závislé agregace, rekordy a progress jako vyžadující přepočet.

## INV-055 – Osobní rekord vyžaduje validní kanonický výkon

**Úroveň:** `CONSISTENCY_CRITICAL`

Duplicitní, nevalidovaný, neporovnatelný nebo později invalidovaný výkon nesmí zůstat autoritativním personal recordem.

## INV-056 – Progres nesmí být odvozován pouze z adherence

**Úroveň:** `ABSOLUTE`

Dokončení plánovaných položek je samostatná metrika a nesmí být prezentováno jako automatické zlepšení výkonnosti.

---

# 14. AI, návrhy a změny

## INV-057 – AI nemá přímý neomezený zápis do zdroje pravdy

**Úroveň:** `ABSOLUTE`

AI může vytvářet strukturované návrhy a volat pouze předem definované autorizované nástroje. Doménovou změnu provádí aplikační vrstva po validaci.

## INV-058 – Text AI odpovědi není provedená změna

**Úroveň:** `ABSOLUTE`

Tvrzení v konverzaci typu „přesunul jsem workout“ nesmí být zobrazeno jako úspěšná skutečnost, dokud není odpovídající ChangeSet nebo command autoritativně aplikován.

## INV-059 – Významná změna vyžaduje odpovídající potvrzení

**Úroveň:** `USER_CONTROL_CRITICAL`

Potvrzovací policy musí zohlednit dopad, vratnost, rozsah, bezpečnost a uživatelské nastavení. AI sama nesmí snížit požadovanou úroveň potvrzení.

## INV-060 – Návrh je vázán na konkrétní kontextové verze

**Úroveň:** `CONSISTENCY_CRITICAL`

AIProposal musí uvádět relevantní profil, plán, schedule, limitation nebo jiné verze, ze kterých vycházel. Změna podstatného kontextu může návrh označit jako `STALE`.

## INV-061 – Stale návrh se nesmí slepě aplikovat

**Úroveň:** `SAFETY_CRITICAL`

Před aplikací návrhu se musí ověřit jeho čerstvost. Neaktuální návrh musí být znovu validován, přepočítán nebo vrácen uživateli k revizi.

## INV-062 – Částečné schválení zachovává konzistentní ChangeSet

**Úroveň:** `CONSISTENCY_CRITICAL`

Pokud uživatel schválí pouze část návrhu, systém musí znovu vyhodnotit závislosti zbývajících operací a nesmí aplikovat izolovanou část, která poruší invariance.

## INV-063 – Undo je nová dohledatelná změna

**Úroveň:** `AUDIT_CRITICAL`

Vrácení změny nemaže původní událost ani audit. Vytvoří kompenzační nebo reverzní změnu s odkazem na původ.

## INV-064 – AI kontext používá nejmenší potřebný rozsah dat

**Úroveň:** `SAFETY_CRITICAL`

Context builder nesmí zpřístupnit modelu nesouvisející profil, autentizační údaje, tokeny, právní historii, celé GPS trasy nebo jiné údaje bez účelu a oprávnění.

## INV-065 – AI odvozený profilový údaj není automaticky uživatelský fakt

**Úroveň:** `CONSISTENCY_CRITICAL`

Interpretace přirozeného jazyka nebo behaviorální odhad musí mít zdroj, jistotu a podle dopadu potvrzení. Nesmí neviditelně přepsat explicitní údaj uživatele.

## INV-066 – Soukromý reasoning modelu se neukládá jako doménový fakt

**Úroveň:** `ABSOLUTE`

Systém může uchovat strukturované důvody, použité vstupy, výsledky validace a tool calls. Nesmí vyžadovat ani ukládat neveřejný chain-of-thought jako zdroj pravdy.

---

# 15. Souhlasy a citlivá data

## INV-067 – Souhlas je účelový a verzovaný

**Úroveň:** `ABSOLUTE`

Souhlas musí odkazovat na konkrétní účel, scope a verzi právního nebo produktového textu. Obecné „souhlasím se vším“ nesmí nahrazovat oddělené právně významné volby.

## INV-068 – Odvolání souhlasu zastavuje budoucí zpracování v daném scope

**Úroveň:** `SAFETY_CRITICAL`

Odvolaný souhlas nesmí být považován za aktivní kvůli cache, offline stavu, starému jobu nebo historickému AI návrhu.

## INV-069 – Product preference není právní souhlas

**Úroveň:** `ABSOLUTE`

Zapnutí personalizace, notifikace nebo AI stylu samo o sobě nepředstavuje souhlas se zpracováním citlivých dat, pokud je takový souhlas vyžadován.

## INV-070 – Citlivost se neztrácí při odvození

**Úroveň:** `SAFETY_CRITICAL`

Agregace, AI summary nebo read model odvozený ze zdravotních, polohových či jinak citlivých dat musí zachovat odpovídající klasifikaci a přístupová pravidla.

## INV-071 – Přístupový token není doménový exportovatelný údaj

**Úroveň:** `ABSOLUTE`

Credential, refresh token, private key ani obdobné tajemství nesmí vstoupit do AI kontextu, běžného auditu, uživatelského exportu nebo doménového event payloadu.

## INV-072 – Data nezletilého vyžadují příslušnou regionální policy

**Úroveň:** `SAFETY_CRITICAL`

Systém nesmí předpokládat jednu globální věkovou hranici nebo univerzální guardian oprávnění. Aktivace funkcí musí respektovat potvrzenou jurisdikční konfiguraci.

---

# 16. Integrace

## INV-073 – Externí poskytovatel není interní zdroj identity objektu

**Úroveň:** `CONSISTENCY_CRITICAL`

Provider ID může identifikovat ExternalDataRecord, ale interní Activity, MetricValue nebo Workout musí mít vlastní stabilní ID.

## INV-074 – Integrace smí používat pouze udělený scope

**Úroveň:** `SAFETY_CRITICAL`

Import, export, webhook i background job musí ověřit aktuální connection status a oprávnění. Historicky udělený scope po revokaci nestačí.

## INV-075 – Provider correction zachovává lineage

**Úroveň:** `AUDIT_CRITICAL`

Nová revize externího záznamu musí být dohledatelně propojena s původním importem a transformací.

## INV-076 – Selhání integrace nesmí zablokovat lokální základní funkce

**Úroveň:** `CONSISTENCY_CRITICAL`

Nedostupnost Garminu, Stravy, Health Connect nebo jiné integrace nesmí zabránit otevření plánu, použití trackeru, ručnímu zápisu či přístupu k již lokálně uloženým datům.

## INV-077 – Capability poskytovatele se nesmí předstírat

**Úroveň:** `ABSOLUTE`

Pokud poskytovatel nepodporuje požadovaný import, export nebo write capability, systém nesmí funkci prezentovat jako dostupnou ani ji nahrazovat neautorizovaným scrapingem.

---

# 17. Offline, synchronizace a více zařízení

## INV-078 – Server potvrzuje autoritativní přijetí offline commandu

**Úroveň:** `CONSISTENCY_CRITICAL`

Lokálně provedená akce může být okamžitě použitelná, ale serverový autoritativní stav vzniká až po validaci a potvrzení synchronizace.

## INV-079 – Retry nesmí znásobit doménový efekt

**Úroveň:** `CONSISTENCY_CRITICAL`

Každý synchronizovatelný command a kritický side effect musí mít idempotency strategii. Opakované odeslání nesmí vytvořit druhé dokončení, platbu, activity, vztah ani souhlas.

## INV-080 – Konflikt se nesmí tiše řešit ztrátou uživatelských dat

**Úroveň:** `USER_CONTROL_CRITICAL`

Pokud nelze změny bezpečně automaticky sloučit, systém musí zachovat obě relevantní varianty nebo vytvořit conflict record k rozhodnutí.

## INV-081 – Tombstone má přednost před starším offline stavem

**Úroveň:** `CONSISTENCY_CRITICAL`

Pozdější synchronizace starého zařízení nesmí znovu vytvořit objekt, který byl autoritativně odstraněn, pokud nejde o explicitní restore proces.

## INV-082 – Pořadí se neurčuje pouze klientským časem

**Úroveň:** `CONSISTENCY_CRITICAL`

Device clock může být chybný. Konflikty a verze musí používat serverové verze, causation, revision nebo jiný robustní mechanismus.

## INV-083 – Aktivní workout má jednoho autoritativního vlastníka zápisu

**Úroveň:** `CONSISTENCY_CRITICAL`

Pokud je jedna WorkoutSession otevřena na více zařízeních, systém musí mít pravidlo lease, ownership, merge nebo explicitního převzetí. Dva klienti nesmí nezávisle dokončit stejnou session.

## INV-084 – Lokální cache nesmí obejít revokaci a smazání

**Úroveň:** `SAFETY_CRITICAL`

Po zjištění revokace zařízení, účtu, role nebo souhlasu musí klient odstranit či znepřístupnit data podle security policy a nesmí je znovu nahrát.

## INV-085 – Offline bezpečnost používá poslední známá omezení konzervativně

**Úroveň:** `SAFETY_CRITICAL`

Bez připojení se nesmí ignorovat lokálně známé aktivní limitation. Pokud stav nelze ověřit a riziko je významné, aplikace musí zvolit konzervativní chování.

---

# 18. Události, audit a procesy

## INV-086 – Doménová událost popisuje nastalou skutečnost

**Úroveň:** `ABSOLUTE`

Event nesmí být skrytým příkazem ani tvrdit změnu, která nebyla transakčně potvrzena.

## INV-087 – Doménová změna a outbox záznam jsou atomické

**Úroveň:** `CONSISTENCY_CRITICAL`

Pokud je pro změnu vyžadováno publikování události, nesmí vzniknout autoritativní změna bez odpovídajícího outbox záznamu ani event bez změny.

## INV-088 – Konzument musí tolerovat duplicitní doručení

**Úroveň:** `CONSISTENCY_CRITICAL`

At-least-once delivery nesmí způsobit vícenásobný business efekt.

## INV-089 – Replay nesmí opakovat nevratný externí side effect

**Úroveň:** `SAFETY_CRITICAL`

Rebuild projekce nebo replay historie nesmí znovu odeslat starou notifikaci, provést provider export, vytvořit platbu nebo jinou nevratnou operaci bez explicitní replay policy.

## INV-090 – Audit je neměnný a přístupově omezený

**Úroveň:** `AUDIT_CRITICAL`

Auditní záznam se neopravuje přepisem; případná korekce vytváří navazující záznam. Audit nesmí být automaticky dostupný každému, kdo vidí běžný profil.

## INV-091 – Correlation a causation se nesmí zaměnit

**Úroveň:** `CONSISTENCY_CRITICAL`

Correlation spojuje širší workflow, causation označuje bezprostřední příčinu. Oba údaje musí být zachovány tam, kde jsou potřebné pro audit a diagnostiku.

---

# 19. Mazání, export a retence

## INV-092 – Export nesmí obsahovat tajemství

**Úroveň:** `ABSOLUTE`

Uživatelský export nesmí obsahovat přístupové tokeny, privátní klíče, interní security credentials ani data jiných profilů.

## INV-093 – Smazání respektuje vlastnictví, zákonné výjimky a lineage

**Úroveň:** `SAFETY_CRITICAL`

Proces musí odstranit nebo anonymizovat osobní data ve všech aktivních storech, projekcích, cache a zařízeních, přičemž zachová pouze právně oprávněné minimum.

## INV-094 – Smazaná data se nesmí obnovit replayem nebo syncem

**Úroveň:** `SAFETY_CRITICAL`

Event replay, historický import, staré zařízení ani provider backfill nesmí znovu vytvořit osobní data odstraněná podle závazného deletion procesu.

## INV-095 – Retence musí odpovídat účelu a klasifikaci

**Úroveň:** `SAFETY_CRITICAL`

Technická pohodlnost sama o sobě není důvodem k neomezenému uchování citlivých dat.

## INV-096 – Odstranění detailu nesmí falšovat zbývající historii

**Úroveň:** `CONSISTENCY_CRITICAL`

Pokud je odstraněna GPS trasa, AI text nebo citlivý detail a základní activity smí zůstat, read model musí jasně reprezentovat chybějící odstraněnou část, nikoli ji nahradit vymyšlenou hodnotou.

---

# 20. Notifikace a automatizace

## INV-097 – Notifikace není zdroj pravdy

**Úroveň:** `ABSOLUTE`

Push, e-mail, watch notification ani kalendářový export mohou zobrazovat snapshot, ale skutečný stav musí být ověřen v autoritativním modelu.

## INV-098 – Automatizace má explicitní scope

**Úroveň:** `USER_CONTROL_CRITICAL`

Uživatel může povolit nízkorizikové automatické změny pouze v definovaném rozsahu. Povolení nelze zobecnit na cíle, safety omezení, sdílení nebo smazání.

## INV-099 – Automatizace nesmí vytvořit nekonečný změnový cyklus

**Úroveň:** `CONSISTENCY_CRITICAL`

Workflow musí používat idempotenci, causation a podmínky publikování tak, aby eventy a přepočty nevytvářely neomezenou zpětnou vazbu.

## INV-100 – Quiet hours neblokují kritickou bezpečnostní reakci podle policy

**Úroveň:** `SAFETY_CRITICAL`

Běžné reminder se odloží nebo potlačí. Kritický bezpečnostní stav se řídí zvláštní policy, která musí být explicitní a přiměřená produktu.

---

# 21. Konflikty mezi doménami

## 21.1 Obecný algoritmus rozhodnutí

Při konfliktu systém postupuje v tomto pořadí:

1. určí dotčený AthleteProfile a oprávněného aktéra,
2. načte nejnovější autoritativní verze,
3. aplikuje právní a bezpečnostní zákazy,
4. aplikuje aktivní limitation a odborná doporučení,
5. ověří globální a lokální invariance,
6. vyhodnotí cíle, plán a schedule,
7. aplikuje explicitní preference,
8. použije AI nebo heuristiku pouze pro zbývající bezpečný prostor,
9. vytvoří návrh, konflikt nebo potvrzenou změnu podle policy,
10. zapíše audit a události.

## 21.2 Příklady priorit

### Plán versus bolest

Aktivní pain/safety restriction má přednost před plánem. Plán se upraví nebo blokuje; bolest se nesmí ignorovat kvůli důležitému workoutu.

### Pevný zápas versus posilování

Pevná sportovní událost může mít vyšší plánovací prioritu než flexibilní workout, ale nemá přednost před safety zákazem.

### Cíl versus dostupnost

Cíl nesmí vynutit jednotku mimo skutečnou dostupnost. Systém musí změnit objem, horizont, prioritu nebo přiznat nereálnost.

### AI návrh versus uživatelská ruční změna

Novější potvrzená uživatelská změna může návrh označit jako stale. AI ji nesmí neviditelně vrátit.

### Provider data versus uživatelská korekce

Pozdější provider revision nesmí bez pravidla přepsat vědomou uživatelskou korekci. Vznikne merge, nová revize nebo conflict.

---

# 22. Cross-domain transakční hranice

Globální invariance neznamenají, že všechny domény musí sdílet jednu databázovou transakci.

Povolené mechanismy:

- synchronní validace před změnou,
- lokální transakce agregátu,
- outbox event,
- saga nebo process manager,
- kompenzační změna,
- dočasný explicitní stav `PENDING`, `PROCESSING` nebo `REQUIRES_REVIEW`.

Nepovolené chování:

- předstírat atomický úspěch, pokud část procesu selhala,
- zobrazit změnu jako hotovou před autoritativním potvrzením,
- ztratit informaci o částečném výsledku,
- obejít invarianci kvůli distribuované architektuře.

---

# 23. Validace podle fáze operace

## 23.1 Při vytvoření návrhu

Kontroluje se:

- strukturální platnost,
- známá oprávnění,
- známé bezpečnostní podmínky,
- existence referencí,
- předběžný dopad.

## 23.2 Při schválení

Kontroluje se:

- identita aktéra,
- confirmation policy,
- rozsah schválení,
- čerstvost návrhu,
- případné změny kontextu.

## 23.3 Při aplikaci

Znovu se kontroluje:

- aktuální verze,
- autorizace,
- bezpečnostní omezení,
- cross-domain invariance,
- idempotence,
- transakční proveditelnost.

## 23.4 Po aplikaci

Musí vzniknout:

- autoritativní výsledek,
- odpovídající revize,
- audit podle citlivosti,
- event/outbox podle kontraktu,
- invalidace nebo přepočet závislých read modelů.

---

# 24. Pravidla pro implementaci

Každý command handler, AI tool, sync operation nebo import pipeline musí určit:

- které invariance vyhodnocuje synchronně,
- které spoléhají na owning domain service,
- které mohou vést ke konfliktu místo odmítnutí,
- které vyvolají přepočet,
- které vyžadují audit,
- které vyžadují potvrzení,
- jak je chování testováno.

Implementace nesmí duplikovat složitá pravidla do více klientů bez jednoho autoritativního serverového nebo sdíleného kontraktu.

Mobilní klient může provádět lokální předběžnou validaci pro UX a offline bezpečnost. Server zůstává autoritativní pro potvrzení synchronizované změny.

---

# 25. Matice vlastnictví invariant

| Oblast | Globální invariance | Detailní zdroj pravdy |
|---|---|---|
| Identita a profily | INV-005 až INV-014 | `identity-and-profile-model.md` |
| Historie a verze | INV-015 až INV-021 | všechny příslušné doménové modely |
| Čas a schedule | INV-022 až INV-027 | `scheduling-model.md` |
| Sporty, cíle, plán | INV-028 až INV-033 | `sports-and-goals-model.md`, `training-plan-model.md` |
| Workout | INV-034 až INV-038 | `workout-model.md` |
| Activity a import | INV-039 až INV-043 | `activity-model.md`, `integration-model.md` |
| Recovery a limitation | INV-044 až INV-050 | `recovery-and-limitations-model.md` |
| Metriky | INV-051 až INV-056 | `metrics-model.md` |
| AI a změny | INV-057 až INV-066 | `ai-and-change-model.md` |
| Souhlasy a citlivost | INV-067 až INV-072 | `identity-and-profile-model.md`, budoucí security dokumenty |
| Integrace | INV-073 až INV-077 | `integration-model.md` |
| Offline a sync | INV-078 až INV-085 | `sync-and-offline-model.md` |
| Eventy a audit | INV-086 až INV-091 | `domain-events.md` |
| Export, deletion, retention | INV-092 až INV-096 | profil, integrace, sync a budoucí security/data dokumenty |
| Notifikace a automatizace | INV-097 až INV-100 | AI/change, scheduling a budoucí notification architektura |

---

# 26. Povinné testovací skupiny

Každá invariance musí být později pokryta jedním nebo více typy testů:

- domain unit test,
- application service test,
- authorization test,
- API contract test,
- database constraint test,
- event consumer test,
- sync conflict test,
- offline test,
- AI tool evaluation,
- end-to-end acceptance test,
- security test.

## 26.1 Kritické testovací scénáře

Minimálně musí být ověřeno:

1. Duplicitní dokončení workoutu nevytvoří dvě Activity.
2. Aktivní limitation zablokuje nebezpečný AI proposal.
3. Stale proposal nelze aplikovat bez nové validace.
4. Provider import a workout session se sloučí jako jedna Activity.
5. Změna jednotek nezmění historické hodnoty.
6. Staré offline zařízení neobnoví smazaný objekt.
7. Revokovaný trenér nezíská data z cache nebo jobu.
8. Odvolání AI souhlasu zastaví nové citlivé zpracování.
9. Změna timezone neposune historickou Activity.
10. Replay eventů neodešle staré notifikace.
11. Oprava Activity invaliduje závislý rekord a progres.
12. Anonymní upgrade zachová ID a nevytvoří duplicity.
13. PainReport z aktivního workoutu spustí safety flow.
14. Dvě zařízení nemohou nezávisle dokončit tutéž session.
15. Export neobsahuje credentials ani data jiného profilu.

---

# 27. Otevřená rozhodnutí

Tento dokument záměrně neřeší následující technické nebo právní volby:

- konkrétní identity provider,
- přesný token a session model,
- konkrétní databázové constraints,
- event transport a schema format,
- sync wire protocol,
- lokální databázi,
- konkrétní AI provider a modely,
- právní pravidla jednotlivých jurisdikcí,
- přesnou medical red-flag matici,
- retenční časy,
- přesnou automation policy,
- konkrétní notification escalation.

Tyto otázky musí být rozhodnuty v navazujících architektonických, bezpečnostních, právních a ADR dokumentech. Výsledek však nesmí porušit invariance definované zde.

---

# 28. Kritéria připravenosti

Tento dokument lze označit jako `IMPLEMENTATION_READY`, až když:

1. každá invariance má potvrzeného vlastníka,
2. je porovnána s detailními doménovými modely,
3. nejsou známé přímé rozpory,
4. security a privacy tým potvrdí relevantní pravidla,
5. medical/safety pravidla projdou odborným review,
6. minors a consent pravidla projdou právním review,
7. každá invariance má plán testovacího pokrytí,
8. backend, mobile, AI a sync architektury na pravidla explicitně odkazují,
9. glossary používá stejné názvy,
10. otevřené technické volby jsou zaznamenány v ADR nebo decision backlogu.

---

# 29. Navazující dokumenty

Bezprostředně následuje:

```text
docs/06-domain/glossary.md
```

Poté se mají aktualizovat:

```text
docs/DOCUMENTATION_STATUS.md
docs/README.md
```

Následné dokumenty musí na `INV-xxx` odkazovat zejména v těchto oblastech:

```text
docs/02-product/functional-requirements.md
docs/02-product/non-functional-requirements.md
docs/07-backend/backend-architecture.md
docs/08-mobile/mobile-architecture.md
docs/09-ai/ai-architecture.md
docs/11-security/security-architecture.md
docs/12-data/data-architecture.md
docs/14-quality/quality-strategy.md
```

---

# 30. Závěr

AI Trainer je systém, ve kterém se současně potkávají:

- dlouhodobé cíle,
- více sportů,
- plán,
- každodenní kalendář,
- skutečné aktivity,
- regenerace,
- bolest a omezení,
- AI návrhy,
- externí data,
- offline změny,
- více zařízení,
- citlivé osobní údaje.

Bez globálních invariant by každá část mohla být lokálně správná a celý systém přesto nekonzistentní nebo nebezpečný.

Základní princip je:

```text
Každá změna
    ↓
určí profil a oprávněného aktéra
    ↓
načte aktuální autoritativní stav
    ↓
aplikuje bezpečnostní a právní priority
    ↓
ověří globální i lokální invariance
    ↓
provede validovanou a idempotentní změnu
    ↓
zachová historii, audit a kauzalitu
    ↓
aktualizuje závislé projekce a výpočty
```

Tyto invariance musí respektovat každá budoucí implementace bez ohledu na zvolený framework, databázi, AI model nebo integračního poskytovatele.