#!/usr/bin/env bash
# Repository smoke check pro AI Trainer monorepo.
#
# Ověřuje evidence gate slice R0-01 (docs/13-delivery/r0-r1-vertical-slice-plan.md §4):
#   1. kanonická repository struktura existuje,
#   2. žádné build artefakty ani lokální stav nejsou verzované,
#   3. verzované soubory neobsahují zjevné secrets.
#
# Vlastník: delivery/tooling (docs/14-quality/test-strategy.md §21).
# Stejný skript má používat lokální vývoj i CI (R0-06).
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

failures=0

fail() {
  echo "FAIL: $1" >&2
  failures=$((failures + 1))
}

# 1. Kanonická struktura (stav po R0-06).
required_paths=(
  "README.md"
  ".editorconfig"
  ".gitignore"
  "compose.yaml"
  ".github/workflows/repository.yml"
  ".github/workflows/mobile.yml"
  ".github/workflows/backend.yml"
  "apps/mobile"
  "apps/backend"
  "packages/contracts"
  "database/migrations"
  "tooling/scripts"
  "docs/README.md"
  "docs/DOCUMENTATION_STATUS.md"
)

for path in "${required_paths[@]}"; do
  [ -e "$path" ] || fail "chybí povinná cesta: $path"
done

# 2. Build artefakty a lokální stav nesmí být verzované.
#    Výjimka: gradle-wrapper.jar je standardní bootstrap Gradle wrapperu
#    a commituje se, aby čistý checkout uměl build (./gradlew).
forbidden_tracked='(^|/)(build|dist|out|node_modules|\.gradle|\.dart_tool|\.idea)/|\.(apk|aab|ipa|jar|war|keystore|jks|sqlite|db)$|(^|/)local\.properties$|(^|/)\.env(\..+)?$'
if git ls-files | grep -E "$forbidden_tracked" | grep -vE '(^|/)gradle/wrapper/gradle-wrapper\.jar$' >&2; then
  fail "repozitář obsahuje verzované build artefakty nebo lokální stav (viz výše)"
fi

# 3. Zjevné secrets ve verzovaných souborech (vysoce spolehlivé vzory,
#    aby dokumentace o secrets nevytvářela false positives).
secret_patterns='-----BEGIN( [A-Z]+)? PRIVATE KEY-----|AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{36}|xox[baprs]-[0-9A-Za-z-]{10,}'
grep_status=0
git grep -nE -e "$secret_patterns" -- . >&2 || grep_status=$?
if [ "$grep_status" -eq 0 ]; then
  fail "verzované soubory obsahují vzor odpovídající secretu (viz výše)"
elif [ "$grep_status" -ne 1 ]; then
  fail "kontrola secrets selhala (git grep exit $grep_status)"
fi

if [ "$failures" -gt 0 ]; then
  echo "Repository smoke check: FAILED ($failures problémů)" >&2
  exit 1
fi

echo "Repository smoke check: OK"
