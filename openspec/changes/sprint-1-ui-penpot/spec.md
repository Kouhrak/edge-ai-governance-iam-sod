# Sprint 1 UI Penpot Specification

**Change**: `sprint-1-ui-penpot` · **Type**: initial spec — all content ADDED (no prior `openspec/specs/`) · **Sources**: `exploration.md`, `proposal.md`, Penpot MCP designs (pages `web`, `escritorio`, `movile`), `app/lib/core/theme/design_tokens.dart`, `app/lib/features/auth/presentation/bloc/auth_bloc.dart`, `app/lib/main.dart`

## Purpose

Sprint 1 ports the three Penpot designs (IOC web, Studio desktop, Loader mobile) onto a shared Atomic Design system with a security-first role→feature→platform login gate. User story (master doc): *Como Ingeniero de Ciberseguridad, quiero que cada rol acceda solo a su feature desde su plataforma autorizada con una UI consistente derivada de Penpot, para que la capa visual nunca altere las restricciones SoD del dominio.* Access policy lives in domain code (pure Dart) and is enforced at login (AuthBloc deny) and at the route (AuthWrapper defense-in-depth).

## Requirements

### Requirement: Design Tokens — Penpot Palette Reconciliation (resolves D1)

`lib/core/theme/design_tokens.dart` SHALL keep the four token names and security semantics (safetyRed=SoD lockouts, warningYellow=calibration warnings, safeGreen=authorized, govBlue=AI identity) while replacing their values with the Penpot palette: govBlue→coral `#FC7E6C`, safetyRed→`#D32F2F`, warningYellow→olive `#B7BE3A`, safeGreen→`#00A461`. SHALL add surface tokens `surfaceCream #FFF3D8`, `surfaceTan #E5BE9D` and spacing/typography/radius scales for fidelity. `tactileMinSize` SHALL stay ≥48.0.

#### Scenario: Token values match Penpot palette

- GIVEN `design_tokens.dart`
- WHEN verify reads constants
- THEN hex values match the Penpot mapping above and tactileMinSize ≥48.0

#### Scenario: Semantics preserved

- GIVEN the new palette values
- WHEN a UI shows an SoD lockout, an authorized status, or an AI identity element
- THEN it consumes safetyRed, safeGreen, govBlue respectively — semantics unchanged

### Requirement: Platform Detection

`core/platform/platform_detector.dart` SHALL expose `enum PlatformType {web, desktop, mobile}` and a current-platform resolver built ONLY on `kIsWeb` + `defaultTargetPlatform` from `flutter/foundation.dart` — no `dart:io` on any web-executable path. It SHALL map kIsWeb→web, Windows/macOS/Linux→desktop, Android/iOS→mobile, and SHALL be testable via `debugDefaultTargetPlatformOverride`.

#### Scenario: Web resolves to web

- GIVEN `kIsWeb == true`
- WHEN `currentPlatform` is read
- THEN it returns `PlatformType.web`

#### Scenario: Desktop and mobile resolve correctly

- GIVEN `debugDefaultTargetPlatformOverride = TargetPlatform.windows` (or `.android`)
- WHEN `currentPlatform` is read
- THEN it returns `desktop` (or `mobile`)

#### Scenario: No dart:io in web paths

- GIVEN the platform detector source
- WHEN a static check scans imports
- THEN `dart:io` is absent from it and from all files it transitively imports into web builds

### Requirement: Feature Access Policy (resolves D2, D4)

`features/auth/domain/policies/feature_access.dart` SHALL be pure Dart (no Flutter imports) and SHALL encode the matrix:

| Role | Feature | Allowed platform |
|---|---|---|
| administrador, superUsuario | IOC | web |
| tecnico | Studio | desktop (Windows) |
| operador | Loader | mobile (Android) |
| externo | — | none (login denied) |

It SHALL expose `bool isLoginAllowed(UserRole role, PlatformType platform)` and `Feature? resolveFeature(UserRole role)`.

#### Scenario: Admin allowed on web only

- GIVEN role administrador/superUsuario
- WHEN `isLoginAllowed(role, web)` / `isLoginAllowed(role, mobile)` is evaluated
- THEN web returns true; mobile returns false

#### Scenario: Tecnico allowed on desktop only

- GIVEN role tecnico
- WHEN `isLoginAllowed(tecnico, desktop)` / `isLoginAllowed(tecnico, web)` is evaluated
- THEN desktop returns true; web returns false

#### Scenario: Operador allowed on mobile only

- GIVEN role operador
- WHEN `isLoginAllowed(operador, mobile)` / `isLoginAllowed(operador, desktop)` is evaluated
- THEN mobile returns true; desktop returns false

#### Scenario: Externo always denied

- GIVEN role externo
- WHEN `isLoginAllowed(externo, platform)` is evaluated for any platform
- THEN it returns false and `resolveFeature(externo)` returns null

### Requirement: AuthBloc Platform Gate (resolves D5)

`AuthBloc` SHALL evaluate `isLoginAllowed` during `LoginRequested` after authentication succeeds; on denial it SHALL emit a new dedicated `PlatformBlocked` state (with the user and a reason) and MUST NOT emit `Authenticated`. Externo SHALL be denied on every platform. Invalid credentials SHALL keep emitting `AuthError`. Platform resolution SHALL be injectable into the bloc for tests (default: `PlatformDetector.currentPlatform`).

#### Scenario: Admin login denied off-web

- GIVEN role administrador authenticating from `PlatformType.mobile`
- WHEN `LoginRequested` completes
- THEN `PlatformBlocked` is emitted and `Authenticated` is never emitted

#### Scenario: Allowed combination authenticates

- GIVEN role tecnico authenticating from `PlatformType.desktop`
- WHEN `LoginRequested` completes
- THEN `Authenticated` is emitted with the parsed `UserIdentity`

#### Scenario: Externo denied regardless of platform

- GIVEN role externo authenticating from any platform
- WHEN `LoginRequested` completes
- THEN `PlatformBlocked` is emitted

#### Scenario: Bad credentials unchanged

- GIVEN invalid username/password
- WHEN `LoginRequested` completes
- THEN `AuthError` is emitted as today

### Requirement: AuthWrapper Defense-in-Depth

`AuthWrapper` (in `main.dart`) SHALL read the SAME policy for any `Authenticated` state: if `isLoginAllowed(user.rol, PlatformDetector.currentPlatform)` is false, it SHALL render a blocked screen (token-styled message + logout button dispatching `LogoutRequested`) and MUST NOT render the feature page. Allowed sessions SHALL route by `resolveFeature`: IOC→IocDashboardPage, Studio→StudioPage, Loader→Loader page.

#### Scenario: Blocked session shows blocked screen

- GIVEN an Authenticated administrador whose current platform is mobile
- WHEN `AuthWrapper` builds
- THEN it renders the blocked screen and never `IocDashboardPage`

#### Scenario: Logout from blocked screen

- GIVEN the blocked screen is shown
- WHEN the user taps logout
- THEN `LogoutRequested` fires and the wrapper renders the login UI

#### Scenario: Allowed session routes to feature

- GIVEN an Authenticated operador on mobile
- WHEN `AuthWrapper` builds
- THEN it renders the Loader flow

### Requirement: Atomic Design System (resolves D3)

`core/widgets/{atoms,molecules,organisms}` SHALL host the global design system consumed by all three UIs, composed from DesignTokens: atoms (AppButton, AppTextField, StatusBadge, TokenChip, ProgressBar), molecules (LoginForm with web/desktop user+password variant and mobile token variant, StatCard, NavItem, ChecklistCard, PageHeader), organisms (SideNavigation, TopBar, DataTable, ActionBar, DeviceDetailPanel). The inline `LoginPage` in `main.dart` SHALL be removed and replaced by the shared `LoginForm` molecule; feature pages SHALL compose shared components rather than duplicate styling.

#### Scenario: LoginPage extracted

- GIVEN `main.dart` after apply
- WHEN its widget tree is inspected
- THEN no inline login form exists; login UI is the shared `LoginForm` molecule

#### Scenario: Shared components reused

- GIVEN IOC dashboard, Studio scan, and Loader device detail pages
- WHEN their widget trees are inspected
- THEN they compose atoms/molecules/organisms from `core/widgets` (no re-inlined styling per page)

### Requirement: IOC Web UI

IOC SHALL render Penpot `web` screens composed from shared widgets: Login (Usuario / Contraseña / Iniciar Sesión), Dashboard (Métricas Globales de acceso, Gestión de Accesos, Registros de entradas Autorizadas, Alertas de Seguridad (Bloqueados), Tráfico de Aplicaciones últimos 7 días), Personal y Accesos (Usuario Institucional, Equipos vinculados, Estatus Global, Acciones Maestras), Gestion de eventos placeholder ("En desarrollo"). UI copy SHALL follow Penpot/existing pages (Spanish acceptable).

#### Scenario: Admin reaches Penpot dashboard

- GIVEN an administrador/superUsuario logged in on web
- WHEN the dashboard renders
- THEN metrics, access management, and security alerts sections are visible per the Penpot `Home` board

#### Scenario: Navigation to Personal y Accesos

- GIVEN the IOC dashboard
- WHEN the user selects "Personal y Accesos" in the side navigation
- THEN the personal/accesses view renders with institutional user and linked devices sections

### Requirement: Studio Desktop UI

`features/studio/` SHALL be scaffolded with two screens per Penpot `escritorio`: Login (Usuario / Contraseña / INICIAR SESION) and Bluetooth Scan (header "Studio", Buscar Dispositivos Bluetooth, device list with Estado, Editar, Validación, Despliegue, Escanear, Conectar, Desconectar, Puerto, Adaptador).

#### Scenario: Tecnico reaches Studio scan

- GIVEN a tecnico logged in on desktop
- WHEN the Studio feature opens
- THEN the scan screen renders with the Penpot device list and connect/disconnect actions

#### Scenario: Scan screen states

- GIVEN the Studio scan screen
- WHEN no scan is running and when one is running
- THEN "Escanear" is enabled/disabled accordingly and a device list or scanning state is shown

### Requirement: Loader Mobile UI

Loader SHALL render Penpot `movile` screens: Token login (token/id — NOT user+password), Scan (Buscar dispositivos, Dispositivos cercanos, PLC cards with MAC, Escaneando… / Cancelar), Conectando…, Device detail home (Familia/Modelo, Estado de conexión, Hardware, Dirección MAC, Nombre de dispositivo, Modificada por, Voltaje/Temperatura, Autorizada/Congelada), and a license-expired screen.

#### Scenario: Operador token login to scan

- GIVEN an operador on mobile with a valid token
- WHEN login completes
- THEN the scan screen renders with nearby device cards per the Penpot board

#### Scenario: Connect flow reaches device detail

- GIVEN a device selected on the scan screen
- WHEN connecting completes
- THEN the device detail home renders showing "Conectado", hardware info, and voltage/temperature

#### Scenario: License expired screen

- GIVEN a device whose status is license-expired
- WHEN the device detail would render
- THEN the license-expired screen is shown instead

### Requirement: Test Rewrites

`test/core/theme/design_tokens_test.dart` SHALL assert the new Penpot hex values; `test/widget/login_form_test.dart` SHALL drive the real shared `LoginForm` (remove the local fake); `integration_test/auth_integration_test.dart` SHALL be rewritten (not deleted if maintainable) to reflect the new flows — admin web→IOC, tecnico desktop→Studio, operador mobile→Loader, mismatches→blocked. New tests SHALL cover the policy (pure unit), platform detector, AuthBloc gate (`bloc_test`), and shared widget composition.

#### Scenario: Design token test updated

- GIVEN the new palette
- WHEN `design_tokens_test.dart` runs
- THEN it asserts the Penpot hex values and ≥48dp touch targets

#### Scenario: Login form test uses shared component

- GIVEN the shared `LoginForm` molecule
- WHEN `login_form_test.dart` runs
- THEN it drives the real molecule (web/desktop and token variants) and no stale local fake is referenced

#### Scenario: Integration test matches new flows

- GIVEN the gate and the three UIs
- WHEN `auth_integration_test.dart` runs
- THEN allowed role+platform combos land on their feature pages and mismatches land on the blocked screen

### Requirement: Inputs, Outputs, Constraints

Inputs: Penpot designs (`web`, `escritorio`, `movile`), exploration.md, proposal.md, current `app/lib/**`. Outputs: updated `design_tokens.dart`, `core/platform/platform_detector.dart`, `feature_access.dart`, AuthBloc `PlatformBlocked` state, `core/widgets/{atoms,molecules,organisms}`, refactored IOC/Loader pages, scaffolded `features/studio/`, rewritten tests. Constraints: flutter_bloc 8.1.3; NO flutter_secure_storage (token persistence OUT of scope — `AuthCheckRequested` stays non-persistent); code identifiers/comments in English; UI copy Spanish acceptable following existing pages; no `dart:io` on web paths; commit `feat(sprint-1): ...` v0.1.0 + tag.

### Requirement: Acceptance Scenarios

#### Scenario: Analyze and tests green

- GIVEN apply complete
- WHEN `flutter analyze` and `flutter test` run
- THEN both pass including the rewritten stale tests

#### Scenario: Denial matrix proven

- GIVEN the policy and gate tests
- WHEN the matrix is exercised
- THEN admin/superUsuario off-web, tecnico off-desktop, operador off-mobile, and externo always are denied at login AND blocked at the wrapper

#### Scenario: No dart:io on web paths

- GIVEN all code that runs on web
- WHEN a scan for `dart:io` imports runs
- THEN no hit is found (platform detection uses `foundation.dart` only)
