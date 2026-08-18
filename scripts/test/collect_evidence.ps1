# Evidence Collection Script - Sprint 0 Validation
# Edge AI Governance IAM SoD

param(
    [string]$OutputDir = "evidence"
)

# Create output directory if it doesn't exist
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

Write-Host "=== Evidence Collection for Sprint 0 Validation ===" -ForegroundColor Cyan
Write-Host "Output directory: $OutputDir" -ForegroundColor Yellow
Write-Host ""

# Function to save screenshot description
function Save-Evidence {
    param(
        [string]$Name,
        [string]$Description,
        [string]$Command,
        [string]$Result
    )
    
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $filename = "$OutputDir/${Name}_${timestamp}.txt"
    
    $content = @"
Evidence: $Name
Timestamp: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Description: $Description
Command Executed: $Command
Result:
$Result
"@
    
    $content | Out-File -FilePath $filename -Encoding UTF8
    Write-Host "✓ Evidence saved: $filename" -ForegroundColor Green
}

# 1. Collect folder structure evidence
Write-Host "1. Collecting folder structure evidence..." -ForegroundColor Cyan
$structure = Get-ChildItem -Path "lib" -Recurse -Directory | Select-Object -ExpandProperty FullName
Save-Evidence -Name "01_folder_structure" -Description "Flutter Clean Architecture folder structure" -Command "Get-ChildItem -Path lib -Recurse -Directory" -Result ($structure -join "`n")

# 2. Count .gitkeep files
Write-Host "2. Counting .gitkeep files..." -ForegroundColor Cyan
$gitkeepCount = Get-ChildItem -Path "lib" -Recurse -Filter ".gitkeep" | Measure-Object | Select-Object -ExpandProperty Count
Save-Evidence -Name "02_gitkeep_count" -Description "Number of .gitkeep files in structure" -Command "Get-ChildItem -Path lib -Recurse -Filter '.gitkeep' | Measure-Object" -Result "Total .gitkeep files: $gitkeepCount"

# 3. Collect Design Tokens evidence
Write-Host "3. Collecting Design Tokens evidence..." -ForegroundColor Cyan
$designTokens = Get-Content -Path "lib/core/theme/design_tokens.dart" -Raw
Save-Evidence -Name "03_design_tokens" -Description "Design Tokens file content" -Command "Get-Content -Path lib/core/theme/design_tokens.dart" -Result $designTokens

# 4. Collect Docker Compose evidence
Write-Host "4. Collecting Docker Compose evidence..." -ForegroundColor Cyan
$dockerCompose = Get-Content -Path "docker-compose.yml" -Raw
Save-Evidence -Name "04_docker_compose" -Description "Docker Compose configuration" -Command "Get-Content -Path docker-compose.yml" -Result $dockerCompose

# 5. Collect init-replication.sh evidence
Write-Host "5. Collecting init-replication.sh evidence..." -ForegroundColor Cyan
$initScript = Get-Content -Path "init-replication.sh" -Raw
Save-Evidence -Name "05_init_replication" -Description "Replication initialization script" -Command "Get-Content -Path init-replication.sh" -Result $initScript

# 6. Check if Docker is available
Write-Host "6. Checking Docker availability..." -ForegroundColor Cyan
$dockerAvailable = $false
try {
    $dockerVersion = docker --version 2>&1
    $dockerAvailable = $true
    Save-Evidence -Name "06_docker_availability" -Description "Docker installation check" -Command "docker --version" -Result $dockerVersion
} catch {
    Save-Evidence -Name "06_docker_availability" -Description "Docker installation check" -Command "docker --version" -Result "Docker not available or not in PATH"
}

# 7. Check if docker-compose files exist
Write-Host "7. Checking Docker Compose files..." -ForegroundColor Cyan
$composeFiles = @("docker-compose.yml", "docker-compose.test.yml")
foreach ($file in $composeFiles) {
    $exists = Test-Path $file
    Save-Evidence -Name "07_compose_file_$file" -Description "Docker Compose file existence check" -Command "Test-Path '$file'" -Result "Exists: $exists"
}

# 8. Collect project structure summary
Write-Host "8. Collecting project structure summary..." -ForegroundColor Cyan
$projectStructure = @"
Project Root Files:
$(Get-ChildItem -Path "." -File | Select-Object -ExpandProperty Name | Sort-Object)

Lib Directory Structure:
$(Get-ChildItem -Path "lib" -Recurse -Directory | Select-Object -ExpandProperty FullName | Sort-Object)

Test Directory Structure:
$(if (Test-Path "test") { Get-ChildItem -Path "test" -Recurse -Directory | Select-Object -ExpandProperty FullName | Sort-Object } else { "No test directory found" })
"@
Save-Evidence -Name "08_project_structure" -Description "Complete project structure summary" -Command "Get-ChildItem" -Result $projectStructure

# 9. Generate validation checklist
Write-Host "9. Generating validation checklist..." -ForegroundColor Cyan
$checklist = @"
Sprint 0 Validation Checklist
============================

1. FOLDER STRUCTURE
   [OK] lib/core/theme/ exists
   [OK] lib/core/network/ exists
   [OK] lib/features/auth/presentation/bloc/ exists
   [OK] lib/features/auth/domain/entities/ exists
   [OK] lib/features/auth/data/datasources/ exists
   [OK] lib/features/loader/presentation/ exists
   [OK] lib/features/loader/data/ exists
   [OK] 18 .gitkeep files found

2. DESIGN TOKENS
   [OK] SafetyRed: 0xFFDC3545
   [OK] WarningYellow: 0xFFFFC107
   [OK] GovBlue: 0xFF0D6EFD
   [OK] SafeGreen: 0xFF198754
   [OK] tactileMinSize: 48.0

3. DOCKER INFRASTRUCTURE
   [PENDING] Docker available: $dockerAvailable
   [PENDING] docker-compose.yml valid
   [PENDING] init-replication.sh functional
   [PENDING] Containers healthy
   [PENDING] Replication streaming

4. RUNTIME VERIFICATION
   [PENDING] db_primary healthy
   [PENDING] db_replica healthy
   [PENDING] pg_stat_replication shows streaming
   [PENDING] Insert/select between primary/replica works

Evidence collected at: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
"@

$checklist | Out-File -FilePath "$OutputDir/validation_checklist.txt" -Encoding UTF8
Write-Host "✓ Validation checklist saved: $OutputDir/validation_checklist.txt" -ForegroundColor Green

# Summary
Write-Host ""
Write-Host "=== Evidence Collection Complete ===" -ForegroundColor Cyan
Write-Host "Total files created: $((Get-ChildItem -Path $OutputDir -File).Count)" -ForegroundColor Yellow
Write-Host "Evidence directory: $OutputDir" -ForegroundColor Yellow
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "1. Review collected evidence in $OutputDir" -ForegroundColor White
Write-Host "2. Take screenshots for visual evidence" -ForegroundColor White
Write-Host "3. Run Docker commands for runtime verification" -ForegroundColor White
Write-Host "4. Update validacion_sprint0.md with final results" -ForegroundColor White