# Exploration: Sprint 0 Scaffold — Clean Architecture, Design Tokens & PostgreSQL Replication

- **Change key**: `sprint-0-scaffold`
- **Date**: 2026-08-17
- **Sources**: `documento_maestro.md` (Sprint 0, lines 33–100), `arquitectura_y_algoritmos_ia.md` (section 1.1), `openspec/config.yaml`, repo tree, environment probe (Flutter/Docker availability)
- **Mode**: openspec (read-only exploration; no code, no manifests, no installs)

## Current State

Repo (`main`, single commit `98a4fc2`) contains **zero source code / manifests**:
- Tracked: `README.md`, `.gitignore`
- Untracked: `documento_maestro.md`, `arquitectura_y_algoritmos_ia.md`, `.atl/`, `openspec/` (bootstrap skeleton only — `config.yaml`, empty `specs/`, `changes/`, `changes/archive/`)
- `openspec/config.yaml`: `strict_tdd: false`; no test runner, linter, or coverage detected
- Environment: **Docker 29.4.3 + Compose v5.1.3 present; Flutter SDK NOT on PATH**

## Sprint 0 Requirements (verbatim from master doc)

1. Flutter monorepo scaffold under Clean Architecture:
   - `lib/core/theme/` (Design Tokens) — `lib/features/auth/` (presentation/bloc, domain/entities, domain/usecases, data/datasources, data/repositories) — `lib/features/loader/` (presentation + data for firmware injection)
2. `lib/core/theme/design_tokens.dart` with SafetyRed `#DC3545`, WarningYellow `#FFC107`, GovBlue `#0D6EFD`, SafeGreen `#198754`; tactile min 48dp touch targets
3. Root `docker-compose.yml`: `db_primary` (postgres:16, host port 5432) + `db_replica` (postgres:16, host port 5433, read replica simulating hybrid offline behavior)
4. `init-replication.sh` — automated physical streaming replication between the two containers
5. Acceptance (per doc's commit block): directory structure validated + `docker-compose up -d` initializes both containers with **active replication**; commit `feat(sprint-0): ... v0.0.0` + tag `v0.0.0`
6. Note: the doc's acceptance criteria do NOT require `flutter build/analyze` — only structure + Docker replication. "Listo para compilar" is aspirational wording, not a gate.

## Affected Areas (to be created by apply)

- `lib/core/theme/design_tokens.dart` — normative visual atoms (colors, spacing, tactile sizes)
- `lib/core/theme/app_theme.dart` — tokens → Flutter `ThemeData` (implied by architecture doc 1.1)
- `lib/features/auth/**` — Clean Architecture shells (bloc/entities/usecases/datasources/repositories) — stub/skeleton only in Sprint 0; real OIDC in Sprint 1
- `lib/features/loader/**` — presentation + data shells; real BLE in Sprint 2
- `docker-compose.yml` — db_primary (5432) + db_replica (5433)
- `init-replication.sh` — `pg_basebackup`-style physical streaming replica bootstrap
- `pubspec.yaml` + platform folders (android/windows) — required only if `flutter create` is run or hand-scaffolded
- `.gitignore` — currently a Flutter-framework-repo template; needs monorepo additions (docker volumes, .env, .venv, node_modules, database/)

## Conflicts / Decisions Detected

### C1. Two conflicting ground-truth folder layouts (must resolve in SPEC)
- Master doc (Sprint 0): feature-first — `lib/features/{auth,loader}/...` with `domain/usecases/`
- Architecture doc (1.1): layer-first — `lib/{core,data,domain,presentation}` with `presentation/modules/{ioc,studio,loader,toolbox}`
- **Recommendation (hybrid)**: `lib/core/{theme,network}` + `lib/features/{auth,ioc,studio,loader,toolbox}/` each with `presentation/`, `domain/`, `data/`. This satisfies both docs and scales to 5 interfaces. The arch doc tree lists only 4 modules but claims "Las 5 interfaces de tesis" — count discrepancy; SPEC should enumerate all 5 apps explicitly.

### C2. Backend language unpinned (Node/Express vs Python/FastAPI)
- Sprint 0 ships NO backend code, so this does not block Sprint 0 — but the choice affects future port conventions and docker-compose network layout.
- Evidence strongly favors **Python/FastAPI**: Sprints 3/5/6/7/9/10 are Python-native (`validate_ledger.py`, `data_sync_orchestrator.py`, `mcp_server.py` (FastMCP/Pydantic), `collect_telemetry.py`, pandas/numpy/matplotlib, stress tests). Only Sprint 2's SoD engine is neutral ("Node.js o Python").
- **Recommendation**: pin FastAPI in the Sprint 0 spec as the documented default (a one-line decision, zero code impact) with explicit rollback to Express if a future sprint justifies it.

### C3. Flutter SDK absent from this machine
- `flutter` command not found; Docker + Compose present. `flutter create`/`analyze` cannot run here.
- Sprint 0 acceptance per master doc does not require compilation (structure + Docker replication only) → **not blocked**.
- Mitigation options: (a) hand-scaffold folders + minimal `pubspec.yaml` and validate structure statically (matches doc acceptance), (b) install Flutter SDK in apply phase (user decision — doc forbids nothing, but the thesis machine may already have it elsewhere), (c) defer compile validation to Sprint 1 gate (`flutter build apk --debug` / `build windows --debug`).
- Spec must state exactly which option Sprint 0 uses so `sdd-verify` knows its validation commands.

### C4. `init-replication.sh` on Windows host
- Script is bash; host is PowerShell/Windows. Execution needs Git Bash / WSL, or run via `docker compose exec db_primary bash /init/init-replication.sh` (container has bash).
- **Recommendation**: write the script so it is idempotent and invoke it from inside the primary container (or via Git Bash); document the host-side invocation in the spec. Optionally provide a PowerShell wrapper that shells into the container.

### C5. Physical streaming replication details
- Official `postgres:16` image: replica bootstrapped via `pg_basebackup` (requires `wal_level=replica`, `max_wal_senders`, primary network reachability) or a volume copy. `pg_hba.conf` must allow replication user from replica.
- Alternative `bitnami/postgresql-repmgr` exists but adds proprietary auto-failover; master doc asks for plain physical streaming — stay with official image + custom init.
- Sprint 0 scope: **infrastructure + live replication only**. Hybrid offline sync logic is Sprint 5 — do not leak it into Sprint 0.

### C6. Ports & production posture
- 5432/5433 bound to host for dev. Risk: an existing local PostgreSQL service may already occupy 5432 on dev machines → compose up fails. Spec should treat port conflict as a known failure mode (document override via env, e.g. `POSTGRES_PORT`).
- Sprint 8 will close all DB ports behind a gateway — fine, out of scope now; just note dev-only exposure in compose comments.

### C7. Modern Docker Compose syntax
- Compose v5.1.3 (V2 plugin): the top-level `version:` key is obsolete and emits a warning. Spec must mandate `services:`-only compose file, pins `postgres:16` (minor-version pin decision: `16-alpine` vs `16.x`).

### C8. strict_tdd blocked until manifests exist
- Config correctly detects no manifests. After Sprint 0 apply (pubspec.yaml exists), re-run `sdd-init` to promote `strict_tdd: true` before Sprint 1. Sprint 0 verify = structure check + `docker compose up -d` + replication probe (`pg_isready` / `SELECT` on replica / `pg_stat_replication`), plus optional `flutter analyze` only if SDK present.

## Approaches

1. **Full scaffold (`flutter create` + clean-arch folders + compose + script)** — Effort: Medium. Pros: real pubspec/platform folders, compiles-ready. Cons: requires Flutter SDK on machine (absent — install decision), generated boilerplate noise. Validation: SDK-dependent.
2. **Hand-scaffold (folders + minimal pubspec + compose + script, static validation)** — Effort: Low-Medium. Pros: matches master doc acceptance exactly (structure + Docker replication), no SDK needed, review-friendly. Cons: `pubspec.yaml` written by hand must be exact for Sprint 1; no compile proof until SDK appears. Validation: path/structure assertions + `docker compose up -d` + replication probe.
3. **Defer Flutter entirely; Sprint 0 = Docker only** — Rejected: violates master doc Sprint 0 scope (structure + design_tokens are explicit deliverables).

**Recommendation**: Approach 2 as the Sprint 0 body, with a conditional apply step IF Flutter SDK becomes available (then run `flutter create` to materialize platform folders). Enumerate exact folder paths and design_tokens values in the spec so verify can assert them.

## Risks

- Flutter SDK absence → no compile/analyze proof in Sprint 0 (acceptance doc doesn't require it; Sprint 1 does — SDK install must be resolved before Sprint 1).
- Local port 5432 conflict (existing PostgreSQL on dev machine) → compose up failure; document override.
- Bash script on Windows host → invocation path ambiguity; must be defined in spec.
- Layout conflict (C1) unresolved → structural churn in later sprints if fixed wrong; resolve in SPEC.
- Backend language drift (C2) → port/network convention churn at Sprint 2; pin now (cheap).
- `v0.0.0` tag + `feat(sprint-0)` commit per master doc; repo already `git init`'d — doc's `git init` line is a no-op, do not re-init.

## Ready for Proposal

**Yes.** Scope is crisp and doc-defined. The SPEC phase must first resolve C1 (folder layout) and C2 (backend language pin), then enumerate: exact `lib/` folder tree, design token constants, compose services/healthchecks/volumes, replication bootstrap steps, and conditional Flutter-SDK step. Recommend proposal title/existing key: `sprint-0-scaffold` (matches orchestrator-assigned change key).