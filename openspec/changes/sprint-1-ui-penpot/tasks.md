# Tasks: Sprint 1 UI Penpot — Penpot-driven UI, Platform Gates & Atomic Design

Order: design WS1→6. Commits: `feat(sprint-1): ...`, tag `v0.1.0` (COMMIT phase). Tests: package import `package:edge_ai_iam_sod/...`; commands `flutter analyze`, `flutter test`.

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | ~3000 (2700–3400) |
| 400-line budget risk | High |
| Chained PRs recommended | Yes |
| Suggested split | 5 chained PRs (below) |
| Delivery strategy | ask-on-risk (default — not passed) |
| Chain strategy | pending |

Decision needed before apply: Yes
Chained PRs recommended: Yes
Chain strategy: pending
400-line budget risk: High

### Work Units

| # | Unit | PR | Notes |
|---|------|----|-------|
| 1 | Foundation — tokens, platform, policy, gate (WS1–2) | PR 1 | ~500 lines; additive; unit+bloc tests |
| 2 | Design system — 16 widgets + `ble_device` (WS3) | PR 2 | ~1300 lines, largest; split atoms+molecules / organisms if over budget |
| 3 | IOC web — login + dashboard shell + 4 sections (WS4) | PR 3 | ~800; base PR 2 |
| 4 | Loader + Studio + main wiring (WS5) | PR 4 | ~730; base PR 3 (main routes IOC pages) |
| 5 | Test rewrites + cleanup (WS6) | PR 5 | ~250 net; base PR 4 |

## Phase 1: Tokens + platform detector (WS1)

- [x] 1.1 [M] `lib/core/theme/design_tokens.dart` — Penpot palette (§3.1): govBlue→#FC7E6C, safetyRed→#D32F2F, warningYellow→#B7BE3A, safeGreen→#00A461, surfaceCream #FFF3D8, surfaceTan #E5BE9D, space/radius/text scales, tactileMinSize=48. Update `test/core/theme/design_tokens_test.dart` hex assertions+scales (verify: token test green — do together so suite never red).
- [x] 1.2 [S] `lib/core/theme/app_theme.dart` — `scaffoldBackgroundColor: surfaceCream`; keep primary/secondary/error/tertiary token mappings; refresh comments.
- [x] 1.3 [S] `lib/core/platform/platform_type.dart` (NEW, pure Dart, no imports) — `enum PlatformType {web, desktop, mobile}`.
- [x] 1.4 [S] `lib/core/platform/platform_detector.dart` (NEW) — foundation.dart ONLY (no dart:io): kIsWeb→web; defaultTargetPlatform windows/macOS/linux/fuchsia→desktop, android/iOS→mobile; re-export `platform_type.dart`.
- [x] 1.5 [S] `test/core/platform/platform_detector_test.dart` (NEW) — `debugDefaultTargetPlatformOverride` mapping (web/desktop/mobile), reset in teardown (verify: `flutter test test/core/platform`).

Deps: 1.3←1.4←1.5; 1.1/1.2 independent.

## Phase 2: Policy + gate (WS2)

- [ ] 2.1 [M] `lib/features/auth/domain/policies/feature_access.dart` (NEW, pure Dart) — `Feature{ioc,studio,loader}`; matrix admin/super→ioc/web, tecnico→studio/desktop, operador→loader/mobile, externo→none; `resolveFeature(UserRole)` + `isLoginAllowed(UserRole, PlatformType)`. + `test/features/auth/domain/policies/feature_access_test.dart` (NEW): 4 roles × platforms + externo denied everywhere.
- [ ] 2.2 [S] `lib/features/auth/data/datasources/auth_mock_datasource.dart` — `ext` user `active: true` (D-08: policy is single denial point).
- [ ] 2.3 [M] `lib/features/auth/presentation/bloc/auth_bloc.dart` — add `PlatformBlocked{user, reason}` state + `TokenLoginRequested{token}` event; ctor-injected `PlatformResolver` (default `PlatformDetector.currentPlatform`); gate `isLoginAllowed` after parse, before `Authenticated`; token handler parses claims via `_parseJwtPayload` + same gate, invalid token→`AuthError`.
- [ ] 2.4 [M] `test/features/auth/presentation/bloc/auth_bloc_test.dart` (NEW) — bloc_test with injected resolver: allowed→Authenticated; denied→PlatformBlocked; externo→PlatformBlocked; bad creds→AuthError; token login; logout→Unauthenticated (valid mock JWT from datasource `authenticate` output).
- [ ] 2.5 [S] `lib/features/auth/presentation/widgets/platform_blocked_view.dart` (NEW) — `{username, message, onLogout}`: lock icon, message, AppButton "Cerrar Sesión". + widget test (message + logout fires callback).

Deps: Phase 1 → 2.1 → 2.3; 2.2 independent; 2.5 after widgets.

## Phase 3: Shared widgets — 16 components (WS3)

- [ ] 3.1 [S] `lib/features/loader/domain/entities/ble_device.dart` (NEW, pure Dart) — `BleDevice{name, mac, model, family, hardware, connectionState(enum), modifiedBy, voltage, temperature, authorized, licenseExpired}`. Pulled ahead of design WS5: DeviceCard/DeviceDetailPanel depend on it.
- [ ] 3.2 [M] atoms ×5 — `{app_button, app_text_field, status_badge, token_chip, progress_bar}.dart` per §3.6 contracts (≥48dp, loading spinner, tone badges).
- [ ] 3.3 [M] `molecules/login_form.dart` — `LoginVariant{userPassword, token}`; controlled (no bloc import); local Form validation; inline errorMessage via StatusBadge danger; both submit callbacks.
- [ ] 3.4 [M] molecules ×5 — `{stat_card, nav_item, checklist_card, device_card, page_header}.dart` per §3.7.
- [ ] 3.5 [M] organisms ×5 — `{side_navigation, top_bar, data_table, action_bar, device_detail_panel}.dart` per §3.8 (nav items list, generic DataTable column/row contracts).
- [ ] 3.6 [M] `test/core/widgets/widgets_test.dart` (NEW) — render + callbacks + ≥48dp tap targets for shared components.

Deps: 3.1→3.4/3.5; 3.2→3.3; 3.6 last.

## Phase 4: IOC web (WS4)

- [ ] 4.1 [S] `lib/features/ioc/presentation/pages/ioc_login_page.dart` (NEW) — LoginForm(userPassword) + BlocConsumer (AuthError→errorMessage).
- [ ] 4.2 [M] `lib/features/ioc/presentation/pages/ioc_dashboard_page.dart` — refactor to shell: SideNavigation (Dashboard/Gestión de Accesos/Personal y Accesos/Gestion de eventos), TopBar, IndexedStack, logout→`LogoutRequested` (D-10, D-13). Keep `currentUser:` ctor (main.dart still routes here until 5.5).
- [ ] 4.3 [M] `sections/dashboard_section.dart` (NEW) — StatCard×4 métricas, DataTable registros autorizados, alertas bloqueados (StatusBadge danger), static 7-bar traffic placeholder.
- [ ] 4.4 [M] `sections/{access_management, personal_accesses, events}_section.dart` (NEW) — users DataTable; usuario institucional + equipos (DeviceCard) + Estatus Global + Acciones Maestras (Vincular → SnackBar placeholder); "En desarrollo" card.

Deps: 3.3→4.1; 3.4/3.5→4.2–4.4.

## Phase 5: Loader mobile + Studio desktop + main wiring (WS5)

- [ ] 5.1 [S] `lib/features/loader/presentation/pages/loader_login_page.dart` (NEW) — LoginForm(token) → `TokenLoginRequested`.
- [ ] 5.2 [M] `scan_page.dart` + `connecting_page.dart` (NEW) — "Buscar dispositivos", DeviceCard list (mock PLC MACs like `C1:51:53:9E:6A:17`), Escaneando…/Cancelar; tap → ConnectingPage (ProgressBar, auto-advance → detail).
- [ ] 5.3 [S] `device_detail_page.dart` + `license_expired_page.dart` (NEW) — DeviceDetailPanel; if `licenseExpired` → license-expired screen (AppButton back).
- [ ] 5.4 [M] `lib/features/studio/presentation/pages/{studio_login_page, studio_page}.dart` (NEW) — userPassword login ("INICIAR SESION"); scan: TopBar "Studio", Escanear toggle (disabled while scanning), DataTable dispositivos (Estado badge, Puerto, Adaptador, Editar/Validación/Despliegue/Conectar), mock list.
- [ ] 5.5 [L] `lib/main.dart` — delete inline `LoginPage`; AuthWrapper §2c: loading spinner → blocked (`state is PlatformBlocked` OR `Authenticated && !isLoginAllowed`) → `PlatformBlockedView(onLogout: LogoutRequested)`; allowed → `resolveFeature` (ioc→IocDashboardPage, studio→StudioPage, loader→LoaderScanPage); unauthenticated → platform login router (web→IocLoginPage, desktop→StudioLoginPage, mobile→LoaderLoginPage).

Deps: 3.x→5.1–5.4; 5.5 requires 4.1, 4.2, 5.1–5.4.

## Phase 6: Test rewrites + cleanup (WS6)

- [ ] 6.1 [S] Delete `lib/features/loader/presentation/pages/checklist_page.dart` (unreferenced after 5.5; ChecklistCard molecule retained).
- [ ] 6.2 [M] Rewrite `test/widget/login_form_test.dart` — drive real shared LoginForm, both variants, validation, ≥48dp; remove local fake.
- [ ] 6.3 [M] `test/widget/auth_wrapper_test.dart` (NEW) — routing matrix + gate via real bloc + `debugDefaultTargetPlatformOverride`: admin/mobile blocked, operador/mobile→Loader, tecnico/desktop→Studio; logout round-trip.
- [ ] 6.4 [M] Rewrite `integration_test/auth_integration_test.dart` — force `TargetPlatform.windows`: admin blocked, tecnico→Studio; force `android`: operador→Loader; replace non-existent keys.
- [ ] 6.5 [S] Final gate — `flutter analyze` clean; `flutter test` green; static scan: no `dart:io` on web paths.

Deps: 5.5→6.1–6.3; 6.4 after 5.x; 6.5 last.

## Scenario → Tasks

| Scenario | Tasks |
|---|---|
| Token hexes + tactile | 1.1 |
| Detector web/desktop/mobile + no dart:io | 1.3–1.5, 6.5 |
| Policy matrix + externo | 2.1 |
| Bloc gate + externo + bad creds | 2.2–2.4 |
| Wrapper defense-in-depth + logout + routing | 5.5, 6.3 |
| LoginPage extracted; shared reuse | 3.2–3.6, 4.x, 5.x |
| IOC/Studio/Loader screens per Penpot | 4.1–4.4, 5.1–5.4 |
| Test rewrites green | 6.2, 6.4, 6.5 |
