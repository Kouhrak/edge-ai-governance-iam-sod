# Tasks: Sprint 0 Scaffold

Order: design 1→8. Commits: `feat(sprint-0): ...`, tag `v0.0.0` (COMMIT phase).

## Review Workload Forecast

| Field | Value |
|---|---|
| Estimated changed lines | ~320 (290–370) |
| 400-line budget risk | Medium |
| Chained PRs recommended | No |
| Suggested split | Single PR — 10 work-unit commits |
| Delivery strategy | ask-always |
| Chain strategy | pending |

Decision needed before apply: No
Chained PRs recommended: No
Chain strategy: pending
400-line budget risk: Medium

Riskiest artifact: `init-replication.sh` (~120 lines). Monitor diff before PR. Second risk: `opencode.json` contains sensitive token — MUST be gitignored.

### Work Units (commits, one PR)

| # | Commit | # | Commit |
|---|---|---|---|
| 1 | Flutter tree + `.gitkeep` | 5 | docker-compose.yml |
| 2 | tokens + theme | 6 | init-replication.sh |
| 3 | pubspec.yaml | 7 | `.env` (gitignored) |
| 4 | .gitignore + .env.example | 8 | smoke (result only) |
| 9 | opencode.json + Penpot MCP | 10 | .gitignore (opencode.json) |

## Phase 1: Flutter hybrid tree

- [ ] 1.1 Create `lib/core/{theme,network}` + `lib/features/{auth,ioc,studio,loader,toolbox}/{presentation,domain,data}` with `.gitkeep` in empty leaves (network, ioc/studio/toolbox) — git ignores dirs (D-07). Done: "All 5 shells exist".
- [ ] 1.2 Auth full: `lib/features/auth/{presentation/bloc,domain/entities,domain/usecases,data/datasources,data/repositories}` + `.gitkeep`. Done: acceptance (a).
- [ ] 1.3 Loader: `lib/features/loader/{presentation,data}` + `.gitkeep`; ioc/studio/toolbox stay shells. Done: acceptance (a).

## Phase 2: Visual atoms

- [ ] 2.1 `lib/core/theme/design_tokens.dart`: SafetyRed `0xFFDC3545`, WarningYellow `0xFFFFC107`, GovBlue `0xFF0D6EFD`, SafeGreen `0xFF198754`, `tactileMinSize=48.0`. Done: "Token values asserted" (exact hex, ≥48dp).
- [ ] 2.2 `lib/core/theme/app_theme.dart`: `AppTheme.light()` → `ThemeData` (primary=govBlue, secondary=warningYellow, error=safetyRed, tertiary=safeGreen; ≥48×48 tap targets). Done: §3.2 mapping.

## Phase 3: Minimal pubspec

- [ ] 3.1 `pubspec.yaml`: hand-written §3.3 (name `edge_ai_governance_iam_sod`, publish_to: none, version 0.0.0, sdk `">=3.5.0 <4.0.0"`, flutter sdk, flutter_lints ^4.0.0). Done: "SDK absent". Gotchas: NO `pub get`/`create` (conditional `flutter create` only if SDK appears); `strict_tdd` stays false; no `git init` re-run.

## Phase 4: Repo hygiene + env contract

- [ ] 4.1 `.gitignore`: append `.env`, `.venv/`, `node_modules/`, `database/`; keep Flutter template. Done: env never committed.
- [ ] 4.2 `.env.example`: POSTGRES_USER/PASSWORD/DB, REPLICATION_USER/PASSWORD, POSTGRES_PORT=5432, POSTGRES_REPLICA_PORT=5433 (dev placeholders). Done: env contract §7.

## Phase 5: Docker replication stack

- [ ] 5.1 `docker-compose.yml`: services-only (NO `version:` key); both postgres:16-alpine; GUCs via `command:` flags (wal_level=replica, max_wal_senders=10, max_replication_slots=10); `POSTGRES_PASSWORD:?`/`REPLICATION_PASSWORD:?` env-only; named volumes; ports `${POSTGRES_PORT:-5432}`/`${POSTGRES_REPLICA_PORT:-5433}` (dev-only); `pg_isready` healthchecks, `$$`-escaped; replica `command: bash /init/init-replication.sh --replica` + `depends_on: db_primary: condition: service_healthy` (load-bearing). Done: "Port 5432 collision" (env override).
- [ ] 5.2 `init-replication.sh`: dual-mode idempotent — `--replica`: wait pg_isready → `pg_controldata` guard → `rm -rf "$PGDATA"/*` → `pg_basebackup -R -X stream` → `exec postgres`; default: `is_in_recovery` guard → streaming guard (exit 0) → `CREATE ROLE` if missing → GUC preflight → pg_hba recompute per run (`getent hosts db_replica` → replace → append → `pg_reload_conf`) → 60s probe. Done: "Streaming active". Gotchas: pg_hba idempotent, NOT one-shot append; invoke `docker compose exec db_primary bash /init/init-replication.sh`, never PowerShell.

## Phase 6: Env + smoke

- [ ] 6.1 Copy `.env.example` → `.env` (`Copy-Item`; gitignored). Done: `:?` vars resolve — `.env` MUST exist before compose up.
- [ ] 6.2 Smoke: `docker compose up -d` → both healthy → bootstrap (re-run exits 0) → `pg_stat_replication`=streaming → INSERT primary → SELECT replica; optional `POSTGRES_PORT=55432`. Done: acceptance (b). No build/analyze gate.

## Phase 7: Penpot MCP integration

- [ ] 7.1 `opencode.json`: Add Penpot MCP server configuration (`type: "remote"`, URL with userToken). Done: MCP server enabled for design-to-code workflow.
- [ ] 7.2 `.gitignore`: Append `opencode.json` to prevent committing sensitive tokens. Done: token security.

## Scenario → Tasks (verify traceability)

| Scenario | Tasks |
|---|---|
| All 5 shells exist | 1.1 |
| Token values asserted | 2.1 |
| Port 5432 collision | 5.1, 6.2 |
| Streaming active | 5.1, 5.2, 6.1, 6.2 |
| SDK absent | 1.1–1.3, 3.1 |
| Acceptance (a) | 1.1, 1.2, 1.3, 2.1, 2.2, 3.1 |
| Acceptance (b) | 5.1, 5.2, 6.1, 6.2 |
| SDD process state | 3.1 (strict_tdd false; no `git init`) |
| Penpot MCP connected | 7.1, 7.2 |
