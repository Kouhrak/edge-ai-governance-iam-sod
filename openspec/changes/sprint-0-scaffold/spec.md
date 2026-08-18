# Sprint 0 Scaffold Specification

**Change**: `sprint-0-scaffold` · **Type**: initial spec — all content ADDED (no prior `openspec/specs/`) · **Sources**: `documento_maestro.md` Sprint 0, `arquitectura_y_algoritmos_ia.md` §1.1, `exploration.md` C1–C8

## Purpose

Sprint 0 creates the reproducible base: Flutter Clean Architecture monorepo shell, normative design tokens, Docker PostgreSQL primary/replica pair with active streaming replication. User story (master doc): *Como Ingeniero de Ciberseguridad, quiero inicializar el monorepo Flutter bajo Clean Architecture, configurar los Design Tokens normativos y levantar la réplica PostgreSQL en Docker, para heredar las restricciones SoD en todas las interfaces.*

## Requirements

### Requirement: Hybrid Feature Tree (resolves C1)

The system SHALL scaffold a hybrid tree (master doc feature-first + architecture doc layer-first): `lib/core/{theme,network}/` plus `lib/features/` with exactly 5 shells — **auth**, **ioc**, **studio**, **loader**, **toolbox** — each with `presentation/`, `domain/`, `data/`. Sprint 0 SHALL create: auth's full sub-structure (presentation/bloc, domain/entities, domain/usecases, data/datasources, data/repositories); loader's presentation + data layers; ioc/studio/toolbox as empty shells (populated in Sprints 1/4/6). Auth = federated OIDC identity, ioc = admin console, studio = desktop templates, loader = BLE firmware, toolbox = plant SLM assistant.

#### Scenario: All 5 shells exist

- GIVEN the repo root
- WHEN apply completes
- THEN `lib/features/{auth,ioc,studio,loader,toolbox}/` each contain `presentation/`, `domain/`, `data/`

### Requirement: Design Tokens

`lib/core/theme/design_tokens.dart` SHALL define: SafetyRed `#DC3545` (SoD lockouts), WarningYellow `#FFC107` (calibration warnings), GovBlue `#0D6EFD` (AI agent), SafeGreen `#198754` (authorized access). Touch targets SHALL be ≥48dp (industrial tablets). `lib/core/theme/app_theme.dart` SHALL map tokens to `ThemeData`.

#### Scenario: Token values asserted

- GIVEN design_tokens.dart
- WHEN verify reads constants
- THEN hex values match exactly and tactile constant ≥48dp

### Requirement: Docker Compose Postgres Pair

Root `docker-compose.yml` SHALL define exactly two services with NO top-level `version:` key: `db_primary` (postgres:16-alpine, host port 5432) and `db_replica` (postgres:16-alpine, host port 5433, read replica simulating hybrid offline behavior). Both SHALL declare `pg_isready` healthchecks and named volumes; ports dev-only, overridable via env (`POSTGRES_PORT`).

#### Scenario: Port 5432 collision (failure mode)

- GIVEN a local service already occupies 5432
- WHEN `docker compose up -d` fails
- THEN override via `POSTGRES_PORT` env per compose comments
- AND no code/secret change is required

### Requirement: Replication Bootstrap

`init-replication.sh` SHALL bootstrap physical streaming replication idempotently: create `REPLICATION LOGIN` user on primary; set `wal_level=replica`, `max_wal_senders`, `max_replication_slots`; authorize replica host in `pg_hba.conf`; `pg_basebackup -R`; start replica; probe `pg_stat_replication`. Windows invocation: inside the container — `docker compose exec db_primary bash /init/init-replication.sh` (or Git Bash) — never directly in PowerShell.

#### Scenario: Streaming active

- GIVEN both containers healthy and script executed
- WHEN a row is inserted on db_primary
- THEN it is readable on db_replica and pg_stat_replication shows `state=streaming`

### Requirement: Conditional Flutter SDK Step

Sprint 0 SHALL hand-scaffold the tree plus a minimal `pubspec.yaml` (no Flutter SDK on machine). IF the SDK appears, apply MAY run `flutter create` for platform folders. Acceptance = structure + replication probe, NOT compile; `flutter build/analyze` MUST NOT gate Sprint 0.

#### Scenario: SDK absent

- GIVEN `flutter` not on PATH
- WHEN apply runs
- THEN hand-scaffold succeeds; verify uses static structure assertions + Docker probe only

### Requirement: Backend Language Pin (resolves C2)

The backend SHALL default to Python/FastAPI (Sprints 3/5/6/7/9/10 are Python-native); Node/Express is the documented rollback. Zero code impact in Sprint 0.

### Requirement: Inputs, Outputs, Constraints

Inputs: master doc Sprint 0, architecture doc §1.1, exploration.md. Outputs: `lib/**` tree, `docker-compose.yml`, `init-replication.sh`, updated `.gitignore` (docker volumes, `.env`, `.venv`), compose up with active replication. Constraints: replication credentials via env only — no secrets hardcoded in compose; tokens carry security semantics (visual layer must not alter SoD logic); commit `feat(sprint-0): ... v0.0.0` + tag `v0.0.0`.

### Requirement: Acceptance Scenarios

Acceptance mirrors the master doc commit block (see scenarios below). NOT `flutter build`.

#### Scenario: Acceptance (a) — structure

- GIVEN apply complete
- WHEN tree validated
- THEN all paths from the Hybrid Feature Tree and Design Token requirements exist

#### Scenario: Acceptance (b) — replication

- GIVEN `docker compose up -d` succeeds
- WHEN probes run (`pg_isready` both; `pg_stat_replication` on primary; SELECT on replica)
- THEN both services healthy and replication streaming

### Requirement: SDD Process State

`strict_tdd` SHALL stay false until `pubspec.yaml` exists; SHALL re-run `sdd-init` after Sprint 0 (promote `strict_tdd: true` before Sprint 1). MUST NOT re-run `git init` (repo already initialized; master doc line is a no-op).