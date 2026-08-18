# Simple Evidence Collection Script - Sprint 0 Validation

$OutputDir = "evidence"
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

Write-Host "Collecting evidence for Sprint 0 validation..." -ForegroundColor Cyan

# 1. Folder structure
Write-Host "1. Collecting folder structure..." -ForegroundColor Yellow
$structure = Get-ChildItem -Path "lib" -Recurse -Directory | Select-Object -ExpandProperty FullName
$structure | Out-File -FilePath "$OutputDir/01_folder_structure.txt" -Encoding UTF8

# 2. Gitkeep count
Write-Host "2. Counting .gitkeep files..." -ForegroundColor Yellow
$gitkeepCount = Get-ChildItem -Path "lib" -Recurse -Filter ".gitkeep" | Measure-Object | Select-Object -ExpandProperty Count
"Total .gitkeep files: $gitkeepCount" | Out-File -FilePath "$OutputDir/02_gitkeep_count.txt" -Encoding UTF8

# 3. Design tokens
Write-Host "3. Collecting design tokens..." -ForegroundColor Yellow
Get-Content -Path "lib/core/theme/design_tokens.dart" | Out-File -FilePath "$OutputDir/03_design_tokens.txt" -Encoding UTF8

# 4. Docker compose
Write-Host "4. Collecting docker compose..." -ForegroundColor Yellow
Get-Content -Path "docker-compose.yml" | Out-File -FilePath "$OutputDir/04_docker_compose.txt" -Encoding UTF8

# 5. Init script
Write-Host "5. Collecting init script..." -ForegroundColor Yellow
Get-Content -Path "init-replication.sh" | Out-File -FilePath "$OutputDir/05_init_script.txt" -Encoding UTF8

# 6. Project files
Write-Host "6. Collecting project files..." -ForegroundColor Yellow
Get-ChildItem -Path "." -File | Select-Object -ExpandProperty Name | Sort-Object | Out-File -FilePath "$OutputDir/06_project_files.txt" -Encoding UTF8

Write-Host "Evidence collection complete!" -ForegroundColor Green
Write-Host "Files saved to: $OutputDir" -ForegroundColor Yellow
Get-ChildItem -Path $OutputDir -File | Select-Object -ExpandProperty Name