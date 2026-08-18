# Testing & CI/CD Strategy - Edge AI Governance IAM SoD

## 1. Resumen Ejecutivo
Estrategia completa de testing y integración continua para el proyecto Edge AI Governance IAM SoD, utilizando herramientas nativas de Flutter y Python con Jenkins para automatización.

## 2. Arquitectura de Testing

### 2.1 Pirámide de Testing
```
                    /\
                   /  \  E2E Tests (5%)
                  /----\
                 /      \  Integration Tests (20%)
                /--------\
               /          \  Unit/Widget Tests (75%)
              /------------\
```

### 2.2 Herramientas por Capa

| Capa | Flutter | Python | Herramientas |
|------|---------|--------|--------------|
| **Unit** | `flutter test` | `pytest` | mockito, pytest-mock |
| **Widget** | `flutter_test` | - | flutter_test |
| **Integration** | `integration_test` | `pytest` + testcontainers | Docker Compose |
| **E2E** | `flutter_driver` | - | Appium (opcional) |
| **Performance** | `flutter test` | `pytest-benchmark` | Custom scripts |

## 3. Estructura de Archivos

```
project/
├── test/                          # Flutter tests
│   ├── unit/                      # Unit tests
│   ├── widget/                    # Widget tests
│   └── e2e/                       # End-to-end tests
├── integration_test/              # Integration tests
├── tests/                         # Python tests
│   ├── unit/
│   └── integration/
├── scripts/test/                  # Test scripts
│   ├── run_flutter_tests.sh
│   ├── run_python_tests.sh
│   ├── run_all_tests.sh
│   └── test_sod_enforcement.py
├── docs/testing/                  # Testing documentation
│   ├── README.md
│   ├── testing_strategy.md
│   └── jenkins_pipeline.md
├── docker-compose.test.yml        # Test environment
├── pytest.ini                     # Pytest configuration
└── requirements-test.txt          # Python test dependencies
```

## 4. Pipeline CI/CD con Jenkins

### 4.1 Flujo del Pipeline
```
Code Commit → Lint → Unit Tests → Integration Tests → Build → Deploy
     ↓           ↓         ↓              ↓            ↓        ↓
   Webhook   Static    Flutter/      Docker       APK/EXE   SSH/ADB
   Trigger   Analysis  Python       Compose       Build    Deploy
```

### 4.2 Stages del Pipeline
1. **Checkout**: Descarga del código
2. **Static Analysis**: Lint y análisis de código
3. **Unit Tests**: Pruebas unitarias (Flutter + Python)
4. **Integration Tests**: Pruebas de integración con Docker
5. **Build**: Compilación de APK/EXE
6. **Deploy**: Despliegue a ambientes

### 4.3 Configuración Jenkins
- **Plugins**: Git, Docker Pipeline, HTML Publisher, JUnit
- **Tools**: Flutter SDK, Python 3.11, JDK 17
- **Credentials**: Docker Registry, SSH Keys, Vault

## 5. SoD Enforcement en CI/CD

### 5.1 Reglas de SoD
```yaml
# config/sod_rules.yml
rules:
  build:
    allowed_roles: [developer, tecnico]
    blocked_combinations: [developer, administrador]
  
  test:
    allowed_roles: [developer, qa, tecnico]
    blocked_combinations: [tecnico, administrador]
  
  deploy:
    allowed_roles: [devops, administrador]
    blocked_combinations: [developer, administrador]
```

### 5.2 Validación en Pipeline
```groovy
stage('SoD Check') {
    steps {
        script {
            def builder = currentBuild.rawBuild.getCause(
                hudson.model.Cause.UserIdCause.class
            )?.userId
            def deployer = env.DEPLOY_USER
            
            if (builder == deployer) {
                error("SoD Violation: Same user cannot build and deploy")
            }
        }
    }
}
```

## 6. Métricas de Calidad

### 6.1 Cobertura de Código
- **Unit Tests**: ≥80%
- **Integration Tests**: ≥60%
- **Overall**: ≥70%

### 6.2 Performance
- **Unit Test Execution**: <2 minutes
- **Integration Test Execution**: <5 minutes
- **Build Time**: <10 minutes
- **Deployment Time**: <5 minutes

### 6.3 Seguridad
- **Vulnerability Scan**: 0 critical/high
- **SoD Violations**: 0
- **Secret Exposure**: 0

## 7. Scripts de Ejecución

### 7.1 Todas las Pruebas
```bash
./scripts/test/run_all_tests.sh
```

### 7.2 Solo Flutter
```bash
./scripts/test/run_flutter_tests.sh
```

### 7.3 Solo Python
```bash
./scripts/test/run_python_tests.sh
```

### 7.4 SoD Enforcement Test
```bash
python scripts/test/test_sod_enforcement.py
```

## 8. Docker para Testing

### 8.1 Entorno de Prueba
```bash
# Levantar entorno de prueba
docker compose -f docker-compose.test.yml up -d

# Ejecutar pruebas
pytest tests/integration/ -v

# Detener entorno
docker compose -f docker-compose.test.yml down
```

### 8.2 Servicios Incluidos
- **PostgreSQL 16**: Base de datos de prueba
- **Redis 7**: Caché de prueba
- **Test Runner**: Ejecutor de pruebas Python

## 9. Reportes y Monitoreo

### 9.1 Reportes Generados
- **Coverage Report**: HTML en `coverage/html/`
- **JUnit Report**: XML para Jenkins
- **Audit Report**: JSON en `reports/`
- **SoD Violations**: JSON en `logs/`

### 9.2 Integración con Dashboards
- **Jenkins**: Reportes de build y cobertura
- **SonarQube**: Análisis de calidad de código
- **Grafana**: Métricas de performance
- **Slack/Teams**: Notificaciones de builds

## 10. Troubleshooting

### 10.1 Problemas Comunes
1. **Flutter tests failing**: Verificar SDK installation
2. **Docker permission denied**: `sudo usermod -aG docker jenkins`
3. **SoD violations**: Revisar `logs/sod_violations.json`
4. **Coverage not showing**: Verificar paths en Jenkinsfile

### 10.2 Logs Útiles
```bash
# Jenkins logs
docker logs jenkins

# Test results
cat reports/pipeline_audit_*.json

# SoD violations
cat logs/sod_violations.json
```

## 11. Próximos Pasos
1. Configurar Jenkins server
2. Instalar plugins necesarios
3. Configurar webhooks con GitHub
4. Ejecutar pipeline de prueba
5. Ajustar métricas según resultados

## 12. Referencias
- [Flutter Testing](https://docs.flutter.dev/testing)
- [Pytest Documentation](https://docs.pytest.org/)
- [Jenkins Pipeline](https://www.jenkins.io/doc/book/pipeline/)
- [Docker Compose](https://docs.docker.com/compose/)
- [SoD Best Practices](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final)