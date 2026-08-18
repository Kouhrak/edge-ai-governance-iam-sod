# Jenkins CI/CD Pipeline - Edge AI Governance IAM SoD

## 1. Instalación de Jenkins

### 1.1 Requisitos Previos
- Java JDK 11+
- Docker y Docker Compose
- Git
- Flutter SDK (para pruebas Flutter)
- Python 3.11+ (para pruebas Python)

### 1.2 Instalación Rápida
```bash
# Usando Docker
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts

# Obtener contraseña inicial
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

### 1.3 Plugins Necesarios
- Git Plugin
- Docker Pipeline
- Pipeline
- Blue Ocean
- HTML Publisher
- JUnit Plugin
- Cobertura Plugin

## 2. Configuración del Pipeline

### 2.1 Jenkinsfile Básico
```groovy
pipeline {
    agent any
    
    environment {
        FLUTTER_HOME = tool('Flutter')
        PYTHON_HOME = tool('Python3.11')
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Flutter Tests') {
            steps {
                sh '''
                    $FLUTTER_HOME/bin/flutter pub get
                    $FLUTTER_HOME/bin/flutter test --coverage
                '''
            }
            post {
                always {
                    publishHTML([
                        reportDir: 'coverage',
                        reportFiles: 'lcov.info',
                        reportName: 'Flutter Coverage'
                    ])
                }
            }
        }
        
        stage('Python Tests') {
            steps {
                sh '''
                    $PYTHON_HOME/bin/pip install -r requirements-test.txt
                    $PYTHON_HOME/bin/pytest tests/ -v --cov=src --cov-report=html:coverage/python
                '''
            }
            post {
                always {
                    publishHTML([
                        reportDir: 'coverage/python',
                        reportFiles: 'index.html',
                        reportName: 'Python Coverage'
                    ])
                }
            }
        }
        
        stage('Integration Tests') {
            steps {
                sh '''
                    docker compose -f docker-compose.test.yml up -d
                    sleep 10
                    $PYTHON_HOME/bin/pytest tests/integration/ -v
                    docker compose -f docker-compose.test.yml down
                '''
            }
        }
        
        stage('Build') {
            parallel {
                stage('Build APK') {
                    steps {
                        sh '$FLUTTER_HOME/bin/flutter build apk --debug'
                    }
                }
                stage('Build Windows') {
                    steps {
                        sh '$FLUTTER_HOME/bin/flutter build windows --debug'
                    }
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            slackSend(
                color: 'good',
                message: "✅ Build Exitoso: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
            )
        }
        failure {
            slackSend(
                color: 'danger',
                message: "❌ Build Fallido: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
            )
        }
    }
}
```

### 2.2 Pipeline Completo con Roles SoD
```groovy
pipeline {
    agent any
    
    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'test', 'staging', 'production'],
            description: 'Target environment'
        )
        booleanParam(
            name: 'SKIP_INTEGRATION_TESTS',
            defaultValue: false,
            description: 'Skip integration tests'
        )
    }
    
    stages {
        stage('Security Scan') {
            steps {
                sh '''
                    # Dependency vulnerability scan
                    pip install safety
                    safety check -r requirements.txt
                '''
            }
        }
        
        stage('Unit Tests') {
            parallel {
                stage('Flutter Unit Tests') {
                    steps {
                        sh 'flutter test --coverage'
                    }
                }
                stage('Python Unit Tests') {
                    steps {
                        sh 'pytest tests/unit/ -v --cov=src'
                    }
                }
            }
        }
        
        stage('Integration Tests') {
            when {
                expression { return !params.SKIP_INTEGRATION_TESTS }
            }
            steps {
                sh '''
                    docker compose -f docker-compose.test.yml up -d
                    pytest tests/integration/ -v
                    docker compose -f docker-compose.test.yml down
                '''
            }
        }
        
        stage('SoD Validation Test') {
            steps {
                sh '''
                    # Test that SoD rules are enforced
                    python scripts/test/test_sod_enforcement.py
                '''
            }
        }
        
        stage('Build & Package') {
            steps {
                sh '''
                    flutter build apk --release
                    flutter build windows --release
                '''
            }
        }
        
        stage('Deploy to Environment') {
            when {
                branch 'main'
            }
            steps {
                sh """
                    ./scripts/deploy/deploy_to_${params.ENVIRONMENT}.sh
                """
            }
        }
    }
}
```

## 3. Configuración de Herramientas

### 3.1 Global Tool Configuration
En Jenkins → Manage Jenkins → Global Tool Configuration:

1. **Flutter SDK**:
   - Name: `Flutter`
   - Install automatically: ✅
   - Version: latest stable

2. **Python**:
   - Name: `Python3.11`
   - Install automatically: ✅
   - Version: 3.11.x

3. **JDK**:
   - Name: `JDK17`
   - Install automatically: ✅

### 3.2 Credentials
En Jenkins → Manage Jenkins → Manage Credentials:

1. **Docker Registry**:
   - ID: `docker-registry`
   - Username: dockerhub-username
   - Password: dockerhub-password

2. **SSH Keys** (para deploy):
   - ID: `ssh-deploy-key`
   - Private Key: (contenido de la clave privada)

## 4. Webhooks y Triggers

### 4.1 GitHub Webhook
1. Ir a GitHub → Settings → Webhooks → Add webhook
2. Payload URL: `http://your-jenkins:8080/github-webhook/`
3. Content type: `application/json`
4. Events: Just the push event

### 4.2 Polling SCM
```groovy
triggers {
    pollSCM('H/5 * * * *')  // Cada 5 minutos
}
```

## 5. Reportes y Métricas

### 5.1 Cobertura de Código
```groovy
post {
    always {
        // Flutter coverage
        publishHTML([
            reportDir: 'coverage',
            reportFiles: 'lcov.info',
            reportName: 'Flutter Coverage Report'
        ])
        
        // Python coverage
        publishHTML([
            reportDir: 'htmlcov',
            reportFiles: 'index.html',
            reportName: 'Python Coverage Report'
        ])
        
        // JUnit results
        junit '**/test-results/*.xml'
        
        // Cobertura
        cobertura(
            coberturaReportFile: '**/coverage.xml',
            onlyStable: false,
            failUnhealthy: false,
            failUnstable: false
        )
    }
}
```

### 5.2 Métricas de Calidad
- **Code Coverage**: ≥80% unit, ≥60% total
- **Test Pass Rate**: 100%
- **Build Time**: <10 minutes
- **Deployment Time**: <5 minutes

## 6. Seguridad en CI/CD

### 6.1 Vault for Secrets
```groovy
withVault([
    configuration: [
        [path: 'secret/data/jenkins', engineVersion: 2]
    ],
    vaultUrl: 'http://vault:8200',
    tokenCredentialId: 'vault-token'
]) {
    sh '''
        export DB_PASSWORD=$DB_PASSWORD
        export API_KEY=$API_KEY
    '''
}
```

### 6.2 SoD Enforcement
```groovy
stage('SoD Check') {
    steps {
        // Verify that the same user doesn't build AND deploy
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

## 7. Troubleshooting

### 7.1 Problemas Comunes
1. **Docker permission denied**:
   ```bash
   sudo usermod -aG docker jenkins
   sudo systemctl restart jenkins
   ```

2. **Flutter not found**:
   - Verificar que Flutter SDK está en PATH
   - Revisar Global Tool Configuration

3. **Tests failing in CI**:
   - Verificar variables de entorno
   - Revisar logs de Docker containers

### 7.2 Logs Útiles
```bash
# Jenkins logs
docker logs jenkins

# Pipeline logs
http://jenkins:8080/job/project-name/lastBuild/console

# Test results
http://jenkins:8080/job/project-name/lastBuild/testReport/
```

## 8. Referencias
- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Pipeline Syntax](https://www.jenkins.io/doc/book/pipeline/syntax/)
- [Flutter CI/CD](https://docs.flutter.dev/cd)
- [Python Testing](https://docs.pytest.org/)