# Exploration: Sprint 1 UI Penpot — Penpot-driven UI, Platform Gates & Atomic Design

- **Change key**: `sprint-1-ui-penpot`
- **Date**: 2026-08-18
- **Mode**: hybrid (exploration.md + Engram `sdd/sprint-1-ui-penpot/explore`)
- **Sources**: Penpot MCP live design (4 pages), `app/lib/main.dart`, `app/lib/features/auth/**`, `app/lib/features/ioc/presentation/pages/ioc_dashboard_page.dart`, `app/lib/features/loader/presentation/pages/checklist_page.dart`, `app/lib/core/theme/{design_tokens,app_theme}.dart`, `app/pubspec.yaml`, `app/test/**`, `app/integration_test/auth_integration_test.dart`, `arquitectura_y_algoritmos_ia.md` §1.1, `documento_maestro.md` Sprints 0–4, `openspec/changes/sprint-0-scaffold/*`, git log (5 commits, `feat(sprint-1)` in progress)

---

## 1. Penpot Designs — What They Contain (MCP access: AVAILABLE)

Connected Penpot project exposes **4 pages**. Page names map 1:1 to the three UIs plus a logo asset:

| Penpot page | Target UI | Screens (boards) found |
|---|---|---|
| **`web`** (1440×960) | **IOC — Identity Orchestrator Center** | `Login` (Usuario / Contraseña / Iniciar Sesión), `Home` (Dashboard, Métricas Globales de acceso, Gestión de Accesos, SuperUsuario/Usuario_1 header, Registros de entradas Autorizadas, Alertas de Seguridad (Bloqueados), Tráfico de Aplicaciones últimos 7 días), `Personal y Accesos` (Usuario Institucional, Equipos vinculados, Estatus Global, Acciones Maestras), `Gestion de eventos` ("En desarrollo" placeholder), `Ventana1` (modal "Directorio de Personal": Guardar Cambios, Vincular Studio (Windows), Vincular (Android), Configuración) |
| **`escritorio`** (1440×960) | **Studio — Windows desktop** | `Login` (Usuario / Contraseña / INICIAR SESION / Acceder), `ScanScreen` (Buscar Dispositivos Bluetooth, Estado, Editar, Validación, Despliegue, Conectar, Desconectar, Escanear, Puerto, Adaptador, header "Studio") |
| **`movile`** (360×780) | **Loader — mobile BLE** | Scan (`Buscar dispositivos`, `Dispositivos cercanos`, PLC cards with MAC `C1:51:53:9E:6A:17`, Escaneando…/Cancelar), `Conectando…`, `Home` (device detail: Familia/Modelo CIL3 068930, Estado de conexión: Conectado, Hardware CIR2017, Dirección MAC, Nombre de dispositivo, Modificada por: Superusuario, Voltaje/Temperatura, Autorizada/Congelada), `Login` (token/id based — **different from web/desktop user+password**), license-expired screen |
| **`Page 1`** | Asset | `Isoiipo` logo (670×443, paths+image) |

**Design library**: NO components, NO typographies, 7 ad-hoc local colors. Raw shapes only.

**Palette conflict (CRITICAL)**: dominant fills are coral `#fc7e6c` (207 uses), cream `#fff3d8`, tan `#e5be9d`, olive `#b7be3a`, green `#00a461`/`#22bd23`, red `#d32f2f`/`#c80f1f`. Flutter `DesignTokens` are govBlue `#0D6EFD`, safetyRed `#DC3545`, warningYellow `#FFC107`, safeGreen `#198754`. **The Penpot design does NOT use the normative tokens** — semantic greens/reds are close (status/safety) but the primary brand color is coral, not govBlue. Must be resolved before implementation (see Risks R1).

---

## 2. Current State

- **Routing** (`main.dart`): `AuthWrapper` BlocBuilder — `Authenticated` → `administrador|superUsuario` → `IocDashboardPage`, everything else → `ChecklistPage` (Loader). `LoginPage` is a 200-line widget **inline in main.dart**. No router package; no named routes.
- **Auth flow**: `AuthBloc` (flutter_bloc 8.1.3) — events `LoginRequested|LogoutRequested|AuthCheckRequested`; states `AuthInitial|AuthLoading|Authenticated|Unauthenticated|AuthError`. `LoginRequested` calls `AuthMockDataSource.authenticate` (mock OIDC, generates unsigned JWT, 3 users: admin/tech/oper + inactive `ext`), parses claims into `UserIdentity`. `AuthCheckRequested` always emits `Unauthenticated` (no persistence — **flutter_secure_storage was removed** due to ATL build break on Windows). `UserRole`: superUsuario, administrador, tecnico, operador, externo. `AuthBloc` hardcodes the datasource (no repository abstraction/DI).
- **UI code today**: single-file pages, all styling inlined — IOC (`ioc_dashboard_page.dart`, 569 lines: side nav, stat cards, users table, activity list, role colors) and Loader (`checklist_page.dart`, 362 lines: tactile checklist cards, progress bar, warning banner, action bar). Both consume `DesignTokens` directly; **no shared widgets exist** (`lib/core/` has only `theme/`; no `core/widgets`, no `shared/`). Duplicated patterns: login form, header bars, cards, badges, nav items.
- **Features present**: `features/{auth,ioc,loader}` only. **`features/studio/` and `features/toolbox/` DO NOT EXIST** (sprint-0 design planned 5 shells, but the sprint-1 `flutter create` restart materialized only 3). User prompt said studio "has .gitkeep placeholders" — that is stale; the folder is absent.
- **Platforms**: `app/.metadata` → android, web, windows. No platform detection anywhere (`kIsWeb`/`defaultTargetPlatform` unused).
- **Tests**: `test/core/theme/design_tokens_test.dart` (token hex + ≥48dp assertions, good). `test/widget/login_form_test.dart` is **stale** — tests a local fake `LoginForm` (strings 'Username'/'Password'), not the app's login. `integration_test/auth_integration_test.dart` is **aspirational** — references keys/widgets that don't exist ('Loader', 'Studio Admin', `username_field`, `inject_firmware_button`).
- **Conventions**: per-sprint commits `feat(sprint-N): ... v0.1.0` + tag. `openspec/config.yaml` rules: Spanish docs, English code/identifiers/UI strings, design tokens normative, security implications (SoD/IAM) MUST be stated when touching auth/roles. Testing strategy doc: `test/widget/*_widget_test.dart`, golden_toolkit planned, ≥80% unit coverage.

---

## 3. Affected Areas

| File | Why |
|---|---|
| `app/lib/main.dart` | AuthWrapper role routing + platform gate UI + LoginPage extraction out of main |
| `app/lib/features/auth/presentation/bloc/auth_bloc.dart` | Gate state (if BLoC-approach) + platform check on LoginRequested |
| `app/lib/features/auth/domain/entities/user_identity.dart` | Extend `UserRole` with feature/platform access capability (or new policy file) |
| `app/lib/features/auth/domain/policies/feature_access.dart` (NEW) | Pure-Dart role→feature→allowed-platform policy (unit-testable) |
| `app/lib/core/platform/platform_detector.dart` (NEW) | `kIsWeb` + `defaultTargetPlatform` abstraction (web-safe, testable via `debugDefaultTargetPlatformOverride`) |
| `app/lib/core/widgets/{atoms,molecules,organisms}/` (NEW) | Global Atomic Design system shared by all 3 UIs (see §5) |
| `app/lib/core/theme/design_tokens.dart` / `app_theme.dart` | Palette reconciliation with Penpot (R1); new tokens (spacing/typography/radius) needed for fidelity |
| `app/lib/features/ioc/presentation/pages/ioc_dashboard_page.dart` | Refactor to shared components + Penpot web layout (Dashboard/Personal y Accesos/Eventos) |
| `app/lib/features/loader/presentation/pages/checklist_page.dart` | Refactor to shared components + Penpot mobile flow (scan → connect → device detail) |
| `app/lib/features/studio/**` (NEW) | Folder does NOT exist — full feature scaffold needed if Studio screens are in scope (Sprint 4 per master doc; Penpot desktop design exists) |
| `app/pubspec.yaml` | No new runtime deps expected (kIsWeb is in `flutter/foundation.dart`); maybe `golden_toolkit` dev dep |
| `app/test/**`, `app/integration_test/auth_integration_test.dart` | New policy/widget tests; stale tests must be rewritten |

---

## 4. Approaches — Platform Gate (login restrictions)

All options use `kIsWeb` + `defaultTargetPlatform` from `package:flutter/foundation.dart` — the **only web-safe** detection (dart:io `Platform` crashes web builds).

**Proposed role→feature→platform matrix** (NOT codified in ground-truth docs — needs user confirmation, see Risks R4):

| Feature | Roles | Allowed platforms |
|---|---|---|
| IOC | administrador, superUsuario | **web** only |
| Studio | tecnico (operador/externo read-only per Sprint 4) | **windows** only |
| Loader | tecnico, operador | **android** only |
| externo | — | no feature (inactive in mock) |

1. **Route-level gate only (in `AuthWrapper`)** — after `Authenticated`, resolve target feature from role, check platform, render `UnsupportedPlatformPage` (uses tokens; message + logout) when mismatch.
   - Pros: minimal change, pure presentation, trivially widget-testable.
   - Cons: login itself succeeds on wrong platform (UX/security smell); policy lives in the view layer; every new route must remember the check.
   - Effort: **Low**.

2. **BLoC-level gate (reject login)** — during `LoginRequested`, resolve role from claims, check allowed platform, emit `AuthError`/new `PlatformBlocked` state when denied.
   - Pros: security decision in the business layer; single enforcement point; bloc-testable with `bloc_test`.
   - Cons: changes `AuthState` contract (new state, UI must handle it); platform detection must be injected or overridden in tests; blocks even read-only fallback flows.
   - Effort: **Medium**.

3. **Hybrid — domain policy + dual enforcement (RECOMMENDED)** — pure-Dart `feature_access.dart` (role→feature, feature→platforms) in `auth/domain/policies/`; gate applied in BOTH `AuthBloc` (deny login on wrong platform → `AuthError` with clear message) AND `AuthWrapper` (defense-in-depth, friendly screen + logout for already-authenticated sessions on wrong platform).
   - Pros: single source of truth, unit-testable policy (no Flutter imports), security-first (deny at login) + UX fallback (route guard); survives session-persistence changes later.
   - Cons: slightly more surface (policy file + bloc state + wrapper branch); must keep policy and wrapper in sync (mitigate: wrapper reads the same policy).
   - Effort: **Medium** (~2 new files + auth_bloc/main.dart edits + tests).

**Recommendation: Approach 3.** It matches the thesis principle "the visual layer MUST NOT alter security semantics": access policy is domain logic, the UI only reports it. Effort is only marginally above Approach 1 and it is the only one that actually prevents the disallowed login, satisfying the user's "must NOT be able to log in" requirement.

---

## 5. Recommended Folder Structure — Atomic Design + feature-first hybrid

The architecture doc puts `design_system/{atoms,molecules,organisms}` under `presentation/`; the actual code is feature-first with `core/theme` as the shared visual layer. Recommendation: **global shared design system in `core/widgets/`, feature views inside each feature** (matches existing hybrid and sprint-0 D-01 decision):

```
app/lib/core/
  theme/                     # existing tokens + theme (extended)
  platform/
    platform_detector.dart   # kIsWeb + defaultTargetPlatform + debug override
  widgets/                   # NEW — GLOBAL design system (all 3 UIs)
    atoms/                   # AppButton, AppTextField, StatusBadge, TokenChip, ProgressBar, ...
    molecules/               # LoginForm (extracted from main.dart), StatCard, NavItem, ChecklistCard, PageHeader, ModalShell, ...
    organisms/               # SideNavigation (IOC), TopBar, DataTable, ActionBar, DeviceDetailPanel, ...
app/lib/features/
  auth/…                     # + domain/policies/feature_access.dart
  ioc/presentation/pages/    # feature-specific pages composed from shared organisms (Penpot web layout)
  loader/presentation/pages/ # scan/connect/device-detail pages (Penpot mobile layout)
  studio/presentation/pages/ # NEW — only if Studio screens are in scope (Penpot desktop layout)
```

Mapping to atomic levels: tokens→`core/theme`, atoms/molecules/organisms→`core/widgets`, templates→feature `presentation/pages`, pages→feature screens. Views/screens stay INSIDE each feature section exactly as the user requested.

---

## 6. Other Decisions the Proposal/Spec Must Resolve

- **D1 — Palette conflict**: re-tokenize Penpot to match Flutter tokens (design change), update `DesignTokens` to the Penpot palette (normative token change — conflicts with master doc's stated color semantics: yellow=warnings, red=SoD lockouts, blue=AI), or map Penpot colors onto tokens semantically. Recommend: keep tokens normative (master doc), treat Penpot coral/cream as the *surface* palette layered on the security-semantic tokens — must be user-confirmed.
- **D2 — Studio scope**: `features/studio/` doesn't exist; master doc schedules Studio UI in Sprint 4. Decide whether this change scaffolds studio (Login + ScanScreen per Penpot) or only IOC+Loader shared system.
- **D3 — Loader login flow differs** (mobile uses token/id, web/desktop use user+password) — one `LoginForm` molecule with a variant, or two forms?
- **D4 — `feature_access` location**: `auth/domain/policies/` vs `core/` (recommend auth/domain — it is role policy, not UI).
- **D5 — new AuthState**: add `PlatformBlocked` state vs reuse `AuthError` (recommend dedicated state for testability).

---

## 7. Risks

- **R1 (HIGH)**: Penpot palette ≠ DesignTokens. Blindly porting the design breaks the normative token contract and the master doc's security color semantics. Needs explicit user decision before apply.
- **R2 (MED)**: `dart:io Platform` would crash web builds — gate MUST use `foundation.dart`. Widget tests need `debugDefaultTargetPlatformOverride` to simulate platforms.
- **R3 (MED)**: `features/studio/` absent (contrary to the assumption it has .gitkeep placeholders) — scope surprise for apply; confirm D2.
- **R4 (MED)**: Role→feature→platform matrix is NOT in ground-truth docs; current routing (non-admin → Loader) and the stale integration test (admin → Loader + Studio Admin) partially contradict each other. User MUST confirm the matrix before spec.
- **R5 (LOW)**: Stale `login_form_test.dart` and `auth_integration_test.dart` reference non-existent widgets — will fail CI; rewrite as part of this change.
- **R6 (LOW)**: No session persistence (flutter_secure_storage removed) — `AuthCheckRequested` always logs out; gate must not depend on persisted state.
- **R7 (LOW)**: Penpot design has no components/typographies; pixel fidelity needs interpretation. During apply, export each screen board to PNG via Penpot MCP as visual reference.

---

## 8. Ready for Proposal

**Yes.** The three topics are well-scoped and the Penpot designs are fully inventoried. The orchestrator should tell the user:
1. Penpot MCP was connected and all 4 pages inventoried (IOC=web page, Studio=escritorio page, Loader=movile page, + logo asset) — the designs contain full login/home/modal screens for each.
2. **A decision is needed on the palette**: the Penpot design uses a coral/cream palette that does NOT match the normative DesignTokens (govBlue etc.). Confirm the reconciliation strategy (D1) before proposal.
3. **Confirm the role→feature→platform matrix** (D4 section) — especially whether Studio is in this change's scope given `features/studio/` does not exist, and the exact roles allowed per feature.
4. Recommended gate design is a pure-Dart domain policy enforced at both the auth BLoC (deny login) and the route wrapper (defense in depth), using `kIsWeb`/`defaultTargetPlatform` (web-safe).
5. Shared Atomic Design goes in `core/widgets/{atoms,molecules,organisms}`; feature views stay inside each feature's `presentation/pages`.

**Next phase**: `sdd-propose` (must resolve D1–D5 and the role matrix with the user).