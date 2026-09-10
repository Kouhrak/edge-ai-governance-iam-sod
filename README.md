# Edge AI Governance — IAM & SoD

Gobernanza de IA local con Gestión de Identidades y Accesos (IAM) y Segregación de Funciones (SoD) para manufactura inteligente.

## About

Sistema multiplataforma que combina un frontend Flutter (Android, Windows Desktop, Web) con una infraestructura de microservicios containerizada para controlar accesos, auditar acciones y prevenir conflictos de intereses en entornos industriales. El proyecto implementa OIDC/OAuth 2.0 con PKCE, tokens CapBAC con firma Ed25519, replicación PostgreSQL primary/replica y un pipeline de validación tripartita (esquema Pydantic / semántica actor-crítica / atributo-SoD) asistido por un SLM local (Ollama Gemma 3 / Phi-3-mini).

## Quick Start

### Prerequisites

- Flutter SDK >= 3.13.0 (Dart >= 3.13)
- Docker Desktop / Docker Engine + Compose V2
- Python 3.11+ (para tests y scripts)
- PostgreSQL 16 (o usar el provided via Docker)

### Installation

```bash
# 1. Clonar el repositorio
git clone https://github.com/Kouhrak/edge-ai-governance-iam-sod.git
cd edge-ai-governance-iam-sod

# 2. Configurar variables de entorno
cp .env.example .env
# Editar .env con tus credenciales

# 3. Levantar infraestructura (PostgreSQL primary/replica)
docker compose up -d

# 4. Instalar dependencias del frontend
cd app
flutter pub get
```

### Run

```bash
# Frontend (seleccionar plataforma)
cd app
flutter run -d chrome        # Web
flutter run -d windows       # Windows Desktop
flutter run -d android       # Android

# Infraestructura
docker compose up -d         # PostgreSQL primary + replica
```

## Available Commands

| Comando | Descripción |
|---------|-------------|
| `flutter pub get` | Instalar dependencias del frontend |
| `flutter run -d <device>` | Ejecutar app en plataforma específica |
| `flutter analyze` | Analizar código Dart (lint + static analysis) |
| `flutter test` | Ejecutar tests unit/widget del frontend |
| `docker compose up -d` | Levantar PostgreSQL primary + replica |
| `docker compose down` | Detener contenedores |
| `pytest tests/ -v` | Ejecutar tests Python (unit/integration) |
| `pytest tests/ --cov=src` | Tests con reporte de cobertura |
| `bash scripts/test/run_all_tests.sh` | Ejecutar suite completa de tests |

## Project Structure

```
edge-ai-governance-iam-sod/
├── app/                          # Flutter frontend (Dart)
│   ├── lib/
│   │   ├── main.dart             # Entry point + AuthWrapper + routing
│   │   ├── core/                 # Capa compartida
│   │   │   ├── theme/            # Design tokens + app theme (Penpot-derived)
│   │   │   ├── widgets/          # Design System Atomic
│   │   │   │   ├── atoms/        # AppButton, StatusBadge, TokenChip, ProgressBar
│   │   │   │   ├── molecules/    # LoginForm, DeviceCard, StatCard, NavItem
│   │   │   │   └── organisms/    # DataTable, SideNavigation, TopBar
│   │   │   ├── network/          # HTTP client (placeholder)
│   │   │   └── platform/         # Detección de plataforma (Web/Desktop/Mobile)
│   │   └── features/             # Features bajo Clean Architecture
│   │       ├── auth/             # Autenticación (OIDC, JWT, roles, SoD)
│   │       │   ├── data/         # Data sources + repositories impl
│   │       │   ├── domain/       # Entities, policies, use cases
│   │       │   └── presentation/ # BLoC, widgets, pages
│   │       ├── ioc/              # Panel IOC (dashboard administrativo)
│   │       │   └── presentation/ # Dashboard, accesos, personal, eventos
│   │       └── loader/           # Carga y checklist de dispositivos BLE
│   │           ├── domain/       # BleDevice entity
│   │           └── presentation/ # Checklist page
│   ├── test/                     # Flutter tests
│   ├── integration_test/         # Integration tests
│   └── pubspec.yaml              # Dependencias Dart
├── initdb/                       # SQL de inicialización PostgreSQL
├── scripts/
│   └── test/                     # Scripts de testing y recolección de evidencia
├── tests/                        # Tests Python (unit + integration)
├── docs/                         # Documentación y assets
├── openspec/                     # Spec-Driven Development (SDD)
│   ├── specs/                    # Especificaciones por feature
│   └── changes/                  # Propuestas de cambio por sprint
├── evidence/                     # Evidencia de validación
├── docker-compose.yml            # PostgreSQL 16 primary/replica
├── docker-compose.test.yml       # Entorno de testing Docker
├── requirements-test.txt         # Dependencias Python para testing
├── pytest.ini                    # Configuración pytest
├── .env.example                  # Template de variables de entorno
└── documento_maestro.md          # Documento maestro de la tesis
```

## Tech Stack

### Frontend
- **Framework**: Flutter 3.13+ (Dart)
- **State Management**: BLoC (flutter_bloc 8.1)
- **Arquitectura**: Clean Architecture + Atomic Design
- **Design System**: Design Tokens (Penpot-derived), tokens en `core/theme/`
- **Plataformas**: Android, Windows Desktop, Web

### Backend / Infraestructura
- **Base de datos**: PostgreSQL 16 (primary/replica con streaming replication)
- **Containerización**: Docker + Compose V2
- **Autenticación**: OIDC/OAuth 2.0 con PKCE, JWT, SCIM (RFC 7643/7644)
- **Seguridad**: FIDO2/WebAuthn MFA, AES-GCM-256, SHA-256 ledger, CapBAC (Ed25519)

### Edge AI
- **SLM local**: Ollama (Gemma 3 2B Q4_K_M / Phi-3-mini)
- **MCP Server**: FastMCP
- **Validación tripartita**: Pydantic schema / actor-critic semantics / attribute-SoD

### Testing
- **Flutter**: `flutter test` (widget + unit)
- **Python**: pytest (unit, integration, e2e)
- **Cobertura**: pytest-cov, flutter test --coverage
- ** quality**: flutter analyze, flake8, mypy, black, isort

## Configuration

| Variable | Descripción | Default |
|----------|-------------|---------|
| `POSTGRES_USER` | Usuario de PostgreSQL | `postgres` |
| `POSTGRES_PASSWORD` | Contraseña de PostgreSQL | *(requerido en .env)* |
| `POSTGRES_DB` | Nombre de la base de datos | `edge_iam` |
| `POSTGRES_PORT` | Puerto del primary | `5432` |
| `POSTGRES_REPLICA_PORT` | Puerto del replica | `5433` |
| `REPLICATION_USER` | Usuario de replicación | `repl` |
| `REPLICATION_PASSWORD` | Contraseña de replicación | *(requerido en .env)* |

## Roles del Sistema

| Rol | Plataforma | Descripción |
|-----|------------|-------------|
| `administrador` | IOC Web | Gestión completa de usuarios, activos y auditoría |
| `superUsuario` | IOC Web | Acceso administrativo con privilegios extendidos |
| `tecnico` | Móvil/Desktop | Inyección de firmware, mantenimiento de dispositivos |
| `operador` | Móvil | Operaciones de piso, checklists |
| `externo` | Restringido | Auditor externo, acceso de solo lectura |

## Contributing

El proyecto está en fase de tesis (UTEQ). Las contribuciones se gestionan vía SDD (Spec-Driven Development) usando el workflow definido en `openspec/`.

1. Crear una propuesta en `openspec/changes/`
2. Seguir el ciclo: proposal → spec → design → tasks → apply → verify
3. Commits siguen convención: `feat(sprint-N): ...` / `test(sprint-N): ...`

## License

Proyecto privado — tesis de grado UTEQ. No distribuir sin autorización.
