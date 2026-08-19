# Proposal: Sprint 1 UI Penpot — Penpot-driven UI, Platform Gates & Atomic Design

## Intent

Port the three Penpot designs (IOC web, Studio desktop, Loader mobile) into a shared Atomic Design system with a security-first role→feature→platform gate. Today: single-file pages with inline styles, ~200-line login inline in `main.dart`, no platform detection, `features/studio/` absent. Thesis principle: the visual layer MUST NOT alter security semantics — access policy lives in domain code, enforced at login (AuthBloc) and at the route (AuthWrapper). Maps to `documento_maestro.md` Sprints 1–4 and `arquitectura_y_algoritmos_ia.md` §1.1 (SoD/IAM).

## Scope

### In Scope
- DesignTokens values → Penpot palette; names/semantics kept (safetyRed=SoD lockouts, warningYellow=calibration, safeGreen=authorized, govBlue=AI agent; coral/cream = identity/brand)
- `features/auth/domain/policies/feature_access.dart` (pure Dart): administrador/superUsuario→IOC (web only); tecnico→Studio (Windows only); operador→Loader (Android only); externo→denied
- AuthBloc: new blocked state, deny on `LoginRequested` when platform mismatched; AuthWrapper defense-in-depth screen + logout
- `core/platform/platform_detector.dart` — kIsWeb + defaultTargetPlatform, web-safe (no dart:io), testable via debug override
- `core/widgets/{atoms,molecules,organisms}` — global design system; LoginForm molecule replaces inline LoginPage (token-based variant for Loader)
- IOC pages (login, dashboard, personal/accesses) per Penpot web; Loader pages (scan, connecting, device detail, token login, license expired) per Penpot mobile
- NEW `features/studio/` — login + Bluetooth scan per Penpot desktop
- Tests: rewrite stale `test/widget/login_form_test.dart` and `integration_test/auth_integration_test.dart`; add policy/platform/widget tests

### Out of Scope
- Token/session persistence (flutter_secure_storage removed — ATL break on Windows; `AuthCheckRequested` stays non-persistent)
- Real OIDC, real Bluetooth, backend work, golden_toolkit adoption
- IOC "Gestion de eventos" placeholder, modal behavior details, logo asset extraction
- Studio Sprint-4 scope (read-only roles, toolbox)

## Capabilities

### New Capabilities
- `feature-access-policy`: role→feature→platform matrix; login denial + route guard
- `design-tokens`: Penpot palette under existing semantic names + spacing/typography/radius tokens
- `atomic-design-system`: global atoms/molecules/organisms shared by all 3 UIs
- `ioc-ui`: web screens per Penpot (login, dashboard, personal/accesses)
- `loader-ui`: mobile screens per Penpot (scan, connecting, device detail, token login, license expired)
- `studio-ui`: desktop screens per Penpot (login, bluetooth scan)

### Modified Capabilities
None — no specs exist yet.

## Approach

Feature-first hybrid: global design system in `core/widgets/`, feature views in each feature's `presentation/pages`. Gate = pure-Dart policy enforced at AuthBloc (deny) + AuthWrapper (defense-in-depth); detection via `foundation.dart` only. Order: (1) tokens + platform detector, (2) policy + bloc/wrapper gate, (3) shared widgets, (4) refactor IOC/Loader, (5) scaffold Studio, (6) tests. flutter_bloc 8.1.3, no new runtime deps.

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `app/lib/main.dart` | Modified | AuthWrapper gate; LoginPage extracted |
| `app/lib/features/auth/` | Modified | New state + denial in bloc; `domain/policies/feature_access.dart` (new) |
| `app/lib/core/theme/design_tokens.dart` | Modified | Penpot palette values + new tokens |
| `app/lib/core/platform/platform_detector.dart` | New | Web-safe platform detection |
| `app/lib/core/widgets/{atoms,molecules,organisms}/` | New | Global design system |
| `app/lib/features/ioc/presentation/pages/` | Modified | Refactor to shared components (Penpot web) |
| `app/lib/features/loader/presentation/pages/` | Modified | Refactor + token login variant (Penpot mobile) |
| `app/lib/features/studio/` | New | Login + scan screens (Penpot desktop) |
| `app/test/**`, `app/integration_test/` | Modified | Stale tests rewritten; new tests |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| dart:io `Platform` crashes web builds | High | Only `foundation.dart` in shared paths; lint review |
| Palette retoken breaks master-doc semantics | Med | Names/semantics kept; mapping documented |
| Studio scaffold scope creep | Low | Locked to login + scan screens |
| Stale tests fail CI | High | Rewritten in this change (in scope) |

## Rollback Plan

Per-sprint commits keep units reversible: revert palette/token change or widget refactors independently; AuthBloc change is additive (new state, nothing removed); Studio scaffold isolated in its own commit — drop if defective.

## Dependencies

- Penpot MCP (export screen boards to PNG as visual reference during apply)
- Existing: flutter_bloc 8.1.3, `flutter/foundation.dart` (no new runtime deps)

## Success Criteria

- [ ] `flutter analyze` clean; `flutter test` green incl. rewritten stale tests
- [ ] Login denied for admin/superUsuario off-web, tecnico off-Windows, operador off-Android, externo always; defense-in-depth screen shown on mismatch
- [ ] IOC/Loader render Penpot-matching layouts composed from shared widgets; Studio login + scan exist
- [ ] No `dart:io` import in any code path that runs on web
