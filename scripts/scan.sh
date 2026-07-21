#!/usr/bin/env bash
# ICM Builder — codebase scanner
# Usage: bash scan.sh /path/to/project
# Prints a markdown scan report to stdout. Read-only: never modifies the project.
set -uo pipefail

ROOT="${1:-.}"
cd "$ROOT" 2>/dev/null || { echo "ERROR: cannot access $ROOT"; exit 1; }

section() { printf '\n## %s\n\n' "$1"; }
have() { [ -e "$1" ]; }

echo "# ICM Scan Report"
echo "Root: $(pwd)"
echo "Date: $(date +%Y-%m-%d)"

# ---------- Languages & frameworks ----------
section "Stack signals"
have package.json      && echo "- Node.js project (package.json)"
have tsconfig.json     && echo "- TypeScript (tsconfig.json)"
have pyproject.toml    && echo "- Python (pyproject.toml)"
have requirements.txt  && echo "- Python (requirements.txt)"
have go.mod            && echo "- Go (go.mod)"
have Cargo.toml        && echo "- Rust (Cargo.toml)"
have pom.xml           && echo "- Java/Maven (pom.xml)"
have build.gradle      && echo "- Java/Gradle (build.gradle)"
have composer.json     && echo "- PHP (composer.json)"
have Gemfile           && echo "- Ruby (Gemfile)"

if have package.json; then
  for dep in react vue svelte next nuxt astro express fastify nestjs vite angular remix; do
    grep -q "\"$dep\"" package.json 2>/dev/null && echo "- Framework/dep: $dep"
  done
fi
# Python manifests at root OR one level deep (common in web apps with backend/ subfolder)
find . -maxdepth 2 \( -name requirements.txt -o -name pyproject.toml \) \
  ! -path '*/node_modules/*' ! -path '*/venv/*' 2>/dev/null | while read -r f; do
  [ "$f" = "./requirements.txt" ] || [ "$f" = "./pyproject.toml" ] || echo "- Python manifest: $f"
  for dep in fastapi django flask celery sqlalchemy; do
    grep -qi "$dep" "$f" 2>/dev/null && echo "- Framework/dep: $dep (in $f)"
  done
done

# ---------- Package manager ----------
section "Package manager"
have pnpm-lock.yaml    && echo "- pnpm"
have yarn.lock         && echo "- yarn"
have package-lock.json && echo "- npm"
have bun.lockb         && echo "- bun"
have poetry.lock       && echo "- poetry"
have uv.lock           && echo "- uv"
have Pipfile.lock      && echo "- pipenv"

# ---------- Commands ----------
section "Commands"
if have package.json; then
  echo "From package.json scripts:"
  echo '```'
  if command -v node >/dev/null 2>&1; then
    node -e 'const s=require("./package.json").scripts||{};Object.entries(s).forEach(([k,v])=>console.log(k.padEnd(16),v))' 2>/dev/null
  else
    sed -n '/"scripts"/,/}/p' package.json
  fi
  echo '```'
fi
have Makefile && { echo "Makefile targets:"; echo '```'; grep -E '^[a-zA-Z0-9_.-]+:' Makefile | cut -d: -f1 | head -20; echo '```'; }
have pyproject.toml && grep -q '\[tool.poetry.scripts\]\|\[project.scripts\]' pyproject.toml 2>/dev/null && echo "- pyproject.toml defines script entry points (read it)"
have manage.py && echo "- Django manage.py present"

# ---------- Monorepo ----------
section "Repo layout"
MONO=""
have pnpm-workspace.yaml && MONO="pnpm workspaces"
have lerna.json          && MONO="lerna"
have turbo.json          && MONO="turborepo"
have nx.json             && MONO="nx"
have package.json && grep -q '"workspaces"' package.json 2>/dev/null && MONO="${MONO:-npm/yarn workspaces}"
if [ -n "$MONO" ]; then
  echo "- Monorepo: $MONO"
  for d in packages apps; do
    [ -d "$d" ] && echo "- $d/: $(ls "$d" 2>/dev/null | tr '\n' ' ')"
  done
else
  echo "- Single repo (no monorepo config found)"
fi

# ---------- Folder tree (2 levels, filtered) ----------
section "Folder tree (2 levels)"
echo '```'
find . -maxdepth 2 -type d \
  ! -path '*/node_modules*' ! -path '*/.git*' ! -path '*/dist*' \
  ! -path '*/build*' ! -path '*/.next*' ! -path '*/venv*' ! -path '*/.venv*' \
  ! -path '*/__pycache__*' ! -path '*/target*' ! -path '*/coverage*' \
  2>/dev/null | sort | head -60
echo '```'

# ---------- CI / infra ----------
section "CI and infrastructure"
[ -d .github/workflows ] && echo "- GitHub Actions: $(ls .github/workflows 2>/dev/null | tr '\n' ' ')"
have Jenkinsfile        && echo "- Jenkinsfile"
have .gitlab-ci.yml     && echo "- GitLab CI"
have Dockerfile         && echo "- Dockerfile"
ls docker-compose*.yml docker-compose*.yaml 2>/dev/null | while read -r f; do echo "- $f"; done
have vercel.json        && echo "- Vercel config"
have netlify.toml       && echo "- Netlify config"
have fly.toml           && echo "- Fly.io config"

# ---------- Tests ----------
section "Test setup"
ls jest.config.* vitest.config.* playwright.config.* cypress.config.* 2>/dev/null | while read -r f; do echo "- $f"; done
have pytest.ini && echo "- pytest.ini"
have pyproject.toml && grep -q '\[tool.pytest' pyproject.toml 2>/dev/null && echo "- pytest configured in pyproject.toml"
for d in tests test __tests__ spec e2e; do
  [ -d "$d" ] && echo "- test folder: $d/ ($(find "$d" -type f 2>/dev/null | wc -l | tr -d ' ') files)"
done

# ---------- Existing agent context ----------
section "Existing agent context files"
FOUND=0
for f in AGENTS.md CLAUDE.md GEMINI.md .cursorrules .github/copilot-instructions.md opencode.json .mcp.json; do
  have "$f" && { echo "- $f"; FOUND=1; }
done
[ -d .cursor/rules ]   && { echo "- .cursor/rules/ ($(ls .cursor/rules | tr '\n' ' '))"; FOUND=1; }
[ -d .claude ]         && { echo "- .claude/ ($(ls .claude | tr '\n' ' '))"; FOUND=1; }
[ -d .opencode ]       && { echo "- .opencode/ ($(ls .opencode | tr '\n' ' '))"; FOUND=1; }
[ -d .icm ]            && { echo "- .icm/ (ICM manifest present — UPDATE mode candidate)"; FOUND=1; }
if have AGENTS.md && grep -q 'icm:managed' AGENTS.md 2>/dev/null; then
  echo "- AGENTS.md has icm:managed marker → run UPDATE mode"
fi
[ "$FOUND" -eq 0 ] && echo "- none (FRESH mode)"

# ---------- Room candidates ----------
section "Candidate rooms (top-level working folders)"
find . -maxdepth 1 -type d \
  ! -name '.*' ! -name node_modules ! -name dist ! -name build \
  ! -name coverage ! -name venv ! -name target \
  2>/dev/null | sed 's|^\./||' | grep -v '^\.$' | sort | while read -r d; do
  N=$(find "$d" -type f 2>/dev/null | head -500 | wc -l | tr -d ' ')
  echo "- $d/ ($N files)"
done

# ---------- README ----------
section "README (first 30 lines)"
for f in README.md readme.md README.rst README; do
  if have "$f"; then echo '```'; head -30 "$f"; echo '```'; break; fi
done

echo
echo "---"
echo "Scan complete. Next: present the Scan Summary to the user (ICM-BUILDER.md Phase 1),"
echo "then ask only the questions the scan could not answer (Phase 2)."
