# Estrategia de Testing - Edge AI Governance IAM SoD

## 1. Visión General
Estrategia de testing basada en la pirámide de testing, priorizando pruebas unitarias rápidas y confiables, seguidas de pruebas de integración y finalmente pruebas de sistema/end-to-end.

## 2. Pirámide de Testing
```
          /\
         /  \  System/E2E (5%)
        /----\
       /      \  Integration (20%)
      /--------\
     /          \  Unit/Widget (75%)
    /------------\
```

### 2.1 Pruebas Unitarias (75% del esfuerzo)
**Objetivo**: Verificar funciones aisladas sin dependencias externas.

**Flutter**:
- **Herramienta**: `flutter test`
- **Ubicación**: `test/` al mismo nivel que `lib/`
- **Patrón**: `*_test.dart` junto al archivo fuente
- **Ejemplo**: `test/core/theme/design_tokens_test.dart`

**Python/FastAPI**:
- **Herramienta**: `pytest`
- **Ubicación**: `tests/` en la raíz del backend
- **Patrón**: `test_*.py`
- **Ejemplo**: `tests/test_sod_engine.py`

### 2.2 Pruebas de Widget (15% del esfuerzo)
**Objetivo**: Verificar componentes UI de Flutter.

**Flutter**:
- **Herramienta**: `flutter_test` (widget testing)
- **Ubicación**: `test/widget/` o junto a los componentes
- **Patrón**: `*_widget_test.dart`
- **Ejemplo**: `test/features/auth/widget/login_form_test.dart`

### 2.3 Pruebas de Integración (20% del esfuerze)
**Objetivo**: Verificar interacción entre componentes.

**Flutter ↔ Backend**:
- **Herramienta**: `integration_test`
- **Ubicación**: `integration_test/`
- **Patrón**: `*_integration_test.dart`

**Backend ↔ PostgreSQL**:
- **Herramienta**: `pytest` + `testcontainers`
- **Ubicación**: `tests/integration/`
- **Patrón**: `test_*.py` con fixtures Docker

**Docker Compose**:
- **Herramienta**: Scripts bash que levantan servicios
- **Ubicación**: `scripts/test/`

### 2.4 Pruebas de Sistema/E2E (5% del esfuerzo)
**Objetivo**: Verificar flujos completos de usuario.

**Flutter**:
- **Herramienta**: `flutter_driver` o `integration_test`
- **Ubicación**: `test/e2e/`
- **Patrón**: `*_e2e_test.dart`

**Multiplataforma**:
- **Herramienta**: Appium (basado en Selenium WebDriver)
- **Para**: Pruebas en dispositivos reales/emuladores

## 3. Configuración de Dependencias

### 3.1 Flutter (pubspec.yaml)
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  mockito: ^5.4.0
  build_runner: ^2.4.0
  bloc_test: ^9.1.0
```

### 3.2 Python (requirements-test.txt)
```
pytest>=7.4.0
pytest-asyncio>=0.21.0
pytest-cov>=4.1.0
httpx>=0.25.0
testcontainers>=3.7.0
```

## 4. Scripts de Ejecución

### 4.1 Todas las pruebas Flutter
```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widget/

# Integration tests (requiere dispositivo/emulador)
flutter test integration_test/

# Cobertura
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### 4.2 Todas las pruebas Python
```bash
# Unit tests
pytest tests/unit/ -v

# Integration tests
pytest tests/integration/ -v --tb=short

# Con Docker
docker compose -f docker-compose.test.yml up -d
pytest tests/integration/ -v
docker compose -f docker-compose.test.yml down

# Cobertura
pytest --cov=src --cov-report=html
```

### 4.3 Script unificado
```bash
./scripts/test/run_all_tests.sh
```

## 5. Pipeline CI/CD (Jenkins)

### 5.1 Jenkinsfile básico
```groovy
pipeline {
    agent any
    
    stages {
        stage('Flutter Tests') {
            steps {
                sh 'flutter test --coverage'
            }
        }
        
        stage('Python Tests') {
            steps {
                sh 'pip install -r requirements-test.txt'
                sh 'pytest tests/ -v --cov=src'
            }
        }
        
        stage('Integration Tests') {
            steps {
                sh 'docker compose -f docker-compose.test.yml up -d'
                sh 'pytest tests/integration/ -v'
                sh 'docker compose -f docker-compose.test.yml down'
            }
        }
        
        stage('Build') {
            steps {
                sh 'flutter build apk --debug'
                sh 'flutter build windows --debug'
            }
        }
    }
    
    post {
        always {
            publishHTML([
                reportDir: 'coverage/html',
                reportFiles: 'index.html',
                reportName: 'Coverage Report'
            ])
        }
    }
}
```

## 6. Organización de Archivos
```
project/
├── test/                          # Flutter tests
│   ├── unit/                      # Unit tests
│   │   ├── core/
│   │   │   └── theme/
│   │   │       └── design_tokens_test.dart
│   │   └── features/
│   │       └── auth/
│   │           └── domain/
│   │               └── entities/
│   │                   └── user_identity_test.dart
│   ├── widget/                    # Widget tests
│   │   └── features/
│   │       └── auth/
│   │           └── widget/
│   │               └── login_form_test.dart
│   └── e2e/                       # End-to-end tests
│       └── auth_flow_e2e_test.dart
├── integration_test/              # Integration tests
│   └── auth_integration_test.dart
├── tests/                         # Python tests
│   ├── unit/
│   │   └── test_sod_engine.py
│   └── integration/
│       └── test_database.py
├── scripts/test/                  # Test scripts
│   ├── run_flutter_tests.sh
│   ├── run_python_tests.sh
│   └── run_all_tests.sh
└── docs/testing/                  # Testing documentation
    └── testing_strategy.md
```

## 7. Métricas de Calidad
- **Cobertura unitaria**: ≥80%
- **Cobertura total**: ≥60%
- **Tiempo de ejecución unitarias**: <2 minutos
- **Tiempo de ejecución integración**: <5 minutos
- **Zero regressions** en cada PR

## 8. Herramientas Adicionales Recomendadas
- **Flutter**: `golden_toolkit` para pruebas visuales
- **Python**: `hypothesis` para pruebas basadas en propiedades
- **Docker**: `testcontainers` para bases de datos de prueba
- **CI/CD**: Jenkins + Docker para ejecución aislada
- **Reporting**: Allure Reports para reportes HTML

## 9. Flujo de Desarrollo
1. Escribir prueba unitaria primero (TDD opcional)
2. Implementar código
3. Ejecutar pruebas localmente
4. Push a repo → Jenkins ejecuta pipeline
5. Cobertura y métricas en dashboard
6. Merge si todo pasa

## 10. Casos Especiales del Proyecto
- **Replicación Docker**: Pruebas de integración deben levantar ambos contenedores
- **BLE**: Mockear en unit tests, pruebas reales solo en dispositivo
- **MCP Server**: Mockear respuestas del SLM en pruebas
- **Seguridad**: Pruebas de penetración en Sprint 11